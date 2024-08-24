// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Base} from "test/utils/Addresses.sol";
import {IQuoterV2} from "test/interfaces/IQuoter.sol";
import {ISugarHelper} from "test/interfaces/ISugarHelper.sol";
import {IAMOStrategy} from "test/interfaces/IAMOStrategy.sol";

library BinarySearchQuoter {
    ////////////////////////////////////////////////////////////////
    /// --- STRUCTS & ENUMS
    ////////////////////////////////////////////////////////////////
    struct BinarySearchQuoterParams {
        bool swapWETHForOETHB;
        uint256 targetPrice;
        uint160 sqrtPriceLimitX96;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 allowedVariance;
        uint256 maxIterations;
    }

    struct SearchState {
        uint256 low;
        uint256 high;
        uint256 iterations;
        uint160 sqrtPriceX96After;
    }

    struct QuoteParams {
        address tokenIn;
        address tokenOut;
        int24 tickSpacing;
        uint160 sqrtPriceLimitX96;
    }

    enum RevertReasons {
        RebalanceOutOfBounds,
        NotInExpectedTickRange,
        NotEnoughWethForSwap,
        NotEnoughWethLiquidity,
        UnexpectedError,
        Found
    }

    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS
    ////////////////////////////////////////////////////////////////
    int24 private constant DEFAULT_LOWER_TICK = -1;
    int24 private constant DEFAULT_UPPER_TICK = 0;
    int24 private constant TICK_SPACING = 1;
    uint256 private constant PERCENTAGE_BASE = 1e27; // 100%
    IQuoterV2 private constant quoter = IQuoterV2(Base.QUOTERV2);
    IAMOStrategy private constant strategy = IAMOStrategy(Base.AMO_STRATEGY);
    ISugarHelper private constant sugarHelper = ISugarHelper(Base.SUGAR_HELPER);

    ////////////////////////////////////////////////////////////////
    /// --- EVENTS
    ////////////////////////////////////////////////////////////////
    event log_named_uint(string name, uint256 value);
    event log_named_int(string name, int256 value);

    ////////////////////////////////////////////////////////////////
    /// --- INVERTED QUOTER FOR SWAP
    ////////////////////////////////////////////////////////////////
    /// @notice Get the amount of token to swap to reach the target price
    function amountToSwapToReachPrice(BinarySearchQuoterParams memory params)
        external
        returns (uint256, uint160, uint256)
    {
        SearchState memory state =
            SearchState({low: params.minAmount, high: params.maxAmount, iterations: 0, sqrtPriceX96After: 0});

        QuoteParams memory quoteParams = QuoteParams({
            tokenIn: params.swapWETHForOETHB ? Base.WETH : Base.OETHB,
            tokenOut: params.swapWETHForOETHB ? Base.OETHB : Base.WETH,
            tickSpacing: TICK_SPACING,
            sqrtPriceLimitX96: params.sqrtPriceLimitX96
        });

        while (state.low <= state.high && state.iterations < params.maxIterations) {
            uint256 mid = (state.low + state.high) / 2;

            uint160 sqrtPriceX96After = _getPriceAfter(
                quoter,
                quoteParams.tokenIn,
                quoteParams.tokenOut,
                mid,
                quoteParams.tickSpacing,
                quoteParams.sqrtPriceLimitX96
            );

            if (
                state.low == state.high
                    || _isWithinAllowedVariance(sqrtPriceX96After, params.targetPrice, params.allowedVariance)
            ) {
                return (mid, sqrtPriceX96After, state.iterations);
            } else if (
                params.swapWETHForOETHB
                    ? (sqrtPriceX96After > params.targetPrice)
                    : (sqrtPriceX96After < params.targetPrice)
            ) {
                state.low = mid + 1;
            } else {
                state.high = mid;
            }
            state.iterations++;
        }

        revert("Quoter: max iterations reached");
    }

    /// @notice Helper that returns the price after swapping `amount` of `tokenIn` for `tokenOut`
    function _getPriceAfter(
        IQuoterV2 _quoter,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        int24 _tickSpacing,
        uint160 _sqrtPriceLimitX96
    ) private returns (uint160) {
        IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            amountIn: _amountIn,
            tickSpacing: _tickSpacing,
            sqrtPriceLimitX96: _sqrtPriceLimitX96
        });
        (, uint160 sqrtPriceX96After,,) = _quoter.quoteExactInputSingle(params);
        return sqrtPriceX96After;
    }

    /// @notice Helper that checks if the current price is within the allowed variance
    function _isWithinAllowedVariance(uint256 currentPrice, uint256 targetPrice, uint256 allowedVariancePercentage)
        private
        pure
        returns (bool)
    {
        uint256 allowedVariance = (targetPrice * allowedVariancePercentage) / PERCENTAGE_BASE;
        if (currentPrice > targetPrice) {
            return currentPrice - targetPrice <= allowedVariance;
        } else {
            return targetPrice - currentPrice <= allowedVariance;
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- INVERTED QUOTER FOR SWAP BEFORE REBALANCE
    ////////////////////////////////////////////////////////////////
    /// @notice Get the amount of token to swap to reach the target price before rebalance
    /// @dev This quoter is home made and actually performs a binary search to find the amount of token to swap
    /// @dev but the last transaction is NOT reverted, this means that the pool will be in an invalid state. 
    /// @dev Use forge `vm.snapshot()` and `vm.revertToAndDelete()` to revert the state after using this function. 
    function amountToSwapToReachTargetPriceBeforeRebalance(BinarySearchQuoterParams memory params)
        public
        returns (uint256, uint256)
    {
        uint256 low = params.minAmount;
        uint256 high = params.maxAmount;
        uint256 iterations = 0;

        while (low <= high && iterations < params.maxIterations) {
            uint256 mid = (low + high) / 2;

            // Get quote to get pool share after swapping `amount` and rebalancing
            (
                RevertReasons reason,
                uint256 currentPoolWethShare,
                uint256 allowedWethShareStart,
                uint256 allowedWethShareEnd,
                int24 currentTick
            ) = _getPoolShareAfterRebalance(mid, params.swapWETHForOETHB);

            // Best case, we found the `amount` that will reach the target pool share!
            if (reason == RevertReasons.Found) {
                emit log_named_uint("Amount Found: ", mid);
                return (mid, iterations);
            }

            // Worst case, it reverted and we don't know why
            if (reason == RevertReasons.UnexpectedError) {
                revert("Quoter: Unexpected error");
            }

            // If the pool is not in the expected tick range, we need to increase the amount
            // Must be improve
            if (reason == RevertReasons.NotInExpectedTickRange) {
                emit log_named_uint("Amount Wrong tick range: ", mid);
                emit log_named_int("Current tick: ", currentTick);
                emit log_named_int("Lower tick: ", DEFAULT_LOWER_TICK);
                emit log_named_int("Upper tick: ", DEFAULT_UPPER_TICK);
                // If we are buying OETHb and the current tick is greater than the lower tick, we need to increase the amount
                // in order to continue to push price down.
                // If we are selling OETHb and the current tick is less than the upper tick, we need to increase the amount
                // in order to continue to push price up.
                if (params.swapWETHForOETHB ? currentTick > DEFAULT_LOWER_TICK : currentTick < DEFAULT_UPPER_TICK) {
                    low = mid + 1;
                }
                // Else we need to decrease the amount
                else {
                    high = mid;
                }
            }

            // If the pool is out of bounds, we need to adjust the amount to reach the target pool share
            if (reason == RevertReasons.RebalanceOutOfBounds) {
                emit log_named_uint("Amount Reverted: ", mid);
                emit log_named_uint("Current pool share Reverted : ", currentPoolWethShare);
                emit log_named_uint("Allowed WETH Share Start: ", allowedWethShareStart);
                emit log_named_uint("Allowed WETH Share End: ", allowedWethShareEnd);
                // If the current pool share is less than the target pool share, we need to increase the amount
                if (
                    params.swapWETHForOETHB
                        ? currentPoolWethShare < allowedWethShareStart
                        : currentPoolWethShare > allowedWethShareEnd
                ) {
                    low = mid + 1;
                }
                // Else we need to decrease the amount
                else {
                    high = mid;
                }
            }

            // If we don't have enough WETH to swap, we need to decrease the amount
            // This error can happen, when initial value of mid is too high, so we need to decrease it
            if (reason == RevertReasons.NotEnoughWethForSwap) {
                emit log_named_uint("Amount Not enough WETH: ", mid);
                // currentPoolWethShare is the WETH balance
                // targetedPoolWethShare is the amount of WETH we want to swap
                high = mid;
            }

            // If we don't have enough WETH liquidity
            // Revert for the moment, we need to improve this
            if (reason == RevertReasons.NotEnoughWethLiquidity) {
                emit log_named_uint("Amount Not enough WETH liquidity: ", mid);
                revert("Quoter: Not enough WETH liquidity");
            }

            iterations++;
        }

        //return (0, iterations);
        revert("Quoter: max iterations reached");
    }

    /// @notice Get the pool share after rebalancing, using try and catch method, analysing the revert reason
    function _getPoolShareAfterRebalance(uint256 amount, bool swapWETH)
        public
        returns (
            RevertReasons,
            uint256 currentPoolWethShare,
            uint256 allowedWethShareStart,
            uint256 allowedWethShareEnd,
            int24 currentTick
        )
    {
        try strategy.rebalance(amount, swapWETH, 0) {
            return (RevertReasons.Found, 1, 1, 1, 1);
        } catch Error(string memory) {
            return (RevertReasons.UnexpectedError, 0, 0, 0, 0);
        } catch (bytes memory reason) {
            bytes4 receivedSelector = bytes4(reason);

            // Error: PoolRebalanceOutOfBounds
            bytes4 expectedSelectorPoolRebalanceOutOfBounds = IAMOStrategy.PoolRebalanceOutOfBounds.selector;
            bytes4 expectedSelectorOutsideExpectedTickRange = IAMOStrategy.OutsideExpectedTickRange.selector;
            bytes4 expectedSelectorNotEnoughWethForSwap = IAMOStrategy.NotEnoughWethForSwap.selector;
            bytes4 expectedSelectorNotEnoughWethLiquidity = IAMOStrategy.NotEnoughWethLiquidity.selector;

            if (receivedSelector == expectedSelectorPoolRebalanceOutOfBounds) {
                assembly ("memory-safe") {
                    currentPoolWethShare := mload(add(reason, 0x24))
                    allowedWethShareStart := mload(add(reason, 0x44))
                    allowedWethShareEnd := mload(add(reason, 0x64))
                }
                return (
                    RevertReasons.RebalanceOutOfBounds,
                    currentPoolWethShare,
                    allowedWethShareStart,
                    allowedWethShareEnd,
                    0
                );
            }
            // Error: OutsideExpectedTickRange
            else if (receivedSelector == expectedSelectorOutsideExpectedTickRange) {
                int24 _currentTick;

                assembly {
                    _currentTick := mload(add(reason, 0x24))
                }

                return (RevertReasons.NotInExpectedTickRange, 0, 0, 0, _currentTick);
            }
            // Error: NotEnoughWethForSwap
            else if (receivedSelector == expectedSelectorNotEnoughWethForSwap) {
                assembly ("memory-safe") {
                    currentPoolWethShare := mload(add(reason, 0x24)) // wethBalance
                    allowedWethShareStart := mload(add(reason, 0x44)) // wethAmount
                }
                return (RevertReasons.NotEnoughWethForSwap, currentPoolWethShare, allowedWethShareStart, 0, 0);
            }
            // Error: NotEnoughWethLiquidity
            else if (receivedSelector == expectedSelectorNotEnoughWethLiquidity) {
                return (RevertReasons.NotEnoughWethLiquidity, 0, 0, 0, 0);
            }
            // Error: UnexpectedError
            else {
                return (RevertReasons.UnexpectedError, 0, 0, 0, 0);
            }
        }
    }
}

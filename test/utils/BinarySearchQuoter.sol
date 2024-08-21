// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Base} from "test/utils/Addresses.sol";
import {IQuoterV2} from "test/interfaces/IQuoter.sol";

library BinarySearchQuoter {
    int24 private constant TICK_SPACING = 1;
    uint256 private constant PERCENTAGE_BASE = 1e27; // 100%
    IQuoterV2 private constant quoter = IQuoterV2(Base.QUOTERV2);

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

            uint160 sqrtPriceX96After = getPriceAfter(
                quoter,
                quoteParams.tokenIn,
                quoteParams.tokenOut,
                mid,
                quoteParams.tickSpacing,
                quoteParams.sqrtPriceLimitX96
            );

            if (
                state.low == state.high
                    || isWithinAllowedVariance(sqrtPriceX96After, params.targetPrice, params.allowedVariance)
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

    function getPriceAfter(
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

    function isWithinAllowedVariance(uint256 currentPrice, uint256 targetPrice, uint256 allowedVariancePercentage)
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
}

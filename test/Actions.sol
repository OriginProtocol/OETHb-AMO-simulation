// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC721Holder} from "lib/contracts/lib/openzeppelin-contracts/contracts/token/ERC721/utils/ERC721Holder.sol";

// Internal utils
import {TickMath} from "test/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Internal for testing
import {Base_Test_} from "test/Base.sol";

abstract contract Actions is Base_Test_, ERC721Holder {
    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE LIQUDITY
    ////////////////////////////////////////////////////////////////

    // --- Initial liquidity deposit --- //
    function addLiquidity(uint256 amount0, uint256 amount1) public returns (uint256, uint128) {
        deal(address(token0), address(this), amount0);
        deal(address(token1), address(this), amount1);

        // Add liquidity
        (uint256 tokenId, uint128 liquidity,,) = nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(token0),
                token1: address(token1),
                tickSpacing: TICK_SPACING,
                tickLower: LOWER_TICK,
                tickUpper: UPPER_TICK,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );

        return (tokenId, liquidity);
    }

    function addLiquidityAndStake(uint256 amount0, uint256 amount1) public returns (uint256, uint128) {
        (uint256 tokenId, uint128 liquidity) = addLiquidity(amount0, amount1);
        stake(tokenId);

        return (tokenId, liquidity);
    }

    // --- Increase liquidity --- //
    function increaseLiquidity(uint256 tokenId, uint256 _amount0, uint256 _amount1)
        public
        returns (uint128, uint256, uint256)
    {
        deal(address(token0), address(this), _amount0);
        deal(address(token1), address(this), _amount1);

        // Increase liquidity
        (uint128 liquidity, uint256 amount0, uint256 amount1) = nftManager.increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: _amount0,
                amount1Desired: _amount1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 100
            })
        );

        return (liquidity, amount0, amount1);
    }

    function increaseLiquidityAndStake(uint256 tokenId, uint256 _amount0, uint256 _amount1)
        public
        returns (uint128, uint256, uint256)
    {
        unstake(tokenId);
        (uint128 liquidity, uint256 amount0, uint256 amount1) = increaseLiquidity(tokenId, _amount0, _amount1);
        stake(tokenId);
        return (liquidity, amount0, amount1);
    }

    // --- Decrease liquidity --- //
    function decreaseLiquidity(uint256 tokenId, uint128 liquidity) public returns (uint256, uint256) {
        return nftManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 100
            })
        );
    }

    function decreaseAllLiquidity(uint256 tokenId) public returns (uint256, uint256) {
        (,,,,,,, uint128 liquidity,,,,) = nftManager.positions(tokenId);
        return decreaseLiquidity(tokenId, liquidity);
    }

    function unstakeAndDecreaseLiquidity(uint256 tokenId, uint128 liquidity) public returns (uint256, uint256) {
        unstake(tokenId);
        (uint256 amount0, uint256 amount1) = decreaseLiquidity(tokenId, liquidity);
        stake(tokenId);
        return (amount0, amount1);
    }

    function unstakeAndAllDecreaseLiquidity(uint256 tokenId) public returns (uint256, uint256) {
        unstake(tokenId);
        return decreaseAllLiquidity(tokenId);
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE GAUGE
    ////////////////////////////////////////////////////////////////
    function stake(uint256 tokenId) public {
        gauge.deposit(tokenId);
    }

    function unstake(uint256 tokenId) public {
        gauge.withdraw(tokenId);
    }
    ////////////////////////////////////////////////////////////////
    /// --- MANAGE USER ACTIONS
    ////////////////////////////////////////////////////////////////

    function swap(address tokenIn, uint256 amountIn) public {
        bool zeroForOne = tokenIn == address(token0);
        int256 amountSpecified = zeroForOne ? int256(amountIn) : -int256(amountIn);
        uint160 sqrtPriceLimitX96 = zeroForOne ? TickMath.getSqrtRatioAtTick(-1) : TickMath.getSqrtRatioAtTick(100);

        // Swap
        pool.swap({
            recipient: address(this),
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96,
            data: ""
        });
    }
}

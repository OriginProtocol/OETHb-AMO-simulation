// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Internal utils
import {TickMath} from "test/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Internal for testing
import {Base_Test_} from "test/Base.sol";

abstract contract Actions is Base_Test_ {
    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE LIQUDITY
    ////////////////////////////////////////////////////////////////
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

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE GAUGE
    ////////////////////////////////////////////////////////////////
    function stake(uint256 tokenId) public {
        gauge.deposit(tokenId);
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE SWAP
    ////////////////////////////////////////////////////////////////
    function swap(address tokenIn, uint256 amountIn) public {
        deal(tokenIn, address(this), amountIn);

        bool zeroForOne = tokenIn == address(token0);
        int256 amountSpecified = zeroForOne ? int256(amountIn) : -int256(amountIn);
        uint160 sqrtPriceLimitX96 = zeroForOne ? TickMath.getSqrtRatioAtTick(-100) : TickMath.getSqrtRatioAtTick(100);

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

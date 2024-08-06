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

        // Infinite approval from voter to gauge for AERO
        vm.prank(address(voter));
        AERO.approve(address(gauge), type(uint256).max);
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

    function addLiquidityAndStake(uint256 amount0, uint256 amount1) public returns (uint256, uint128) {
        (uint256 tokenId, uint128 liquidity) = addLiquidity(amount0, amount1);
        stake(tokenId);

        return (tokenId, liquidity);
    }

    ////////////////////////////////////////////////////////////////
    /// --- MANAGE GAUGE
    ////////////////////////////////////////////////////////////////
    function stake(uint256 tokenId) public {
        gauge.deposit(tokenId);
    }

    function distributeReward(uint256 amount) public {
        skip(10 days);
        deal(address(AERO), address(voter), amount);
        vm.startPrank(address(voter));
        gauge.notifyRewardAmount(amount);
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

    function claimRewards() public {
        skip(1 days);
        gauge.getReward(address(this));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base test
import {Base_Test_} from "test/Base.sol";

// Solmate and Solady
import {SafeCastLib} from "lib/solady/src/utils/SafeCastLib.sol";

// Interfaces -- Aerodrome
import {ISwapRouter} from "test/interfaces/ISwapRouter.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Utils
import {TickMath} from "test/libraries/TickMath.sol";

/// @notice List any actions than an external actor can perform on the pool, vault, or strategy
abstract contract Base_Pool_Actions_ is Base_Test_ {
    using SafeCastLib for uint256;

    ////////////////////////////////////////////////////////////////
    /// --- DEAL
    ////////////////////////////////////////////////////////////////
    modifier dealToken_(uint256 amountWETH, uint256 amountOETHb, bool _deal) {
        if (_deal) dealToken(amountWETH, amountOETHb);
        _;
    }

    function dealToken(uint256 amountWETH, uint256 amountOETHb) internal {
        deal(address(weth), address(this), amountWETH);
        deal(address(oethb), address(this), amountOETHb);
    }

    ////////////////////////////////////////////////////////////////
    /// --- PROVIDE LIQUIDITY
    ////////////////////////////////////////////////////////////////
    function provideLiquidity(uint256 amount0, uint256 amount1, int24 tickLower, int24 tickUpper, bool deal)
        public
        dealToken_(amount0, amount1, deal)
    {
        nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(weth),
                token1: address(oethb),
                tickSpacing: DEFAULT_TICK_SPACING,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );
    }

    function provideLiquidity(uint256 amount0, uint256 amount1, bool deal) public {
        provideLiquidity(amount0, amount1, DEFAULT_LOWER_TICK, DEFAULT_UPPER_TICK, deal);
    }

    ////////////////////////////////////////////////////////////////
    /// --- SWAP
    ////////////////////////////////////////////////////////////////

    // Swap WETH for OETHb
    function swapWETHExactInput(uint256 amountIn, uint256 sqrtPriceLimitX96, bool deal)
        public
        dealToken_(amountIn, 0, deal)
    {
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(weth),
                tokenOut: address(oethb),
                tickSpacing: DEFAULT_TICK_SPACING,
                recipient: address(this),
                deadline: block.timestamp + 1,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: (sqrtPriceLimitX96).toUint160()
            })
        );
    }

    function swapWETHExactInput(uint256 amountIn, int24 tick, bool deal) public {
        uint160 sqrtPriceLimitX96 = TickMath.getSqrtRatioAtTick(tick);
        swapWETHExactInput(amountIn, sqrtPriceLimitX96, deal);
    }

    function swapWETHExactInput(uint256 amountIn, bool deal) public {
        swapWETHExactInput(amountIn, TickMath.getSqrtRatioAtTick(TickMath.MIN_TICK), deal);
    }

    // Swap OETHb for WETH
    function swapOETHbExactInput(uint256 amountIn, uint256 sqrtPriceLimitX96, bool deal)
        public
        dealToken_(0, amountIn, deal)
    {
        swapRouter.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(oethb),
                tokenOut: address(weth),
                tickSpacing: DEFAULT_TICK_SPACING,
                recipient: address(this),
                deadline: block.timestamp + 1,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: (sqrtPriceLimitX96).toUint160()
            })
        );
    }

    function swapOETHbExactInput(uint256 amountIn, int24 tick, bool deal) public {
        uint160 sqrtPriceLimitX96 = TickMath.getSqrtRatioAtTick(tick);
        swapOETHbExactInput(amountIn, sqrtPriceLimitX96, deal);
    }

    function swapOETHbExactInput(uint256 amountIn, bool deal) public {
        swapOETHbExactInput(amountIn, TickMath.getSqrtRatioAtTick(TickMath.MAX_TICK), deal);
    }
}

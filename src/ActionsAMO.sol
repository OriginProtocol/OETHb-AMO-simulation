// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {TickMath} from "test/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

contract ActionsAMO {
    int24 public immutable DEFAULT_TICK_SPACING;
    int24 public immutable DEFAULT_LOWER_TICK;
    int24 public immutable DEFAULT_UPPER_TICK;

    ERC20 public weth;
    ERC20 public oethb;
    ICLPool public pool;
    INonfungiblePositionManager public nftManager;

    uint256 public tokenId;

    constructor(INonfungiblePositionManager _nftManager, ICLPool _pool, ERC20 _weth, ERC20 _oethb) {
        DEFAULT_TICK_SPACING = 1;
        DEFAULT_LOWER_TICK = 0;
        DEFAULT_UPPER_TICK = 1;

        pool = _pool;
        weth = _weth;
        oethb = _oethb;
        nftManager = _nftManager;

        // Approvals
        weth.approve(address(nftManager), type(uint256).max);
        oethb.approve(address(nftManager), type(uint256).max);
    }

    function _addIinitialLiquidity(uint256 amount0, uint256 amount1) internal returns (uint256, uint128) {
        (uint256 tokenId_, uint128 liquidity_,,) = nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(weth),
                token1: address(oethb),
                tickSpacing: DEFAULT_TICK_SPACING,
                tickLower: DEFAULT_LOWER_TICK,
                tickUpper: DEFAULT_UPPER_TICK,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );
        tokenId = tokenId_;

        return (tokenId_, liquidity_);
    }

    function _increaseLiquidity(uint256 _amount0, uint256 _amount1) internal returns (uint128, uint256, uint256) {
        return nftManager.increaseLiquidity(
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: _amount0,
                amount1Desired: _amount1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 100
            })
        );
    }

    function _decreaseLiquidity(uint128 liquidity) internal returns (uint256, uint256) {
        nftManager.decreaseLiquidity(
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: liquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 100
            })
        );
        return nftManager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );
    }

    function _removeAllLiquidity() internal returns (uint256, uint256) {
        (,,,,,,, uint128 liquidity,,,,) = nftManager.positions(tokenId);
        return _decreaseLiquidity(liquidity);
    }

    function _swap(address tokenIn, uint256 amountIn) internal {
        _swap(tokenIn, amountIn, int24(100));
    }

    function _swap(address tokenIn, uint256 amountIn, int24 maxTick) internal {
        bool zeroForOne = tokenIn == address(weth);
        int256 amountSpecified = zeroForOne ? int256(amountIn) : -int256(amountIn);
        uint160 sqrtPriceLimitX96 =
            zeroForOne ? TickMath.getSqrtRatioAtTick(-maxTick) : TickMath.getSqrtRatioAtTick(maxTick);

        // Swap
        pool.swap({
            recipient: address(this),
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96,
            data: ""
        });
    }

    function _swap(address tokenIn, uint256 amountIn, uint160 sqrtPrice) internal {
        bool zeroForOne = tokenIn == address(weth);
        int256 amountSpecified = zeroForOne ? int256(amountIn) : -int256(amountIn);
        uint160 sqrtPriceLimitX96 = sqrtPrice;

        // Swap
        pool.swap({
            recipient: address(this),
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96,
            data: ""
        });
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        if (amount0Delta > 0) weth.transfer(address(pool), uint256(amount0Delta));
        else if (amount1Delta > 0) oethb.transfer(address(pool), uint256(amount1Delta));
    }

    function _mintOETHb(uint256 amount, address receiver) internal {
        MockERC20(address(weth)).mint(receiver, amount);
    }

    function _burnOETHb(uint256 amount, address receiver) internal {
        MockERC20(address(weth)).burn(receiver, amount);
    }
}

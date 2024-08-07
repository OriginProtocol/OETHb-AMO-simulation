// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {TickMath} from "test/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

contract AMO_Actions {
    int24 public immutable DEFAULT_TICK_SPACING;
    int24 public immutable DEFAULT_LOWER_TICK;
    int24 public immutable DEFAULT_UPPER_TICK;

    ERC20 public token0;
    ERC20 public token1;
    ICLPool public pool;
    INonfungiblePositionManager public nftManager;

    int256 public totalOETHbAMO;
    uint256 public tokenId;

    constructor(INonfungiblePositionManager _nftManager, ICLPool _pool, ERC20 _token0, ERC20 _token1) {
        DEFAULT_TICK_SPACING = 1;
        DEFAULT_LOWER_TICK = 0;
        DEFAULT_UPPER_TICK = 1;

        pool = _pool;
        token0 = _token0;
        token1 = _token1;
        nftManager = _nftManager;

        // Approvals
        token0.approve(address(nftManager), type(uint256).max);
        token1.approve(address(nftManager), type(uint256).max);
    }

    function _addIinitialLiquidity(uint256 amount0, uint256 amount1) internal returns (uint256, uint128) {
        (uint256 tokenId_, uint128 liquidity_,,) = nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(token0),
                token1: address(token1),
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

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        if (amount0Delta > 0) token0.transfer(address(pool), uint256(amount0Delta));
        else if (amount1Delta > 0) token1.transfer(address(pool), uint256(amount1Delta));
    }

    function _mintOETHb(uint256 amount) internal {
        totalOETHbAMO += int256(amount);
        MockERC20(address(token0)).mint(address(this), amount);
    }

    function _burnOETHb(uint256 amount) internal {
        totalOETHbAMO -= int256(amount);
        MockERC20(address(token0)).burn(address(this), amount);
    }
}

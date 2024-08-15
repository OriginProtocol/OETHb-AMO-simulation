// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Solmate & Solady
import {ERC20} from "@solmate/tokens/ERC20.sol";

// Internal interfaces & libraries
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {TickMath} from "test/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

contract ActionsAMO {
    //////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    //////////////////////////////////////////////////////
    int24 public constant DEFAULT_LOWER_TICK = 0;
    int24 public constant DEFAULT_UPPER_TICK = 1;
    int24 public constant DEFAULT_TICK_SPACING = 1;

    //////////////////////////////////////////////////////
    /// --- VARIABLES
    //////////////////////////////////////////////////////
    ERC20 public weth;
    ERC20 public oethb;
    ICLPool public pool;
    INonfungiblePositionManager public nftManager;

    uint256 public tokenId;

    //////////////////////////////////////////////////////
    /// --- EVENTS
    //////////////////////////////////////////////////////
    event log_named_uint(string name, uint256 value);

    //////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    //////////////////////////////////////////////////////
    constructor(INonfungiblePositionManager _nftManager, ICLPool _pool, ERC20 _weth, ERC20 _oethb) {
        pool = _pool;
        weth = _weth;
        oethb = _oethb;
        nftManager = _nftManager;

        // Approvals
        weth.approve(address(nftManager), type(uint256).max);
        oethb.approve(address(nftManager), type(uint256).max);
    }

    //////////////////////////////////////////////////////
    /// --- MANAGE LIQUIDITY
    //////////////////////////////////////////////////////
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

    //////////////////////////////////////////////////////
    /// --- SWAP
    //////////////////////////////////////////////////////
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
}

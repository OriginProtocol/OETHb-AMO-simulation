// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ActionsAMO} from "src/ActionsAMO.sol";

import {Vault} from "src/Vault.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";
import {SafeCastLib} from "@solady/utils/SafeCastLib.sol";
import {SqrtPriceMath} from "src/libraries/SqrtPriceMath.sol";
import {TickMath} from "test/libraries/TickMath.sol";

contract StrategyAMO is ActionsAMO {
    uint256 public immutable LIQUIDITY_RATIO;

    Vault public vault;
    uint256 targetPrice;

    constructor(
        INonfungiblePositionManager _nftManager,
        ICLPool _pool,
        ERC20 _token0,
        ERC20 _token1,
        uint256 _liquidityRatio
    ) ActionsAMO(_nftManager, _pool, _token0, _token1) {
        LIQUIDITY_RATIO = _liquidityRatio;
    }

    function setVault(Vault _vault) external {
        vault = _vault;
        token0.approve(address(vault), type(uint256).max);
        token1.approve(address(vault), type(uint256).max);
    }

    function depositInPool(uint256 amountWETH) external {
        (, uint256 amountOETHb) = vault.depositInStrategy(amountWETH);
        if (tokenId == 0) _addIinitialLiquidity(amountOETHb, amountWETH);
        else _increaseLiquidity(amountOETHb, amountWETH);
    }

    function withdrawAllFromPool() external {
        (uint256 amountOETHb, uint256 amountWETH) = _removeAllLiquidity();
        vault.withdrawFromStrategy(amountOETHb, amountWETH);
    }

    event log_named_uint(string name, uint256 value);

    function prepareRebalance(uint256 percentage) external returns (uint256, uint256) {
        // First remove liquidity from pool
        (,,,,,,, uint128 liquidity,,,,) = nftManager.positions(tokenId);
        uint128 adjustedLiquidity = SafeCastLib.toUint128(liquidity * percentage / 1e18);
        _decreaseLiquidity(adjustedLiquidity);

        // Push price
        (uint160 currentSqrtPriceX96,,,,,) = pool.slot0();
        uint160 targetSqrtRatioBX96 = (
            TickMath.getSqrtRatioAtTick(0) * uint160(LIQUIDITY_RATIO)
                + TickMath.getSqrtRatioAtTick(1) * uint160(1e18 - LIQUIDITY_RATIO)
        ) / 1e18;
        emit log_named_uint("currentSqrtPriceX96", uint256(currentSqrtPriceX96));
        emit log_named_uint("targetSqrtRatioBX96", uint256(targetSqrtRatioBX96));
        targetPrice = uint256(targetSqrtRatioBX96);
        uint128 liquidityInPool = pool.liquidity();
        //(uint128 liquidityGross, int128 liquidityNet,,,,,,,,) = pool.ticks(0);
        //emit log_named_uint("liquidityInPool", uint256(liquidityInPool));
        //emit log_named_uint("liquidityGross", uint256(liquidityGross));
        //emit log_named_uint("liquidityNet", uint256(int256(liquidityNet)));

        uint256 amount0Delta;
        uint256 amount1Delta;
        if (currentSqrtPriceX96 > targetSqrtRatioBX96) {
            // Need to sell token1 and buy token0
            amount0Delta =
                SqrtPriceMath.getAmount1Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInPool, false);
            emit log_named_uint("amount0Delta", amount0Delta);
        } else if (currentSqrtPriceX96 < targetSqrtRatioBX96) {
            // Need to sell token0 and buy token1
            amount1Delta =
                SqrtPriceMath.getAmount0Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInPool, false);
            emit log_named_uint("amount1Delta", amount1Delta);
        }

        return (amount0Delta, amount1Delta);
        // Third add liquidity to pool:
    }

    function finalizeRebalance(uint256 amount0, uint256 amount1) public {
        // First swap tokens
        if (amount0 > 0) {
            _swap(address(token0), amount0);
        } else if (amount1 > 0) {
            _swap(address(token1), amount1);
        }
        (uint160 currentSqrtPriceX96,,,,,) = pool.slot0();
        emit log_named_uint("currentSqrtPriceX96", uint256(currentSqrtPriceX96));
        emit log_named_uint("targetPrice", targetPrice);
        uint256 diff = currentSqrtPriceX96 > targetPrice
            ? uint256(currentSqrtPriceX96 - uint160(targetPrice))
            : uint256(uint160(targetPrice) - currentSqrtPriceX96);
        emit log_named_uint("diff: %e", diff);

        // Second add liquidity to pool
        // Todo
        //_addLiquidity(amount0, amount1);
    }
}
// 29711541385420550358
// 29711541385424511746
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
    uint160 public targetPrice;
    uint160 public defaultTargetPrice;

    constructor(
        INonfungiblePositionManager _nftManager,
        ICLPool _pool,
        ERC20 _token0,
        ERC20 _token1,
        uint256 _liquidityRatio
    ) ActionsAMO(_nftManager, _pool, _token0, _token1) {
        LIQUIDITY_RATIO = _liquidityRatio;
        defaultTargetPrice = (
            TickMath.getSqrtRatioAtTick(0) * uint160(LIQUIDITY_RATIO)
                + TickMath.getSqrtRatioAtTick(1) * uint160(1e18 - LIQUIDITY_RATIO)
        ) / 1e18;
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
        (uint160 currentSqrtPriceX96, int24 currentTick,,,,) = pool.slot0();
        uint160 targetSqrtRatioBX96 = defaultTargetPrice;

        targetPrice = targetSqrtRatioBX96;
        //uint128 liquidityInPool = pool.liquidity();
        uint128 liquidityInTicks =
            _getLiquidityBetweenTicks(currentTick, TickMath.getTickAtSqrtRatio(targetSqrtRatioBX96));

        uint256 amount0Delta;
        uint256 amount1Delta;
        if (currentSqrtPriceX96 > targetSqrtRatioBX96) {
            // Need to sell token1 and buy token0
            amount0Delta =
                SqrtPriceMath.getAmount1Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInTicks, false);
            emit log_named_uint("amount1Delta", amount0Delta);
        } else if (currentSqrtPriceX96 < targetSqrtRatioBX96) {
            // Need to sell token0 and buy token1
            amount1Delta =
                SqrtPriceMath.getAmount0Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInTicks, false);
            emit log_named_uint("amount0Delta", amount1Delta);
        }

        return (amount0Delta, amount1Delta);
        // Third add liquidity to pool:
    }

    function finalizeRebalance(uint256 amount0, uint256 amount1) public {
        // First swap tokens
        if (amount0 > 0) {
            uint256 balance = token0.balanceOf(address(this));
            if (amount0 > balance) {
                // Need to mint more OETHb as all the OETHb have been bought
                // Not a problem as we make benefit from the arbitrage
                vault.mintOETHbForFree(amount0 - balance);
            }
            _swap(address(token0), amount0);
        } else if (amount1 > 0) {
            uint256 balance = token1.balanceOf(address(this));
            if (amount1 > balance) {
                // This is a tricky situation as someone has bought all the WETH
                // So in our position, there is only OETHb, and we cannot mint WETH
                // So we transfer it from the vault
                vault.transferWETHToStrategyForFree(amount1 - balance);
            }
            _swap(address(token1), amount1);
        }
        (uint160 currentSqrtPriceX96,,,,,) = pool.slot0();
        uint256 diff = currentSqrtPriceX96 > targetPrice
            ? uint256(currentSqrtPriceX96 - uint160(targetPrice))
            : uint256(uint160(targetPrice) - currentSqrtPriceX96);
        emit log_named_uint("Diff between targeted price and current price: ", diff);

        // Second add liquidity to pool
        _increaseLiquidity(token0.balanceOf(address(this)), token1.balanceOf(address(this)));
    }

    function _getLiquidityBetweenTicks(int24 lowerTick, int24 upperTick) internal returns (uint128) {
        uint128 liquidity;
        if (lowerTick > upperTick) {
            (lowerTick, upperTick) = (upperTick, lowerTick);
        }
        for (int24 tick = lowerTick; tick <= upperTick; tick += DEFAULT_TICK_SPACING) {
            (uint128 liquidityGross,,,,,,,,,) = pool.ticks(tick);
            liquidity += liquidityGross;
        }
        emit log_named_uint("Liquidity between ticks: ", liquidity);
        return liquidity;
    }
}

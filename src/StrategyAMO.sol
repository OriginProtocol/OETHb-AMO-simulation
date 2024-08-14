// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Vm} from "forge-std/Vm.sol";

import {ActionsAMO} from "src/ActionsAMO.sol";

import {Vault} from "src/Vault.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";
import {SafeCastLib} from "@solady/utils/SafeCastLib.sol";
import {SqrtPriceMath} from "src/libraries/SqrtPriceMath.sol";
import {TickMath} from "test/libraries/TickMath.sol";
import {ISugarHelper} from "test/interfaces/ISugarHelper.sol";
import {Base} from "test/utils/Addresses.sol";

contract StrategyAMO is ActionsAMO {
    Vm public immutable vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    uint256 public immutable LIQUIDITY_RATIO;

    Vault public vault;
    uint160 public targetPrice;
    uint160 public defaultTargetPrice;

    ISugarHelper public sugarHelper;

    constructor(
        INonfungiblePositionManager _nftManager,
        ICLPool _pool,
        ERC20 _weth,
        ERC20 _oethb,
        uint256 _liquidityRatio
    ) ActionsAMO(_nftManager, _pool, _weth, _oethb) {
        LIQUIDITY_RATIO = _liquidityRatio;
        defaultTargetPrice = getInitialPriceWithRatio(LIQUIDITY_RATIO);
        sugarHelper = ISugarHelper(Base.SUGAR_HELPER);
    }

    function setVault(Vault _vault) external {
        vault = _vault;
        weth.approve(address(vault), type(uint256).max);
        oethb.approve(address(vault), type(uint256).max);
    }

    function depositInPool(uint256 amountWETH) external {
        (, uint256 amountOETHb) = vault.depositInStrategy(amountWETH);
        if (tokenId == 0) _addIinitialLiquidity(amountWETH, amountOETHb);
        else _increaseLiquidity(amountOETHb, amountWETH);
    }

    function withdrawAllFromPool() external {
        _removeAllLiquidity();
        uint256 balanceWETH = weth.balanceOf(address(this));
        uint256 balanceOETHb = oethb.balanceOf(address(this));
        vault.withdrawFromStrategy(balanceOETHb, balanceWETH);
    }

    event log_named_uint(string name, uint256 value);

    function rebalance() public {
        rebalance(99e16);
    }

    function rebalance(uint256 percentage) public {
        // 1. Remove liquidity from pool
        (,,,,,,, uint128 liquidity,,,,) = nftManager.positions(tokenId);
        uint128 adjustedLiquidity = SafeCastLib.toUint128(liquidity * percentage / 1e18);
        _decreaseLiquidity(adjustedLiquidity);

        // 2.a Get current price and target price
        (uint160 currentSqrtPriceX96,,,,,) = pool.slot0();
        uint160 targetSqrtRatioBX96 = defaultTargetPrice;

        // 2.b Calculate the amount of tokens to swap to push the price to the target price
        (uint256 amount0Delta, uint256 amount1Delta) = _calculateAmounts(currentSqrtPriceX96, targetSqrtRatioBX96);

        emit log_named_uint("Current price before swap: ", uint256(currentSqrtPriceX96));
        // 2.c Swap tokens to push price to the target price
        if (amount0Delta > 0) {
            // Need to swap WETH for OETHb
            uint256 balance = weth.balanceOf(address(this));
            if (amount0Delta > balance) {
                // There is no enough WETH in the strategy, so check if we can take some from the vault
                uint256 amountNeeded = amount0Delta - balance;
                uint256 balanceVault = weth.balanceOf(address(vault));
                if (amountNeeded <= balanceVault) {
                    // Vault has enough WETH to give
                    vault.transferWETHToStrategyForFree(amountNeeded);
                } else {
                    revert("We don't want to cover this situation");
                }
            }
            require(weth.balanceOf(address(this)) >= amount0Delta, "Not enough WETH");
            _swap(address(weth), amount0Delta, defaultTargetPrice);
        } else if (amount1Delta > 0) {
            // Need to swap OETHb for WETH
            uint256 balance = oethb.balanceOf(address(this));
            if (amount1Delta > balance) {
                // There is no enough OETHb in the strategy, so the vault will mint it for free.
                vault.mintOETHbForFree(amount1Delta - balance);
            }
            require(oethb.balanceOf(address(this)) >= amount1Delta, "Not enough OETHb");
            _swap(address(oethb), amount1Delta, defaultTargetPrice);
        }
        (currentSqrtPriceX96,,,,,) = pool.slot0();
        emit log_named_uint("Current price After Swap:  ", uint256(currentSqrtPriceX96));
        emit log_named_uint("Target price: ", uint256(targetSqrtRatioBX96));
        uint256 diff = currentSqrtPriceX96 > targetSqrtRatioBX96
            ? currentSqrtPriceX96 - targetSqrtRatioBX96
            : targetSqrtRatioBX96 - currentSqrtPriceX96;
        emit log_named_uint("Difference: ", diff);
        // Require that difference between current price and target price is less than 0.000001%
        vm.assertApproxEqRel(currentSqrtPriceX96, targetSqrtRatioBX96, 1e10, "Price not reached");
        //require(currentSqrtPriceX96 == targetSqrtRatioBX96, "Price not reached");

        // 3. Add remaining liquidity to pool
        (, uint256 amount0, uint256 amount1) =
            _increaseLiquidity(weth.balanceOf(address(this)), oethb.balanceOf(address(this)));

        // Require that the amount0 is approx equal to ratio * amount1, 0.05% tolerance
        emit log_named_uint("Amount0: ", amount0);
        emit log_named_uint("Amount1: ", amount1);
        vm.assertApproxEqRel(amount0 * LIQUIDITY_RATIO, amount1 * 1e9, 5e14, "Liquidity not added correctly");

        // Maybe we should burn OETHb excess?
    }

    function _calculateAmounts(uint160 currentSqrtPriceX96, uint160 targetSqrtRatioBX96)
        internal
        returns (
            //view
            uint256 amount0Delta,
            uint256 amount1Delta
        )
    {
        uint128 liquidityInTicks = _getLiquidityBetweenTicks(
            TickMath.getTickAtSqrtRatio(currentSqrtPriceX96), TickMath.getTickAtSqrtRatio(targetSqrtRatioBX96)
        );

        if (currentSqrtPriceX96 > targetSqrtRatioBX96) {
            // amount0Delta obtained by calling getAmount1Delta, yes.
            amount0Delta = sugarHelper.getAmount0Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInTicks, true);
            emit log_named_uint("Amount0Delta: ", amount0Delta);
        } else if (currentSqrtPriceX96 < targetSqrtRatioBX96) {
            // amount1Delta obtained by calling getAmount0Delta, yes.
            // I don't know why but price reached is closer to the target when using getAmount0Delta for amount1Delta.
            amount1Delta = sugarHelper.getAmount1Delta(currentSqrtPriceX96, targetSqrtRatioBX96, liquidityInTicks, true);
            emit log_named_uint("Amount1Delta: ", amount1Delta);
        }
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function getInitialPriceWithRatio(uint256 ratio) public pure returns (uint160) {
        return (TickMath.getSqrtRatioAtTick(0) * 1e9 + TickMath.getSqrtRatioAtTick(1) * uint160(ratio))
            / uint160(1e9 + ratio);
    }
}

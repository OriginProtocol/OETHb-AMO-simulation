// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {console} from "lib/forge-std/src/console.sol";

import {TickMath} from "test/libraries/TickMath.sol";

import {Base_AMO_Actions_} from "test/AMOActions.sol";
import {Base_Pool_Actions_} from "test/PoolActions.sol";

import {BinarySearchQuoter} from "test/utils/BinarySearchQuoter.sol";

contract Base_Simulations_ is Base_AMO_Actions_, Base_Pool_Actions_ {
    function test_Quoter_WETHToOETHb() public {
        // Someone mint 100 OETHb
        deal(address(oethb), address(this), 100 ether);

        // Deposit 100 WETH and 100 OETHb between -10 and 10
        provideLiquidity(100 ether, 100 ether, -10, 10, true);

        // We allocate WETH to strategy
        allocate();

        // How much WETH we need to swap to reach target price
        (uint160 currentPrice,,,,,) = pool.slot0();
        uint160 targetPrice = TickMath.getSqrtRatioAtTick(-10);
        emit log_named_uint("Current price: ", currentPrice);
        emit log_named_uint("Target  price: ", targetPrice);

        uint160 priceLimit = TickMath.getSqrtRatioAtTick(-100);
        uint256 minAmount = 0.000001 ether;
        uint256 maxAmount = 1000000 ether;
        uint256 variance = 0;

        (uint256 amountToSwap, uint160 priceAfter, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachPrice(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: true,
                targetPrice: targetPrice,
                sqrtPriceLimitX96: priceLimit,
                minAmount: minAmount,
                maxAmount: maxAmount,
                allowedVariance: variance,
                maxIterations: 100
            })
        );
        uint256 deviance = (max(targetPrice, priceAfter) - min(targetPrice, priceAfter)) * 1e18 / targetPrice;

        console.log("TargetPrice: ", targetPrice);
        console.log("PriceAfter : ", priceAfter);
        console.log("deviance: %18e", deviance);
        console.log("Amount to swap: %18e", amountToSwap);
        console.log("Iterations: ", iterations);

        swapWETHExactInput(amountToSwap, priceLimit, true);
        (currentPrice,,,,,) = pool.slot0();
        console.log("Current price after swap: ", currentPrice);
        console.log("Targeted price:           ", targetPrice);
    }

    function test_Quoter_OETHbToWETH() public {
        // Someone mint 100 OETHb
        deal(address(oethb), address(this), 100 ether);

        // Deposit 100 WETH and 100 OETHb between -10 and 10
        provideLiquidity(100 ether, 100 ether, -10, 10, true);

        // We allocate WETH to strategy
        allocate();

        // How much WETH we need to swap to reach target price
        (uint160 currentPrice,,,,,) = pool.slot0();
        uint160 targetPrice = TickMath.getSqrtRatioAtTick(10);
        emit log_named_uint("Current price: ", currentPrice);
        emit log_named_uint("Target  price: ", targetPrice);

        uint160 priceLimit = TickMath.getSqrtRatioAtTick(100);
        uint256 minAmount = 0.000001 ether;
        uint256 maxAmount = 1000000 ether;
        uint256 variance = 0;

        (uint256 amountToSwap, uint160 priceAfter, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachPrice(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: false,
                targetPrice: targetPrice,
                sqrtPriceLimitX96: priceLimit,
                minAmount: minAmount,
                maxAmount: maxAmount,
                allowedVariance: variance,
                maxIterations: 100
            })
        );
        uint256 deviance = (max(targetPrice, priceAfter) - min(targetPrice, priceAfter)) * 1e18 / targetPrice;

        console.log("TargetPrice: ", targetPrice);
        console.log("PriceAfter : ", priceAfter);
        console.log("deviance: %18e", deviance);
        console.log("Amount to swap: %18e", amountToSwap);
        console.log("Iterations: ", iterations);

        swapOETHbExactInput(amountToSwap, priceLimit, true);
        (currentPrice,,,,,) = pool.slot0();
        console.log("Current price after swap: ", currentPrice);
        console.log("Targeted price:           ", targetPrice);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

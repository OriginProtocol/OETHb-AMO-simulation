// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {console} from "lib/forge-std/src/console.sol";

import {SafeCastLib} from "@solady/utils/SafeCastLib.sol";

import {TickMath} from "test/libraries/TickMath.sol";

import {Base_AMO_Actions_} from "test/AMOActions.sol";
import {Base_Pool_Actions_} from "test/PoolActions.sol";

import {BinarySearchQuoter} from "test/utils/BinarySearchQuoter.sol";

contract Base_Simulations_ is Base_AMO_Actions_, Base_Pool_Actions_ {
    using SafeCastLib for uint256;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    uint256 public constant DEFAULT_VARIANCE = 0; // 1e27 == 100%
    uint256 public constant DEFAULT_MAX_ITERATIONS = 500;
    uint160 public immutable DEFAULT_PRICE_LIMITE_LOW = TickMath.getSqrtRatioAtTick(-10_000);
    uint160 public immutable DEFAULT_PRICE_LIMITE_HIGH = TickMath.getSqrtRatioAtTick(10_000);
    uint256 public constant DEFAULT_AMOUNT_TO_SWAP_START_MIN = 0.000001 ether;
    uint256 public constant DEFAULT_AMOUNT_TO_SWAP_START_MAX = 100000 ether;
    uint256 public constant DEFAULT_INITIAL_DEPOSIT = 40 ether;

    function test_Quoter_WETHToOETHb() public {
        // Someone mint 100 OETHb
        deal(address(oethb), address(this), 100 ether);

        // Deposit 100 WETH and 100 OETHb between -10 and 10
        //provideLiquidity(100 ether, 100 ether, -10, 10, true);

        // We allocate WETH to strategy
        allocateAndRebalance(amountOfWETHToSwapToReachPrice(true), 0, true);
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

    function amountOfWETHToSwapToReachPrice(bool display) public returns (uint256) {
        (uint160 priceBefore,,,,,) = pool.slot0();
        uint160 targetPrice = getTargetPrice();

        (uint256 amountToSwap, uint160 priceAfter, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachPrice(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: true,
                targetPrice: targetPrice,
                sqrtPriceLimitX96: DEFAULT_PRICE_LIMITE_LOW,
                minAmount: DEFAULT_AMOUNT_TO_SWAP_START_MIN,
                maxAmount: DEFAULT_AMOUNT_TO_SWAP_START_MAX,
                allowedVariance: DEFAULT_VARIANCE,
                maxIterations: DEFAULT_MAX_ITERATIONS
            })
        );

        if (display) {
            uint256 deviance = (max(targetPrice, priceAfter) - min(targetPrice, priceAfter)) * 1e18 / targetPrice;
            console.log("PriceBefore: ", priceBefore);
            console.log("TargetPrice: ", targetPrice);
            console.log("PriceAfter : ", priceAfter);
            console.log("deviance: %18e", deviance);
            console.log("Amount to swap: %18e", amountToSwap);
            console.log("Iterations: ", iterations);
        }

        return amountToSwap;
    }

    function amountOfOETHbToSwapToReachPrice(bool display) public returns (uint256) {
        (uint160 priceBefore,,,,,) = pool.slot0();
        uint160 targetPrice = getTargetPrice();

        (uint256 amountToSwap, uint160 priceAfter, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachPrice(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: false,
                targetPrice: targetPrice,
                sqrtPriceLimitX96: DEFAULT_PRICE_LIMITE_HIGH,
                minAmount: DEFAULT_AMOUNT_TO_SWAP_START_MIN,
                maxAmount: DEFAULT_AMOUNT_TO_SWAP_START_MAX,
                allowedVariance: DEFAULT_VARIANCE,
                maxIterations: DEFAULT_MAX_ITERATIONS
            })
        );

        if (display) {
            uint256 deviance = (max(targetPrice, priceAfter) - min(targetPrice, priceAfter)) * 1e27 / targetPrice;
            console.log("PriceBefore: ", priceBefore);
            console.log("TargetPrice: ", targetPrice);
            console.log("PriceAfter : ", priceAfter);
            console.log("deviance: ", deviance);
            console.log("Amount to swap: %18e", amountToSwap);
            console.log("Iterations: ", iterations);
        }

        return amountToSwap;
    }

    function amountOfWETHToSwapToReachPriceBeforeRebalance() public returns (uint256) {
        //vm.startPrank(strategy.governor());
        (uint256 amount, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachTargetPriceBeforeRebalance(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: true,
                targetPrice: 0, // Not needed here
                sqrtPriceLimitX96: 0, // Not needed here
                minAmount: 0.0000000001 ether,
                maxAmount: 1 ether,
                allowedVariance: 0, // Not needed here
                maxIterations: 50
            })
        );
        console.log("Amount to swap: %18e", amount);
        console.log("Iterations: ", iterations);
        return (amount);
    }

    function amountOfOETHbToSwapToReachPriceBeforeRebalance() public returns (uint256) {
        //vm.startPrank(strategy.governor());
        (uint256 amount, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachTargetPriceBeforeRebalance(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: false,
                targetPrice: 0, // Not needed here
                sqrtPriceLimitX96: 0, // Not needed here
                minAmount: 0.00001 ether,
                maxAmount: 0.005 ether,
                allowedVariance: 0, // Not needed here
                maxIterations: 20
            })
        );
        console.log("Amount to swap: %18e", amount);
        console.log("Iterations: ", iterations);
        return (amount);
    }

    //00.002700217571139457
    function getTargetPrice() public view returns (uint160) {
        uint256 share = strategy.poolWethShare();
        return (
            TickMath.getSqrtRatioAtTick(-1) * share.toUint160()
                + TickMath.getSqrtRatioAtTick(0) * (1e18 - share).toUint160()
        ) / 1e18;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

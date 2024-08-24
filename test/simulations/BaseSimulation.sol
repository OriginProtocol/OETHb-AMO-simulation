// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {stdJson} from "lib/forge-std/src/StdJson.sol";
import {console} from "lib/forge-std/src/console.sol";

import {SafeCastLib} from "@solady/utils/SafeCastLib.sol";

import {TickMath} from "test/libraries/TickMath.sol";

import {Base_AMO_Actions_} from "test/AMOActions.sol";
import {Base_Pool_Actions_} from "test/PoolActions.sol";

import {BinarySearchQuoter} from "test/utils/BinarySearchQuoter.sol";
import {Exporter} from "test/utils/Exporter.sol";

abstract contract Base_Simulations_ is Base_AMO_Actions_, Base_Pool_Actions_ {
    using SafeCastLib for uint256;
    using stdJson for string;
    using Exporter for string;

    string public name;
    string public jsonName;
    string[] public inputsNames;
    string[] public outputsNames;
    uint256[][] public inputValues;

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

    ////////////////////////////////////////////////////////////////
    /// --- MODIFIERS
    ////////////////////////////////////////////////////////////////
    modifier revertStateAfter() {
        uint256 id = vm.snapshot();
        _;
        require(vm.revertToAndDelete(id), "RevertToAndDelete failed");
    }

    ////////////////////////////////////////////////////////////////
    /// --- INITIALIZATION
    ////////////////////////////////////////////////////////////////
    function init(string memory _jsonName) internal {
        jsonName = _jsonName;
        // Path to JSON file
        string memory pathToJson =
            string(abi.encodePacked(vm.projectRoot(), "/test/simulations/inputs/", jsonName, ".json"));

        // Read whole JSON file
        string memory json = vm.readFile(pathToJson);

        // Fetch simulation name
        name = json.readString("$.name");

        // Fecth inputs names
        inputsNames = json.readStringArray("$.inputs_names");

        // Fetch inputs values
        inputValues = new uint256[][](inputsNames.length);
        for (uint256 i = 0; i < inputsNames.length; i++) {
            inputValues[i] = json.readUintArray(string(abi.encodePacked("$.inputs.", string(inputsNames[i]))));
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Export result from the simulation and revert the state to before the simulation
    function _simulateAndExport(uint256[] memory params) internal revertStateAfter {
        name.exportSimulation(inputsNames, inputValues, params, outputsNames, _simulation(params));
    }

    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256[] memory params) internal virtual returns (uint256[] memory) {
        // To be implemented in the child contract
    }

    ////////////////////////////////////////////////////////////////
    /// --- HELPER FUNCTIONS
    ////////////////////////////////////////////////////////////////
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
        // Snapshot the current state, as next call will modify it
        uint256 id = vm.snapshot();

        // Get the amount of OETHb to swap to reach target price before rebalance
        // This will perform the effective rebalance, state needs to be reverted after!
        (uint256 amount, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachTargetPriceBeforeRebalance(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: true,
                targetPrice: 0, // Not needed here
                sqrtPriceLimitX96: 0, // Not needed here
                minAmount: DEFAULT_AMOUNT_TO_SWAP_START_MIN,
                maxAmount: DEFAULT_AMOUNT_TO_SWAP_START_MAX,
                allowedVariance: 0, // Not needed here
                maxIterations: 50
            })
        );
        // Revert to the previous state
        require(vm.revertToAndDelete(id), "RevertToAndDelete failed");

        console.log("Amount to swap: %18e", amount);
        console.log("Iterations: ", iterations);
        return (amount);
    }

    function amountOfOETHbToSwapToReachPriceBeforeRebalance() public returns (uint256) {
        // Snapshot the current state, as next call will modify it
        uint256 id = vm.snapshot();

        // Get the amount of OETHb to swap to reach target price before rebalance
        // This will perform the effective rebalance, state needs to be reverted after!
        (uint256 amount, uint256 iterations) = BinarySearchQuoter.amountToSwapToReachTargetPriceBeforeRebalance(
            BinarySearchQuoter.BinarySearchQuoterParams({
                swapWETHForOETHB: false,
                targetPrice: 0, // Not needed here
                sqrtPriceLimitX96: 0, // Not needed here
                minAmount: DEFAULT_AMOUNT_TO_SWAP_START_MIN,
                maxAmount: DEFAULT_AMOUNT_TO_SWAP_START_MAX,
                allowedVariance: 0, // Not needed here
                maxIterations: 50
            })
        );

        // Revert to the previous state
        require(vm.revertToAndDelete(id), "RevertToAndDelete failed");
        console.log("Amount to swap: %18e", amount);
        console.log("Iterations: ", iterations);
        return (amount);
    }

    function getTargetPrice() public view returns (uint160) {
        uint256 share = strategy.poolWethShare();
        return (
            TickMath.getSqrtRatioAtTick(-1) * share.toUint160()
                + TickMath.getSqrtRatioAtTick(0) * (1e18 - share).toUint160()
        ) / 1e18;
    }

    ////////////////////////////////////////////////////////////////
    /// --- MATH FUNCTIONS
    ////////////////////////////////////////////////////////////////
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
}

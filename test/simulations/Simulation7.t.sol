// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {console} from "lib/forge-std/src/console.sol";
import {SafeCastLib} from "lib/solady/src/utils/SafeCastLib.sol";

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

import {TickMath} from "test/libraries/TickMath.sol";

contract Simulation7 is Base_Simulations_ {
    using SafeCastLib for uint256;

    uint256 private constant AMOUT_TO_SWAP_TO_PUSH_PRICE = 1_000_000_000 ether;
    uint256 private constant DEVIANCE_BEFORE_REBALANCE = 0; // 0%
    uint256 private constant DEVIANCE_AFTER_REBALANCE = 1e12; // 0.0001%
    uint256 private constant DEFAULT_POOL_SHARE = 0.2 ether;
    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////

    constructor() {
        name = "Simulation7";
        inputsNames = new string[](1);
        inputsNames[0] = "Price";

        // Replace inputs in the JSON file
        // Path to JSON file
        string memory pathToJson =
            string(abi.encodePacked(vm.projectRoot(), "/test/simulations/inputs/", name, ".json"));

        // In this simulation, the JSON is created manually
        string[] memory inputsNames = new string[](1);
        inputsNames[0] = "Price";

        string memory obj1 = "some key";
        vm.serializeString(obj1, "name", "Simulation7");
        vm.serializeString(obj1, "inputs_names", inputsNames);

        string memory obj2 = "some other key";
        string memory output = vm.serializeUint(obj2, "Price", getPrecisePrice());
        string memory finalJson = vm.serializeString(obj1, "inputs", output);
        vm.writeJson(finalJson, pathToJson);

        outputsNames = new string[](2);
        outputsNames[0] = "TotalSupplyAfter";
        outputsNames[1] = "VaultBalanceAfter";

        // Set inputs
        inputValues = new uint256[][](1);
        inputValues[0] = getPrecisePrice();
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation7A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            uint256[] memory location = new uint256[](1);
            location[0] = inputValues[0][i]; // Price to rebalance from

            _simulateAndExport(location);
        }
    }

    function _simulation(uint256[] memory params) internal override returns (uint256[] memory) {
        // Get inputs params
        require(params.length == 1, "Invalid params length");
        uint160 priceToRebalanceFrom = uint160(params[0]); // Use safecast
        uint256 targetPrice = getTargetPrice();
        console.log("TargetPrice: ", targetPrice);
        console.log("PriceToRebalanceFrom: ", priceToRebalanceFrom);

        // Set up initial state and balance pool.
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(DEFAULT_POOL_SHARE);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);
        (uint160 price,,,,,) = pool.slot0();
        assertApproxEqRel(
            price, targetPrice, DEVIANCE_AFTER_REBALANCE, "Price after rebalance is not the same as target price, 1"
        );

        // Provide liquidity between ticks around price where we want to rebalance from
        int24 lowerTargetTick = sugarHelper.getTickAtSqrtRatio(priceToRebalanceFrom);
        int24 upperTargetTick = lowerTargetTick + 1;
        provideLiquidity(DEFAULT_INITIAL_DEPOSIT, DEFAULT_INITIAL_DEPOSIT, lowerTargetTick, upperTargetTick, true);

        // Swap to push price to targeted price
        if (price > priceToRebalanceFrom) {
            // As priceToRebalanceFrom represent the price at the lower tick, but in this case the lower tick is more "on the left" than the upper tick
            // Pushing the price to the lower tick will ensure that we will have to rebalance from a price that have liquidity above.
            swapWETHExactInput(AMOUT_TO_SWAP_TO_PUSH_PRICE, priceToRebalanceFrom, true);
            (price,,,,,) = pool.slot0();
            // Ensure the price has been pushed enough on the left side.
            assertLe(price, priceToRebalanceFrom, "Price after swap is not lower than the price to rebalance from");
        } else if (price < priceToRebalanceFrom) {
            // As priceToRebalanceFrom represent the price at the lower tick, to be the pass price the liquidity
            // We should use the price at the tick above, to ensure we will have to rebalance from a price that have liquidity below.
            // Otherwise there is not a lot of interest to do it, as we will jut loose money from swap fees.
            uint160 abovePrice = TickMath.getSqrtRatioAtTick(TickMath.getTickAtSqrtRatio(priceToRebalanceFrom) + 1);
            swapOETHbExactInput(AMOUT_TO_SWAP_TO_PUSH_PRICE, abovePrice, true);
            (price,,,,,) = pool.slot0();
            // Ensure the price has been pushed enough on the right side.
            assertGt(price, priceToRebalanceFrom, "Price after swap is not greater than the price to rebalance from");
        }

        if (price < targetPrice) {
            // Try to rebalance, need to sell OETHb to push the price up
            rebalance(amountOfOETHbToSwapToReachPriceBeforeRebalance(), 0, false);
        } else if (price > targetPrice) {
            // Try to rebalance, need to sell WETH to push the price down
            rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);
        }
        (price,,,,,) = pool.slot0();
        // Check that rebalance has been done correctly, however it is already ensured by the smart contract.
        assertApproxEqRel(
            price,
            getTargetPrice(),
            DEVIANCE_AFTER_REBALANCE,
            "Price after rebalance is not the same as price to rebalance from, 2"
        );


        withdrawAll();

        // Return outputs
        uint256[] memory results = new uint256[](2);
        results[0] = oethb.totalSupply();
        results[1] = vault.totalValue();

        return results;
    }

    /// TODO: To better, this is a nightmare.
    function getPrecisePrice() public pure returns (uint256[] memory) {
        uint256[] memory ticks = new uint256[](49);

        ticks[0] = TickMath.getSqrtRatioAtTick(-100_000);
        ticks[1] = TickMath.getSqrtRatioAtTick(-50_000);
        ticks[2] = TickMath.getSqrtRatioAtTick(-20_000);
        ticks[3] = TickMath.getSqrtRatioAtTick(-10_000);
        ticks[4] = TickMath.getSqrtRatioAtTick(-5_000);
        ticks[5] = TickMath.getSqrtRatioAtTick(-2_000);
        ticks[6] = TickMath.getSqrtRatioAtTick(-1_000);
        ticks[7] = TickMath.getSqrtRatioAtTick(-500);
        ticks[8] = TickMath.getSqrtRatioAtTick(-100);
        ticks[9] = TickMath.getSqrtRatioAtTick(-50);
        ticks[10] = TickMath.getSqrtRatioAtTick(-10);
        ticks[11] = TickMath.getSqrtRatioAtTick(-5);
        ticks[12] = TickMath.getSqrtRatioAtTick(-2);
        ticks[13] = TickMath.getSqrtRatioAtTick(-1);
        ticks[14] = getPrecisePriceWithShare(-1, 0, 0.9 ether);
        ticks[15] = getPrecisePriceWithShare(-1, 0, 0.8 ether);
        ticks[16] = getPrecisePriceWithShare(-1, 0, 0.7 ether);
        ticks[17] = getPrecisePriceWithShare(-1, 0, 0.6 ether);
        ticks[18] = getPrecisePriceWithShare(-1, 0, 0.5 ether);
        ticks[19] = getPrecisePriceWithShare(-1, 0, 0.4 ether);
        ticks[20] = getPrecisePriceWithShare(-1, 0, 0.3 ether);
        ticks[21] = getPrecisePriceWithShare(-1, 0, 0.2 ether);
        ticks[22] = getPrecisePriceWithShare(-1, 0, 0.1 ether);
        ticks[23] = TickMath.getSqrtRatioAtTick(0);
        ticks[24] = getPrecisePriceWithShare(0, 1, 0.9 ether);
        ticks[25] = getPrecisePriceWithShare(0, 1, 0.8 ether);
        ticks[26] = getPrecisePriceWithShare(0, 1, 0.7 ether);
        ticks[27] = getPrecisePriceWithShare(0, 1, 0.6 ether);
        ticks[28] = getPrecisePriceWithShare(0, 1, 0.5 ether);
        ticks[29] = getPrecisePriceWithShare(0, 1, 0.4 ether);
        ticks[30] = getPrecisePriceWithShare(0, 1, 0.3 ether);
        ticks[31] = getPrecisePriceWithShare(0, 1, 0.2 ether);
        ticks[32] = getPrecisePriceWithShare(0, 1, 0.1 ether);
        ticks[33] = TickMath.getSqrtRatioAtTick(1);
        ticks[34] = TickMath.getSqrtRatioAtTick(2);
        ticks[35] = TickMath.getSqrtRatioAtTick(5);
        ticks[36] = TickMath.getSqrtRatioAtTick(10);
        ticks[37] = TickMath.getSqrtRatioAtTick(20);
        ticks[38] = TickMath.getSqrtRatioAtTick(50);
        ticks[39] = TickMath.getSqrtRatioAtTick(100);
        ticks[40] = TickMath.getSqrtRatioAtTick(200);
        ticks[41] = TickMath.getSqrtRatioAtTick(500);
        ticks[42] = TickMath.getSqrtRatioAtTick(1_000);
        ticks[43] = TickMath.getSqrtRatioAtTick(2_000);
        ticks[44] = TickMath.getSqrtRatioAtTick(5_000);
        ticks[45] = TickMath.getSqrtRatioAtTick(10_000);
        ticks[46] = TickMath.getSqrtRatioAtTick(20_000);
        ticks[47] = TickMath.getSqrtRatioAtTick(50_000);
        ticks[48] = TickMath.getSqrtRatioAtTick(100_000);

        return ticks;
    }

    /// @notice Calculate the price between two ticks.
    /// For example: lowerTick = -1, upperTick = 0, percentage = 0.5 ether
    /// This will return the price in the middle of the two ticks. 
    /// @dev This is not 100% exact!!! But it should be enough for testing.
    /// Using, lowerTick = -1, upperTick = 0, percentage = 0.2 ether
    /// Could mean that we want to price using the tick 0.2, even if this doesn't exist
    /// This allow more granularity in the price.
    function getPrecisePriceWithShare(int24 lowerTick, int24 upperTick, uint256 percentage)
        public
        pure
        returns (uint160)
    {
        return (
            TickMath.getSqrtRatioAtTick(lowerTick) * percentage.toUint160()
                + TickMath.getSqrtRatioAtTick(upperTick) * (1 ether - percentage).toUint160()
        ) / 1 ether;
    }
}

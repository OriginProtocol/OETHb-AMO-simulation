// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {console} from "lib/forge-std/src/console.sol";

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation5A is Base_Simulations_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation5A";

    constructor() {
        inputs = new string[](3);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";
        inputs[2] = "Ticks";

        values = new uint256[][](3);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 0.2 ether;
        values[0][1] = 0.1 ether;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether; // Less than initial liquidity deposited
        values[1][1] = 1500 ether; // More than initial liquidity deposited
        values[2] = new uint256[](4); // Ticks %
        values[2][0] = 1;
        values[2][1] = 10;
        values[2][2] = 100;
        values[2][3] = 1_000;

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation5A_1_() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5A_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5A_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5A_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5A_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5A_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5A_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5A_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5A_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5A_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5A_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5A_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5A_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5A_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5A_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5A_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1], int24(int256(params[2])));

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, int24 ticks) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(ratio);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Provide Liquiditity outside of current ticks
        provideLiquidity(DEFAULT_INITIAL_DEPOSIT, DEFAULT_INITIAL_DEPOSIT, -ticks - 1, -ticks, true);

        // Buy OETHb to push price down
        swapWETHExactInput(amount, DEFAULT_PRICE_LIMITE_LOW, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance, need to sell OETHb to push the price up
        rebalance(amountOfOETHbToSwapToReachPriceBeforeRebalance(), 0, false);
        withdrawAll();

        // Check values after
        uint256 balanceAfter = vault.totalValue();
        uint256 totalSupplyAfter = oethb.totalSupply();

        uint256[] memory results = new uint256[](4);
        //results[0] = totalSupplyBefore;
        //results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }
}

contract Simulation5B is Base_Simulations_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation5B";

    constructor() {
        inputs = new string[](3);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";
        inputs[2] = "Ticks";

        values = new uint256[][](3);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 0.2 ether;
        values[0][1] = 0.1 ether;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether; // Less than initial liquidity deposited
        values[1][1] = 40 ether; // More than initial liquidity deposited
        values[2] = new uint256[](4); // Ticks %
        values[2][0] = 1;
        values[2][1] = 10;
        values[2][2] = 100;
        values[2][3] = 1_000;

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation5B_1_() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5B_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5B_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5B_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5B_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5B_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5B_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5B_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5B_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5B_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5B_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5B_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation5B_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation5B_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation5B_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation5B_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1], int24(int256(params[2])));

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, int24 ticks) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(ratio);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Provide Liquiditity outside of current ticks
        provideLiquidity(DEFAULT_INITIAL_DEPOSIT, DEFAULT_INITIAL_DEPOSIT, ticks, ticks + 1, true);

        // Sell OETHb to move price in higher ticks
        (uint160 priceBefore,,,,,) = pool.slot0();
        swapOETHbExactInput(amount, DEFAULT_PRICE_LIMITE_HIGH, true);
        (uint160 priceAfter,,,,,) = pool.slot0();
        console.log("Price Before AAAA: %d", priceBefore);
        console.log("Price After AAAAA: %d", priceAfter);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance, need to buy OETHb to reach the price
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);
        withdrawAll();

        // Check values after
        uint256 balanceAfter = vault.totalValue();
        uint256 totalSupplyAfter = oethb.totalSupply();

        uint256[] memory results = new uint256[](4);
        //results[0] = totalSupplyBefore;
        //results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }
}

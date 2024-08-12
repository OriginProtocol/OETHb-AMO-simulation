// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
//import {console} from "lib/forge-std/src/console.sol";

//import {TickMath} from "test/libraries/TickMath.sol";

//import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

//
import {Base_Test_} from "test/Base.sol";

import {Exporter} from "test/utils/Exporter.sol";

contract Simulation1 is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation1";

    constructor() {
        inputs = new string[](2);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";

        values = new uint256[][](2);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 8e17;
        values[0][1] = 9e17;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 10 ether;
        values[1][1] = 20 ether;

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation1_1() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][0]; // Amounts

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1]);

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation1_2() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][1]; // Amounts

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1]);

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation1_3() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][0]; // Amounts

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1]);

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation1_4() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][1]; // Amounts

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1]);

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount) internal returns (uint256[] memory) {
        initialize(ratio);
        deal(address(token1), address(this), amount);
        vault.deposit(amount, address(this));

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        strategy.depositInPool(amount);
        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = token0.totalSupply();

        uint256[] memory results = new uint256[](4);
        results[0] = totalSupplyBefore;
        results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }
}

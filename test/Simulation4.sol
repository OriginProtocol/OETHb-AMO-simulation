// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Test_} from "test/Base.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation4A is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation4A";

    constructor() {
        inputs = new string[](3);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";
        inputs[2] = "Rebalance Percentage";

        values = new uint256[][](3);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 8e17;
        values[0][1] = 9e17;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 10 ether;
        values[1][1] = 15 ether;
        values[2] = new uint256[](4); // Rebalance %
        values[2][0] = 75e16;
        values[2][1] = 80e16;
        values[2][2] = 95e16;
        values[2][3] = 99e16;

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation3_1() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, uint256 rebalancePercentage)
        internal
        returns (uint256[] memory)
    {
        initialize(ratio);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Buy OETHb to move a bit the price
        _buyOETHb(amount);

        // Try to rebalance
        strategy.rebalance(rebalancePercentage);

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

contract Simulation4B is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation4B";

    constructor() {
        inputs = new string[](3);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";
        inputs[2] = "Rebalance Percentage";

        values = new uint256[][](3);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 8e17;
        values[0][1] = 9e17;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 10 ether;
        values[1][1] = 15 ether;
        values[2] = new uint256[](4); // Rebalance %
        values[2][0] = 75e16;
        values[2][1] = 80e16;
        values[2][2] = 95e16;
        values[2][3] = 99e16;

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation3_1() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function test_Simulation3_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        uint256[] memory results = new uint256[](4);
        results = _simulation(location[0], location[1], location[2]); // Add SafeCast

        name.exportSimulation1(inputs, values, location, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, uint256 rebalancePercentage)
        internal
        returns (uint256[] memory)
    {
        initialize(ratio);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Buy OETHb to move a bit the price
        _dumpOETHb(amount);

        // Try to rebalance
        strategy.rebalance(rebalancePercentage);

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

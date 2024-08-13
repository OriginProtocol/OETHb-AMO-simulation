// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Test_} from "test/Base.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation5A is Base_Test_ {
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
        values[0][0] = 8e17;
        values[0][1] = 9e17;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 70 ether; // Less than initial liquidity deposited
        values[1][1] = 90 ether; // More than initial liquidity deposited
        values[2] = new uint256[](4); // Ticks %
        values[2][0] = 1;
        values[2][1] = 10;
        values[2][2] = 1_000;
        values[2][3] = 10_000;

        outputs = new string[](5);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
        outputs[4] = "WETHDebt";
    }

    function test_Simulation5A_1() public {
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
        initialize(ratio);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Provide Liquiditity outside of current ticks
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, ticks, ticks + 1);

        // Try to push price in new ticks
        _buyOETHb(amount);

        // Try to rebalance
        strategy.rebalance(99e16);

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = token0.totalSupply();

        uint256[] memory results = new uint256[](5);
        results[0] = totalSupplyBefore;
        results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;
        results[4] = vault.wethDebt();

        // Return values
        return results;
    }
}

contract Simulation5B is Base_Test_ {
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
        values[0][0] = 8e17;
        values[0][1] = 9e17;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 15 ether; // Less than initial liquidity deposited
        values[1][1] = 25 ether; // More than initial liquidity deposited
        values[2] = new uint256[](4); // Rebalance %
        values[2][0] = 1;
        values[2][1] = 10;
        values[2][2] = 1_000;
        values[2][3] = 10_000;

        outputs = new string[](5);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
        outputs[4] = "WETHDebt";
    }

    function test_Simulation5B_1() public {
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
        initialize(ratio);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Provide Liquiditity outside of current ticks
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, -ticks - 1, -ticks);

        // Try to push price in new ticks
        _dumpOETHb(amount);

        // Try to rebalance
        strategy.rebalance(99e16);

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = token0.totalSupply();

        uint256[] memory results = new uint256[](5);
        results[0] = totalSupplyBefore;
        results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;
        results[4] = vault.wethDebt();

        // Return values
        return results;
    }
}

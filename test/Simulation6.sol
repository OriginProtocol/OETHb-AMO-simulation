// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Test_} from "test/Base.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation6A is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation6A";

    constructor() {
        inputs = new string[](3);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";
        inputs[2] = "Ticks";

        values = new uint256[][](3);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether; // Less than initial liquidity deposited
        values[1][1] = 50 ether; // More than initial liquidity deposited
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

    function test_Simulation6A_1_() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation6A_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation6A_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation6A_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation6A_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation6A_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation6A_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation6A_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation6A_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation6A_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation6A_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation6A_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation6A_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation6A_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation6A_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation6A_16() public {
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
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Provide Liquiditity outside of current ticks
        _provideLiquidity(1, DEFAULT_LIQUIDITY_DEPOSIT, -ticks - 1, -ticks);

        // Push price to new ticks, but buying 10% more than the initial liquidity deposited.
        _buyOETHb(DEFAULT_LIQUIDITY_DEPOSIT * (ratio * 110 / 100) / 1e9, -ticks - 1);

        // Provide WETH liquidity between ticks 0 and 1.
        _provideLiquidity(amount, 1, 0, 1);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance
        strategy.rebalance();
        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
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

/*
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
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 5 ether; // Less than initial liquidity deposited
        values[1][1] = 9 ether; // More than initial liquidity deposited
        values[2] = new uint256[](4); // Rebalance %
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
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Provide Liquiditity outside of current ticks
        _provideLiquidity(DEFAULT_LIQUIDITY_DEPOSIT, 1, ticks, ticks + 1);

        // Try to push price in new ticks
        _sellOETHb(amount, ticks + 1);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance
        strategy.rebalance();
        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
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
*/

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
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Swap Amounts
        values[1][0] = 20 ether;
        values[1][1] = 50 ether;
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

    function test_Simulation4A_1_() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4A_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4A_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4A_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4A_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4A_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4A_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4A_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4A_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4A_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4A_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4A_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4A_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4A_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4A_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4A_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1], params[2]);

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, uint256 rebalancePercentage)
        internal
        returns (uint256[] memory)
    {
        initialize(ratio);
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Buy OETHb to move a bit the price
        _buyOETHb(amount, -1);

        // Check values before
        uint256 totalSupplyBefore = oethb.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance
        strategy.rebalance(rebalancePercentage);

        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = oethb.totalSupply();

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
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 5 ether;
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

    function test_Simulation4B_1_() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4B_2() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4B_3() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4B_4() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4B_5() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4B_6() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4B_7() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4B_8() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][0];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4B_9() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4B_10() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4B_11() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4B_12() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][0];
        location[2] = values[2][3];

        _simulate(location);
    }

    function test_Simulation4B_13() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][0];

        _simulate(location);
    }

    function test_Simulation4B_14() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][1];

        _simulate(location);
    }

    function test_Simulation4B_15() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][2];

        _simulate(location);
    }

    function test_Simulation4B_16() public {
        uint256[] memory location = new uint256[](3);
        location[0] = values[0][1];
        location[1] = values[1][1];
        location[2] = values[2][3];

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1], params[2]);

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount, uint256 rebalancePercentage)
        internal
        returns (uint256[] memory)
    {
        initialize(ratio);
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Buy OETHb to move a bit the price
        _sellOETHb(amount, 1);

        // Check values before
        uint256 totalSupplyBefore = oethb.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance
        strategy.rebalance(rebalancePercentage);

        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = oethb.totalSupply();

        uint256[] memory results = new uint256[](4);
        results[0] = totalSupplyBefore;
        results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }
}

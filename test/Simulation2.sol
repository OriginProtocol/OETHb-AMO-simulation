// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Test_} from "test/Base.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation2A is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation2A";

    constructor() {
        inputs = new string[](2);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";

        values = new uint256[][](2);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether; // Less than initial liquidity deposited (40 ether)
        values[1][1] = 50 ether; // More than initial liquidity deposited (40 ether)

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation2A_1() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][0]; // Amounts

        _simulate(location);
    }

    function test_Simulation2A_2() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][1]; // Amounts

        _simulate(location);
    }

    function test_Simulation2A_3() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][0]; // Amounts

        _simulate(location);
    }

    function test_Simulation2A_4() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][1]; // Amounts

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1]);

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount) internal returns (uint256[] memory) {
        initialize(ratio);
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        pool.slot0();
        _buyOETHb(amount, 0);
        pool.slot0();

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

contract Simulation2B is Base_Test_ {
    using Exporter for string;

    // Input parameters
    string[] public inputs;
    uint256[][] public values;
    string[] public outputs;

    string name = "Simulation2B";

    constructor() {
        inputs = new string[](2);
        inputs[0] = "Ratio";
        inputs[1] = "Amount";

        values = new uint256[][](2);
        values[0] = new uint256[](2); // Ratios
        values[0][0] = 400e7;
        values[0][1] = 410e7;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 5 ether; // Less than initial liquidity deposited (10 ether)
        values[1][1] = 15 ether; // More than initial liquidity deposited (10 ether)

        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation2B_1() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][0]; // Amounts

        _simulate(location);
    }

    function test_Simulation2B_2() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][0]; // Ratios
        location[1] = values[1][1]; // Amounts

        _simulate(location);
    }

    function test_Simulation2B_3() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][0]; // Amounts

        _simulate(location);
    }

    function test_Simulation2B_4() public {
        uint256[] memory location = new uint256[](2);
        location[0] = values[0][1]; // Ratios
        location[1] = values[1][1]; // Amounts

        _simulate(location);
    }

    function _simulate(uint256[] memory params) public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(params[0], params[1]);

        name.exportSimulation1(inputs, values, params, outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount) internal returns (uint256[] memory) {
        initialize(ratio);
        deal(address(weth), address(this), DEFAULT_LIQUIDITY_DEPOSIT);
        vault.deposit(DEFAULT_LIQUIDITY_DEPOSIT, address(this));
        strategy.depositInPool(DEFAULT_LIQUIDITY_DEPOSIT);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        pool.slot0();
        _sellOETHb(amount, 1);

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

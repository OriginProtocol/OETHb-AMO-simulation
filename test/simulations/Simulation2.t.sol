// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation2A is Base_Simulations_ {
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
        values[0][0] = 0.2 ether;
        values[0][1] = 0.1 ether;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether;
        values[1][1] = 50 ether;

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

    function _simulation(uint256 share, uint256 amount) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();

        uint256 id = vm.snapshot();
        uint256 amount_ = amountOfWETHToSwapToReachPriceBeforeRebalance();
        vm.revertToAndDelete(id);
        rebalance(amount_, 0, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        swapWETHExactInput(amount, DEFAULT_PRICE_LIMITE_LOW, true);

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

contract Simulation2B is Base_Simulations_ {
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
        values[0][0] = 0.2 ether;
        values[0][1] = 0.1 ether;
        values[1] = new uint256[](2); // Amounts
        values[1][0] = 20 ether;
        values[1][1] = 50 ether;

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

    function _simulation(uint256 share, uint256 amount) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();

        uint256 id = vm.snapshot();
        uint256 amount_ = amountOfWETHToSwapToReachPriceBeforeRebalance();
        vm.revertToAndDelete(id);

        rebalance(amount_, 0, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        swapOETHbExactInput(amount, DEFAULT_PRICE_LIMITE_HIGH, true);

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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation2A is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation2A");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation2A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                uint256[] memory simulationParams = new uint256[](2);
                simulationParams[0] = inputValues[0][i]; // Ratios
                simulationParams[1] = inputValues[1][j]; // Amounts

                _simulateAndExport(simulationParams);
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256[] memory params) internal override returns (uint256[] memory) {
        require(params.length == 2, "Invalid params length");
        uint256 share = params[0];
        uint256 amount = params[1];

        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

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

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation2B");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation2B() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                uint256[] memory simulationParams = new uint256[](2);
                simulationParams[0] = inputValues[0][i]; // Ratios
                simulationParams[1] = inputValues[1][j]; // Amounts

                _simulateAndExport(simulationParams);
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256[] memory params) internal override returns (uint256[] memory) {
        require(params.length == 2, "Invalid params length");
        uint256 share = params[0];
        uint256 amount = params[1];

        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

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

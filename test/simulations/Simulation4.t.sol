// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation4A is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation4A");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation4A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                for (uint256 k = 0; k < inputValues[2].length; k++) {
                    uint256[] memory simulationParams = new uint256[](3);
                    simulationParams[0] = inputValues[0][i]; // Ratios
                    simulationParams[1] = inputValues[1][j]; // Amounts
                    simulationParams[2] = inputValues[2][k]; // Rebalance %

                    _simulateAndExport(simulationParams);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256[] memory params) internal override returns (uint256[] memory) {
        require(params.length == 3, "Invalid params length");
        uint256 share = params[0];
        uint256 amount = params[1];
        //uint256 rebalancePercent = params[2]; // not used

        deal(address(oethb), address(this), amount);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

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

contract Simulation4B is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation4B");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation4B() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                for (uint256 k = 0; k < inputValues[2].length; k++) {
                    uint256[] memory simulationParams = new uint256[](3);
                    simulationParams[0] = inputValues[0][i]; // Ratios
                    simulationParams[1] = inputValues[1][j]; // Amounts
                    simulationParams[2] = inputValues[2][k]; // Rebalance %

                    _simulateAndExport(simulationParams);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256[] memory params) internal override returns (uint256[] memory) {
        require(params.length == 3, "Invalid params length");
        uint256 share = params[0];
        uint256 amount = params[1];
        //uint256 rebalancePercent = params[2]; // not used

        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Sell OETHb to move a bit the price
        swapOETHbExactInput(amount, DEFAULT_PRICE_LIMITE_HIGH, true);

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

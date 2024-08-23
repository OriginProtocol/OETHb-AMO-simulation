// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation3A is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation3A");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation3A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                for (uint256 k = 0; k < inputValues[2].length; k++) {
                    uint256[] memory simulationParams = new uint256[](3);
                    simulationParams[0] = inputValues[0][i]; // Ratios
                    simulationParams[1] = inputValues[1][j]; // Amounts
                    simulationParams[2] = inputValues[2][k]; // Ticks

                    _simulateAndExport(simulationParams);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256 share, uint256 amount, int24 ticks) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        provideLiquidity(amount, amount, ticks, ticks + 1, true);
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

    /// @notice Export result from the simulation and revert the state to before the simulation
    function _simulateAndExport(uint256[] memory params) public revertStateAfter {
        name.exportSimulation(
            inputsNames, inputValues, params, outputsNames, _simulation(params[0], params[1], int24(int256(params[2])))
        );
    }
}

contract Simulation3B is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation3B");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation3A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                for (uint256 k = 0; k < inputValues[2].length; k++) {
                    uint256[] memory simulationParams = new uint256[](3);
                    simulationParams[0] = inputValues[0][i]; // Ratios
                    simulationParams[1] = inputValues[1][j]; // Amounts
                    simulationParams[2] = inputValues[2][k]; // Ticks

                    _simulateAndExport(simulationParams);
                }
            }
        }
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice Simulation function, this is where all the scenario is executed
    function _simulation(uint256 share, uint256 amount, int24 ticks) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        provideLiquidity(amount, amount, -ticks - 1, -ticks, true);
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

    /// @notice Export result from the simulation and revert the state to before the simulation
    function _simulateAndExport(uint256[] memory params) public revertStateAfter {
        name.exportSimulation(
            inputsNames, inputValues, params, outputsNames, _simulation(params[0], params[1], int24(int256(params[2])))
        );
    }
}

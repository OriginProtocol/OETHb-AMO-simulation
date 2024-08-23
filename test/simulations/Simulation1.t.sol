// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation1 is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation1");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation1() public {
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
    function _simulation(uint256 share, uint256 amount) internal returns (uint256[] memory) {
        deal(address(oethb), address(this), amount);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        withdrawAll();

        // Check values after
        uint256 balanceAfter = vault.totalValue();
        uint256 totalSupplyAfter = oethb.totalSupply();

        uint256[] memory results = new uint256[](outputsNames.length);
        //results[0] = totalSupplyBefore;
        //results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }

    /// @notice Export result from the simulation and revert the state to before the simulation
    function _simulateAndExport(uint256[] memory params) internal revertStateAfter {
        name.exportSimulation(inputsNames, inputValues, params, outputsNames, _simulation(params[0], params[1]));
    }
}

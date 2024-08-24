// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base for simulation
import {Base_Simulations_} from "test/simulations/BaseSimulation.sol";

// Export data
import {Exporter} from "test/utils/Exporter.sol";

contract Simulation6A is Base_Simulations_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTRUCTOR
    ////////////////////////////////////////////////////////////////
    constructor() {
        init("Simulation6A");

        outputsNames = new string[](4);
        outputsNames[0] = "TotalSupplyBefore";
        outputsNames[1] = "VaultBalanceBefore";
        outputsNames[2] = "TotalSupplyAfter";
        outputsNames[3] = "VaultBalanceAfter";
    }

    ////////////////////////////////////////////////////////////////
    /// --- TESTS
    ////////////////////////////////////////////////////////////////
    function test_Simulation6A() public {
        for (uint256 i = 0; i < inputValues[0].length; i++) {
            for (uint256 j = 0; j < inputValues[1].length; j++) {
                for (uint256 k = 0; k < inputValues[2].length; k++) {
                    uint256[] memory location = new uint256[](3);
                    location[0] = inputValues[0][i]; // Ratios
                    location[1] = inputValues[1][j]; // Amounts
                    location[2] = inputValues[2][k]; // Ticks

                    _simulateAndExport(location);
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
        int24 ticks = int24(int256(params[2]));

        deal(address(oethb), address(this), DEFAULT_INITIAL_DEPOSIT);
        setPoolWethShare(share);
        allocate();
        rebalance(amountOfWETHToSwapToReachPriceBeforeRebalance(), 0, true);

        // Provide Liquiditity outside of current ticks
        provideLiquidity(DEFAULT_INITIAL_DEPOSIT, DEFAULT_INITIAL_DEPOSIT, -ticks - 1, -ticks, true);

        // Push price to new ticks
        swapWETHExactInput(DEFAULT_INITIAL_DEPOSIT, DEFAULT_PRICE_LIMITE_LOW, true);

        // Provide WETH liquidity between ticks -1 and 0.
        provideLiquidity(amount, amount, DEFAULT_LOWER_TICK, DEFAULT_UPPER_TICK, true);

        // Check values before
        // uint256 totalSupplyBefore = oethb.totalSupply();
        // uint256 balanceBefore = vault.checkBalance();

        // Try to rebalance, need to buy OETHb to reach the price
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
//import {console} from "lib/forge-std/src/console.sol";

//import {TickMath} from "test/libraries/TickMath.sol";

//import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

//
import {Base_Test_} from "test/Base.sol";

import {Exporter} from "test/utils/ExporterV2.sol";

contract SimulatorV2 is Base_Test_ {
    // Input parameters
    uint256[] public ratios;
    uint256[] public amounts;

    constructor() {
        ratios = new uint256[](2);
        amounts = new uint256[](2);
        ratios[0] = 80e16;
        ratios[1] = 90e16;
        amounts[0] = 20 ether;
        amounts[1] = 50 ether;
    }

    function test_Simulation_Ratio1_Amount1() public {
        (uint256 totalSupplyBefore, uint256 balanceBefore, uint256 totalSupplyAfter, uint256 balanceAfter) =
            _simulation(ratios[0], amounts[0]);
        Exporter.exportSimulation1(
            ratios, amounts, ratios[0], amounts[0], totalSupplyBefore, balanceBefore, balanceAfter, totalSupplyAfter
        );
    }

    function test_Simulation_Ratio1_Amount2() public {
        (uint256 totalSupplyBefore, uint256 balanceBefore, uint256 totalSupplyAfter, uint256 balanceAfter) =
            _simulation(ratios[0], amounts[1]);
        Exporter.exportSimulation1(
            ratios, amounts, ratios[0], amounts[1], totalSupplyBefore, balanceBefore, balanceAfter, totalSupplyAfter
        );
    }

    function test_Simulation_Ratio2_Amount1() public {
        (uint256 totalSupplyBefore, uint256 balanceBefore, uint256 totalSupplyAfter, uint256 balanceAfter) =
            _simulation(ratios[1], amounts[0]);
        Exporter.exportSimulation1(
            ratios, amounts, ratios[1], amounts[0], totalSupplyBefore, balanceBefore, balanceAfter, totalSupplyAfter
        );
    }

    function test_Simulation_Ratio2_Amount2() public {
        (uint256 totalSupplyBefore, uint256 balanceBefore, uint256 totalSupplyAfter, uint256 balanceAfter) =
            _simulation(ratios[1], amounts[1]);
        Exporter.exportSimulation1(
            ratios, amounts, ratios[1], amounts[1], totalSupplyBefore, balanceBefore, balanceAfter, totalSupplyAfter
        );
    }

    function test_Simulation_Ratio3_Amount2() public {
        (uint256 totalSupplyBefore, uint256 balanceBefore, uint256 totalSupplyAfter, uint256 balanceAfter) =
            _simulation(ratios[2], amounts[1]);
        Exporter.exportSimulation1(
            ratios, amounts, ratios[2], amounts[1], totalSupplyBefore, balanceBefore, balanceAfter, totalSupplyAfter
        );
    }

    function _simulation(uint256 ratio, uint256 amount) internal returns (uint256, uint256, uint256, uint256) {
        initialize(ratio);
        deal(address(token1), address(this), amount);
        vault.deposit(amount, address(this));

        // Check values before
        uint256 totalSupplyBefore = token1.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        strategy.depositInPool(amount);
        strategy.withdrawAllFromPool();

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = token1.totalSupply();

        // Return values
        return (totalSupplyBefore, balanceBefore, totalSupplyAfter, balanceAfter);
    }
}

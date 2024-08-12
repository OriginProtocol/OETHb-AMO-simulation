// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
//import {console} from "lib/forge-std/src/console.sol";

//import {TickMath} from "test/libraries/TickMath.sol";

//import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

//
import {Base_Test_} from "test/Base.sol";

import {Exporter} from "test/utils/Exporter.sol";

contract Simulation4A is Base_Test_ {
    using Exporter for string;

    // Input parameters
    uint256[] public ratios;
    uint256[] public amounts;
    string[] public outputs;

    string name = "Simulation4A";

    constructor() {
        ratios = new uint256[](2);
        amounts = new uint256[](2);
        ratios[0] = 80e16;
        ratios[1] = 90e16;
        amounts[0] = 20 ether;
        amounts[1] = 50 ether;
        outputs = new string[](4);
        outputs[0] = "TotalSupplyBefore";
        outputs[1] = "VaultBalanceBefore";
        outputs[2] = "TotalSupplyAfter";
        outputs[3] = "VaultBalanceAfter";
    }

    function test_Simulation4_1() public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(ratios[0], amounts[0]);
        name.exportSimulation1(ratios, amounts, ratios[0], amounts[0], outputs, results);
    }

    function test_Simulation4_2() public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(ratios[0], amounts[1]);
        name.exportSimulation1(ratios, amounts, ratios[0], amounts[1], outputs, results);
    }

    function test_Simulation4_3() public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(ratios[1], amounts[0]);
        name.exportSimulation1(ratios, amounts, ratios[1], amounts[0], outputs, results);
    }

    function test_Simulation4_4() public {
        uint256[] memory results = new uint256[](4);
        results = _simulation(ratios[1], amounts[1]);
        name.exportSimulation1(ratios, amounts, ratios[1], amounts[1], outputs, results);
    }

    function _simulation(uint256 ratio, uint256 amount) internal returns (uint256[] memory) {
        initialize(ratio);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));

        // Check values before
        uint256 totalSupplyBefore = token0.totalSupply();
        uint256 balanceBefore = vault.checkBalance();

        deal(address(token1), address(this), amount);
        _provideLiquidity(1, amount, 1, 2);

        // Check values after
        uint256 balanceAfter = vault.checkBalance();
        uint256 totalSupplyAfter = token0.totalSupply();

        uint256[] memory results = new uint256[](4);
        results[0] = totalSupplyBefore;
        results[1] = balanceBefore;
        results[2] = totalSupplyAfter;
        results[3] = balanceAfter;

        // Return values
        return results;
    }
}

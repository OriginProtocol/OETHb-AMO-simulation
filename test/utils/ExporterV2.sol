// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Vm} from "lib/contracts/lib/forge-std/src/Vm.sol";
import {stdJson} from "lib/contracts/lib/forge-std/src/StdJson.sol";

library Exporter {
    using stdJson for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function exportSimulation1(
        uint256[] memory ratios,
        uint256[] memory amounts,
        uint256 ratio,
        uint256 amount,
        uint256 totalSupplyBefore,
        uint256 balanceBefore,
        uint256 balanceAfter,
        uint256 totalSupplyAfter
    ) public {
        string[] memory calldataPython = new string[](11);
        calldataPython[0] = "python3";
        calldataPython[1] = string(abi.encodePacked(vm.projectRoot(), "/test/python/simulation_1V2.py"));
        calldataPython[2] = string(abi.encodePacked(vm.projectRoot(), "/data/simulation_1V2.json"));
        calldataPython[3] = vm.toString(abi.encode(ratios));
        calldataPython[4] = vm.toString(abi.encode(amounts));
        calldataPython[5] = vm.toString(abi.encode(ratio));
        calldataPython[6] = vm.toString(abi.encode(amount));
        calldataPython[7] = vm.toString(abi.encode(totalSupplyBefore));
        calldataPython[8] = vm.toString(abi.encode(balanceBefore));
        calldataPython[9] = vm.toString(abi.encode(balanceAfter));
        calldataPython[10] = vm.toString(abi.encode(totalSupplyAfter));

        vm.ffi(calldataPython);
    }
}

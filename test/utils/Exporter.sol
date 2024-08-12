// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Vm} from "lib/contracts/lib/forge-std/src/Vm.sol";
import {stdJson} from "lib/contracts/lib/forge-std/src/StdJson.sol";

library Exporter {
    using stdJson for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function exportSimulation1(
        string memory name,
        uint256[] memory ratios,
        uint256[] memory amounts,
        uint256 ratio,
        uint256 amount,
        string[] memory outputs,
        uint256[] memory results
    ) public {
        string[] memory calldataPython = new string[](9);
        calldataPython[0] = "python3";
        calldataPython[1] = string(abi.encodePacked(vm.projectRoot(), "/test/python/json_builder.py"));
        calldataPython[2] = string(abi.encodePacked(vm.projectRoot(), "/data/", name, ".json"));
        calldataPython[3] = vm.toString(abi.encode(ratios));
        calldataPython[4] = vm.toString(abi.encode(amounts));
        calldataPython[5] = vm.toString(abi.encode(ratio));
        calldataPython[6] = vm.toString(abi.encode(amount));
        calldataPython[7] = vm.toString(abi.encode(outputs));
        calldataPython[8] = vm.toString(abi.encode(results));

        vm.ffi(calldataPython);
    }
}

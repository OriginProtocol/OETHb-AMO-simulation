// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Vm} from "lib/contracts/lib/forge-std/src/Vm.sol";
import {stdJson} from "lib/contracts/lib/forge-std/src/StdJson.sol";

library Exporter {
    using stdJson for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function exportSimulation1(
        string memory name, // JSON file name
        string[] memory inputs, // List of string corresponding to the inputs name
        uint256[][] memory params, // List containing list of value for each input
        uint256[] memory location, // Location in the json
        string[] memory outputs, // List of string corresponding to the outputs name
        uint256[] memory results // List containing the value for each output
    ) public {
        string[] memory calldataPython = new string[](8);
        calldataPython[0] = "python3";
        calldataPython[1] = string(abi.encodePacked(vm.projectRoot(), "/test/python/json_builder.py"));
        calldataPython[2] = string(abi.encodePacked(vm.projectRoot(), "/data/", name, ".json"));
        calldataPython[3] = vm.toString(abi.encode(inputs));
        calldataPython[4] = vm.toString(abi.encode(params));
        calldataPython[5] = vm.toString(abi.encode(location));
        calldataPython[6] = vm.toString(abi.encode(outputs));
        calldataPython[7] = vm.toString(abi.encode(results));

        vm.ffi(calldataPython);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Vm} from "lib/contracts/lib/forge-std/src/Vm.sol";
import {stdJson} from "lib/contracts/lib/forge-std/src/StdJson.sol";

library Exporter {
    using stdJson for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    event log_named_uint(string name, uint256 value);

    function exportSimulation1(
        string memory path,
        string memory name,
        uint256[] memory ratios,
        uint256[][] memory amounts,
        uint256[][] memory checkBalances
    ) public {
        string[] memory calldataPython = new string[](6);
        calldataPython[0] = "python3";
        calldataPython[1] = string(abi.encodePacked(vm.projectRoot(), "/test/python/simulation_1.py"));
        calldataPython[2] = string(abi.encodePacked(path, name));
        calldataPython[3] = vm.toString(abi.encode(ratios));
        calldataPython[4] = vm.toString(abi.encode(amounts));
        calldataPython[5] = vm.toString(abi.encode(checkBalances));

        vm.ffi(calldataPython);
    }
}

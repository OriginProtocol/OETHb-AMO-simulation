// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {Vm} from "forge-std/Vm.sol";

// Solmate
import {ERC20} from "@solmate/tokens/ERC20.sol";

// Aerodrome
import {ICLPool} from "test/interfaces/ICLPool.sol";

library Python {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    /// @notice Return the price of the pool in WAD using python call
    function getPriceWAD(ICLPool pool) public returns (uint256) {
        (uint160 sqrtPriceX96,,,,,) = pool.slot0();

        string[] memory calldataPython = new string[](6);
        calldataPython[0] = "python3";
        calldataPython[1] = string(abi.encodePacked(vm.projectRoot(), "/test/python/price.py"));
        calldataPython[2] = vm.toString(sqrtPriceX96);
        calldataPython[3] = vm.toString(ERC20(pool.token0()).decimals());
        calldataPython[4] = vm.toString(ERC20(pool.token1()).decimals());
        calldataPython[5] = vm.toString(uint256(1e18));

        return abi.decode(vm.ffi(calldataPython), (uint256));
    }
}

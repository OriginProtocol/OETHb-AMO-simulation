// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base test
import {Base_Test_} from "test/Base.sol";

abstract contract Base_AMO_Actions_ is Base_Test_ {
    function allocate() public {
        vault.allocate();
    }

    function rebalance(uint256 _amountToSwap, uint256 _minTokenReceived, bool _swapWeth) public {
        vm.prank(strategy.governor());
        strategy.rebalance(_amountToSwap, _minTokenReceived, _swapWeth);
    }

    function allocateAndRebalance(uint256 _amountToSwap, uint256 _minTokenReceived, bool _swapWeth) public {
        allocate();
        rebalance(_amountToSwap, _minTokenReceived, _swapWeth);
    }
}

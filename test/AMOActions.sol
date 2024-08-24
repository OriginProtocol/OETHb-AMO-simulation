// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Base test
import {Base_Test_} from "test/Base.sol";

abstract contract Base_AMO_Actions_ is Base_Test_ {
    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS
    ////////////////////////////////////////////////////////////////
    uint256 public constant DEVIANCE_FROM_TARGET_SHARE = 5; // %


    ////////////////////////////////////////////////////////////////
    /// --- VAULT ACTIONS
    ////////////////////////////////////////////////////////////////
    function allocate() public {
        vault.allocate();
    }


    ////////////////////////////////////////////////////////////////
    /// --- STRATEGY ACTIONS
    ////////////////////////////////////////////////////////////////
    function rebalance(uint256 _amountToSwap, uint256 _minTokenReceived, bool _swapWeth) public {
        vm.prank(strategy.governor());
        strategy.rebalance(_amountToSwap, _swapWeth, _minTokenReceived);
    }

    function allocateAndRebalance(uint256 _amountToSwap, uint256 _minTokenReceived, bool _swapWeth) public {
        allocate();
        rebalance(_amountToSwap, _minTokenReceived, _swapWeth);
    }

    function withdrawAll() public {
        vm.prank(vault.governor());
        vault.withdrawAllFromStrategy(address(strategy));
    }

    /// @notice Set the `allowedWethShareStart` and `allowedWethShareEnd` as a percentage of the pool's WETH share
    function setPoolWethShare(uint256 share) public {
        uint256 _allowedWethShareStart = share * (100 - DEVIANCE_FROM_TARGET_SHARE) / 100;
        uint256 _allowedWethShareEnd = share * (100 + DEVIANCE_FROM_TARGET_SHARE) / 100;
        setAllowedPoolWethShareInterval(_allowedWethShareStart, _allowedWethShareEnd);
    }

    function setAllowedPoolWethShareInterval(uint256 _allowedWethShareStart, uint256 _allowedWethShareEnd) public {
        vm.prank(strategy.governor());
        strategy.setAllowedPoolWethShareInterval(_allowedWethShareStart, _allowedWethShareEnd);
    }
}

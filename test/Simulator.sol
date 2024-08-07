// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {console} from "lib/forge-std/src/console.sol";

import {Base_Test_} from "test/Base.sol";

contract Simulator is Base_Test_ {
    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice First simulation, very simple.
    /// Give 20 WETH to AMO
    /// The AMO mint enough OETHb, deposit both in pool and remove all liquidity
    /// Check balance of WETH at the end
    function test_simulation1() public {
        deal(address(token1), address(amo), 20 ether);
        amo.depositInitialLiquidity(20 ether);
        amo.removeAllLiquidity();
        console.log("Balance: %e", amo.checkBalance());
    }
}

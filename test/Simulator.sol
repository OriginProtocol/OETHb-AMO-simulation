// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {console} from "lib/forge-std/src/console.sol";

// Solmate
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

// Aerodrome
import {ICLPool} from "test/interfaces/ICLPool.sol";

// Internal utils
import {Python} from "test/utils/Python.sol";

// Internal for testing
import {Actions} from "test/Actions.sol";

contract Simulator is Actions {
    using FixedPointMathLib for uint256;
    using Python for ICLPool;

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    function test1() public {
        addLiquidityAndStake(
            DEFAULT_AMOUNT.mulWadDown(liquidityRatio), DEFAULT_AMOUNT.mulWadDown(1e18 - liquidityRatio)
        );

        deal(address(token0), address(this), 10 ether);
        deal(address(token1), address(this), 10 ether);
        console.log("Price Before:\t %e", pool.getPriceWAD());
        swap(address(token0), 1 ether);
        console.log("Price After:\t %e", pool.getPriceWAD());
    }
}

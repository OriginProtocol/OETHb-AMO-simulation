// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Solmate
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

// Internal for testing
import {Actions} from "test/Actions.sol";

contract Simulator is Actions {
    using FixedPointMathLib for uint256;

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
        //console.log("Balance before pool token0: %e", token0.balanceOf(address(pool)));
        //console.log("Balance before pool token1: %e", token1.balanceOf(address(pool)));
        addLiquidityAndStake(
            DEFAULT_AMOUNT.mulWadDown(liquidityRatio), DEFAULT_AMOUNT.mulWadDown(1e18 - liquidityRatio)
        );
        //console.log("Balance after pool token0: %e", token0.balanceOf(address(pool)));
        //console.log("Balance after pool token1: %e", token1.balanceOf(address(pool)));

        deal(address(token0), address(this), 10 ether);
        deal(address(token1), address(this), 10 ether);
        //console.log("BalanceBefore: %e", token0.balanceOf(address(this)));
        //console.log("BalanceBefore: %e", token1.balanceOf(address(this)));
        swap(address(token0), 1 ether);
        //console.log("BalanceAfter: %e", token0.balanceOf(address(this)));
        //console.log("BalanceAfter: %e", token1.balanceOf(address(this)));
    }
}

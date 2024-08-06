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

        console.log("Liquidity:\t %e", pool.liquidity());
        deal(address(token0), address(this), 100 ether);
        console.log("Price Before:\t %e", pool.getPriceWAD());
        swap(address(token0), 10 ether);
        console.log("Price After:\t %e", pool.getPriceWAD());
    }

    // Try to distribute rewards
    function test2() public {
        addLiquidityAndStake(80 ether, 20 ether);
        deal(address(token0), address(this), 100 ether);
        swap(address(token0), 10 ether);
        distributeReward(1000 ether);

        console.log("Balance Before:\t %s \t AERO", AERO.balanceOf(address(this)));
        claimRewards();
        console.log("Balance After:\t %s \t AERO", AERO.balanceOf(address(this)) / 1 ether);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {console} from "lib/forge-std/src/console.sol";

//
import {TickMath} from "test/libraries/TickMath.sol";

//
import {Base_Test_} from "test/Base.sol";

contract Simulator is Base_Test_ {
    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
        token1.approve(address(vault), type(uint256).max);
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice First simulation, very simple.
    /// Give 20 WETH to AMO
    /// The AMO mint enough OETHb, deposit both in pool and remove all liquidity
    /// Check balance of WETH at the end
    function test_Simulation1() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
    }

    function test_Simulation2A() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        _buyOETHb(10 ether);
        console.log("Balance: %e", vault.checkBalance());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
    }

    function test_Simulation2B() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        _dumpOETH(10 ether);
        console.log("Balance: %e", vault.checkBalance());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
    }

    function _dumpOETH(uint256 amount) internal {
        // Give user WETH
        deal(address(token1), address(this), amount);
        // User approve vault to take WETH
        token1.approve(address(vault), amount);
        // User mint OETHb against WETH
        vault.deposit(amount, address(this));
        // User swap OETHb for WETH in the pool
        pool.swap({
            recipient: address(this),
            zeroForOne: true,
            amountSpecified: int256(amount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-1),
            data: ""
        });
    }

    function _buyOETHb(uint256 amount) internal {
        // Give user a bit more WETH
        deal(address(token1), address(this), amount);
        // User swap WETH for OETHb in the pool
        pool.swap({
            recipient: address(this),
            zeroForOne: false,
            amountSpecified: -int256(amount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(1),
            data: ""
        });
    }
}

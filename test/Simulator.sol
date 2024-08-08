// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {console} from "lib/forge-std/src/console.sol";

//
import {TickMath} from "test/libraries/TickMath.sol";

import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

//
import {Base_Test_} from "test/Base.sol";

contract Simulator is Base_Test_ {
    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
        token1.approve(address(vault), type(uint256).max);
        token1.approve(address(nftManager), type(uint256).max);
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
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    /// @notice Second simulation, same as before + a user swap WETH for OETHb
    function test_Simulation2A() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        _buyOETHb(10 ether);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    /// @notice Second simulation, same as before + a user swap OETHb for WETH
    function test_Simulation2B() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        _dumpOETH(10 ether);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    /// @notice Third simulation, same as Simulation1, but other user provide liquidity outside of current tick
    function test_Simulation4() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, 1, 2);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    function test_Simulation4B() public {
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, -1, 0);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
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
        deal(address(token1), address(this), amount * 101 / 100);
        // User swap WETH for OETHb in the pool
        pool.swap({
            recipient: address(this),
            zeroForOne: false,
            amountSpecified: -int256(amount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(1),
            data: ""
        });
    }

    /// Note: weird issue of amountDesired shouldn't be 0 even if it's not used, for example deposit full outside of current tick.
    function _provideLiquidity(uint256 amount0, uint256 amount1, int24 tickLower, int24 tickUpper)
        internal
        returns (uint256 tokenId, uint128 liquidity, uint256 _amount0, uint256 _amount1)
    {
        return nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(token0),
                token1: address(token1),
                tickSpacing: 1,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );
    }
}

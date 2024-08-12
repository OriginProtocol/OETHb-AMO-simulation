// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {console} from "lib/forge-std/src/console.sol";

//
import {TickMath} from "test/libraries/TickMath.sol";

import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

//
import {Base_Test_} from "test/Base.sol";

import {Exporter} from "test/utils/Exporter.sol";

contract Simulator is Base_Test_ {
    using Exporter for string;

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    /// @notice First simulation, very simple.
    /// Give 20 WETH to AMO
    /// The AMO mint enough OETHb, deposit both in pool and remove all liquidity
    /// Check balance of WETH at the end
    function test_Simulation1() public {
        initialize(8e17);
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
        initialize(8e17);
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
        initialize(8e17);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        console.log("Balance: %e", vault.checkBalance());
        _dumpOETHb(10 ether);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    /// @notice Third simulation, same as Simulation1, but other user provide liquidity outside of current tick
    /// In between tick 1 and 2, above current tick
    function test_Simulation4() public {
        initialize(8e17);
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

    /// @notice Third simulation, same as Simulation1, but other user provide liquidity outside of current tick
    /// In between tick -1 and 0, below current tick
    function test_Simulation4B() public {
        initialize(8e17);
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);
        deal(address(token1), address(this), 10 ether * 101 / 100);
        vault.deposit(10 ether, address(this));

        _provideLiquidity(10 ether, 1, -1, 0);
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
        strategy.withdrawAllFromPool();
        console.log("Balance: %e", vault.checkBalance());
        console.log("TotalSupply: %e", token0.totalSupply());
    }

    function test_Simulation5A() public {
        initialize(8e17);
        // Deposit initial liquidity
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Buy OETHb to move a bit the price
        _buyOETHb(10 ether);

        // Try to rebalance
        console.log("Balance: %18e", vault.checkBalance());
        (uint256 amount0, uint256 amount1) = strategy.prepareRebalance(99e16); // 99%
        strategy.finalizeRebalance(amount0, amount1);
        console.log("Balance: %18e", vault.checkBalance());
    }

    function test_Simulation5B() public {
        initialize(8e17);
        // Deposit initial liquidity
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Buy OETHb to move a bit the price
        _dumpOETHb(10 ether);

        // Try to rebalance
        console.log("Balance: %18e", vault.checkBalance());
        (uint256 amount0, uint256 amount1) = strategy.prepareRebalance(50e16); // 99%
        strategy.finalizeRebalance(amount0, amount1);
        console.log("Balance: %18e", vault.checkBalance());
    }

    function test_Simulation6A() public {
        initialize(8e17);
        // Deposit initial liquidity
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Provide Liquiditity between tick 1 and 2
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, 1, 2);

        // Buy OETHb to move price between tick 1 and 2
        console.log("Before swap");
        pool.slot0();
        _buyOETHb(85 ether);

        // Try to rebalance
        console.log("After swap");
        pool.slot0();
        console.log("Balance: %18e", vault.checkBalance());
        (uint256 amount0, uint256 amount1) = strategy.prepareRebalance(99e16); // 99%
        strategy.finalizeRebalance(amount0, amount1);
        console.log("Balance: %18e", vault.checkBalance());
    }

    function test_Simulation6B() public {
        initialize(8e17);
        // Deposit initial liquidity
        deal(address(token1), address(this), 20 ether);
        vault.deposit(20 ether, address(this));
        strategy.depositInPool(20 ether);

        // Provide Liquiditity between tick 1 and 2
        deal(address(token1), address(this), 10 ether);
        _provideLiquidity(1, 10 ether, -1, 0);

        // Buy OETHb to move price between tick 1 and 2
        console.log("Before swap");
        pool.slot0();
        _dumpOETHb(25 ether);

        // Try to rebalance
        console.log("After swap");
        pool.slot0();
        console.log("Balance: %18e", vault.checkBalance());
        (uint256 amount0, uint256 amount1) = strategy.prepareRebalance(99e16); // 99%
        strategy.finalizeRebalance(amount0, amount1);
        console.log("Balance: %18e", vault.checkBalance());
    }

    function _dumpOETHb(uint256 amount) internal {
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

    function test_Exporter() public {
        uint256[] memory ratios = new uint256[](2);
        ratios[0] = 1e17;
        ratios[1] = 2e17;
        // 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000016345785defbfbd000000000000000000000000000000000000000000000000000002c68aefbfbd1400000000000000000000000000000000000000000000000000000000000000

        uint256[][] memory amounts = new uint256[][](2);
        amounts[0] = new uint256[](2);
        amounts[0][0] = 3 ether;
        amounts[0][1] = 4 ether;
        amounts[1] = new uint256[](2);
        amounts[1][0] = 5 ether;
        amounts[1][1] = 6 ether;
        // 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000efbfbd000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000029efbfbd241aefbfbd2c000000000000000000000000000000000000000000000000000037efbfbdefbfbdce9defbfbd000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000004563efbfbdefbfbd44efbfbd000000000000000000000000000000000000000000000000000053444835efbfbd580000000000000000000000000000

        uint256[][] memory checkBalances = new uint256[][](2);
        checkBalances[0] = new uint256[](2);
        checkBalances[0][0] = 7 ether;
        checkBalances[0][1] = 8 ether;
        checkBalances[1] = new uint256[](2);
        checkBalances[1][0] = 9 ether;
        checkBalances[1][1] = 0 ether;
        // 0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000efbfbd00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000006124efbfbde993bc00000000000000000000000000000000000000000000000000006f05efbfbdefbfbd3b20000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000007cefbfbd6c50efbfbd0000000000000000000000000000000000000000000000000000efbfbdefbfbd2304efbfbdefbfbd000000000000000000000000000000

        path.exportSimulation1("Example2", ratios, amounts, checkBalances);
    }
}

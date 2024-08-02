// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {Test, console} from "forge-std/Test.sol";

// Solmate
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

// Aerodrome
import {IVoter} from "test/interfaces/IVoter.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ICLGauge} from "test/interfaces/ICLGauge.sol";
import {ICLPoolFactory} from "test/interfaces/ICLPoolFactory.sol";
import {ICLGaugeFactory} from "test/interfaces/ICLGaugeFactory.sol";
import {IFactoryRegistry} from "test/interfaces/IFactoryRegistry.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Internal utils
import {Base} from "test/utils/Addresses.sol";
import {TickMath} from "test/libraries/TickMath.sol";

/*
contract Simulator is Test {
    using FixedPointMathLib for uint256;

    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    bool public constant ENABLE_GAUGE_AT_CREATION = true;
    int24 public constant TICK_SPACING = 1;
    uint256 public constant DEFAULT_AMOUNT = 100 ether;
    uint160 public immutable INITIAL_SQRTPRICEX96 = TickMath.getSqrtRatioAtTick(0);

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    ERC20 public token0; // OETHb
    ERC20 public token1; // WETH
    ERC20 public rewardToken;

    IVoter public voter;
    ICLPool public pool;
    ICLGauge public gauge;
    ICLPoolFactory public poolFactory;
    ICLGaugeFactory public gaugeFactory;
    IFactoryRegistry public factoryRegistry;
    INonfungiblePositionManager public nftManager;

    uint256 public ratio = 8e17; // 80% OETHb, 20% WETH

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public {
        token1 = ERC20(new MockERC20("Wrapped ETH", "WETH", 18));
        token0 = ERC20(new MockERC20("Origin ETH Base", "OETHb", 18));
        rewardToken = ERC20(new MockERC20("Reward Token", "RT", 18));
        voter = IVoter(Base.AERODROME_VOTER);
        poolFactory = ICLPoolFactory(Base.CLPOOL_FACTORY);
        factoryRegistry = IFactoryRegistry(Base.FACTORY_REGISTRY);
        nftManager = INonfungiblePositionManager(payable(Base.NFT_POSITION_MANAGER));

        // Ensure token0 is less than token1, otherwise it will fail when compute pool address
        require(token0 < token1, "Token0 must be less than Token1");

        // Create fork
        vm.createSelectFork("base", 17906760);

        // Create pool with token0 and token1
        pool = ICLPool(
            poolFactory.createPool({
                tokenA: address(token0),
                tokenB: address(token1),
                tickSpacing: TICK_SPACING,
                sqrtPriceX96: INITIAL_SQRTPRICEX96
            })
        );

        // Approve contracts to max
        token0.approve(address(pool), type(uint256).max);
        token1.approve(address(pool), type(uint256).max);
        token0.approve(address(nftManager), type(uint256).max);
        token1.approve(address(nftManager), type(uint256).max);

        /*
        // Label all addresses
        vm.label(address(token0), "Token0");
        vm.label(address(token1), "Token1");
        vm.label(address(rewardToken), "Reward Token");
        vm.label(address(pool), "CLPool T0/T1");
        vm.label(address(poolFactory), "CLFactory");
        vm.label(Base.CLPOOL_IMPL, "CLPool Implementation");
        vm.label(address(nftManager), "NFT Position Manager");
        //vm.label(address(gauge), "Gauge T0/T1");
        vm.label(Base.CLGAUGE_IMPL, "CLGauge Implementation");
        vm.label(address(gaugeFactory), "CLGaugeFactory");
        vm.label(Base.FACTORY_REGISTRY, "Factory Registry");
        vm.label(Base.AERODROME_VOTER, "Aerodrome Voter");
        vm.label(address(factoryRegistry), "Factory Registry");
        vm.label(address(voter), "Voter");

        (, address gaugeFactory_) = factoryRegistry.factoriesToPoolFactory(address(poolFactory));
        gaugeFactory = ICLGaugeFactory(gaugeFactory_);
        // Add a gauge to the pool
        if (ENABLE_GAUGE_AT_CREATION) enableGauge();
    }

    function test() public {
        (uint256 tokenId,) = addLiquidity(DEFAULT_AMOUNT.mulWadDown(ratio), DEFAULT_AMOUNT.mulWadDown(1e18 - ratio));
        stake(tokenId);
        //swap(address(token0), 10 ether);
    }

    /*
    ////////////////////////////////////////////////////////////////
    /// --- ACTIONS
    ////////////////////////////////////////////////////////////////
    function addLiquidity(uint256 amount0, uint256 amount1) public returns (uint256, uint128) {
        deal(address(token0), address(this), amount0);
        deal(address(token1), address(this), amount1);

        // Add liquidity
        (uint256 tokenId, uint128 liquidity,,) = nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(token0),
                token1: address(token1),
                tickSpacing: 1,
                tickLower: 0,
                tickUpper: 1,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );

        return (tokenId, liquidity);
    }

    function stake(uint256 tokenId) public {
        gauge.deposit(tokenId);
    }

    function swap(address tokenIn, uint256 amountIn) public {
        deal(tokenIn, address(this), amountIn);

        bool zeroForOne = tokenIn == address(token0);
        int256 amountSpecified = zeroForOne ? int256(amountIn) : -int256(amountIn);
        uint160 sqrtPriceLimitX96 = zeroForOne ? TickMath.getSqrtRatioAtTick(-100) : TickMath.getSqrtRatioAtTick(100);

        // Swap
        pool.swap({
            recipient: address(this),
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96,
            data: ""
        });
    }

    function enableGauge() public {
        vm.prank(Base.AERODROME_VOTER);
        voter.createGauge(address(poolFactory), address(pool));

        gauge = ICLGauge(
            payable(
                gaugeFactory.createGauge({
                    _forwarder: address(0), // not used
                    _pool: _pool,
                    _feesVotingReward: address(0),
                    _rewardToken: _rewardToken,
                    _isPool: false // seems to be only for old config
                })
            )
        );
    }

    ////////////////////////////////////////////////////////////////
    /// --- CALLBACK
    ////////////////////////////////////////////////////////////////
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {}
}*/

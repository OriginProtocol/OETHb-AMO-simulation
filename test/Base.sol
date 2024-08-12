// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {Test} from "forge-std/Test.sol";

// Solmate
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

// Aerodrome
import {IVoter} from "test/interfaces/IVoter.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ICLGauge} from "test/interfaces/ICLGauge.sol";
import {ICLPoolFactory} from "test/interfaces/ICLPoolFactory.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Internal utils
import {Base} from "test/utils/Addresses.sol";
import {TickMath} from "test/libraries/TickMath.sol";

// Contracts
import {Vault} from "src/Vault.sol";
import {StrategyAMO} from "src/StrategyAMO.sol";

abstract contract Base_Test_ is Test {
    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    int24 public constant LOWER_TICK = 0;
    int24 public constant UPPER_TICK = 1;
    int24 public constant TICK_SPACING = 1;

    ERC20 public immutable AERO = ERC20(Base.AERO);
    IVoter public immutable voter = IVoter(Base.VOTER);
    ICLPoolFactory public immutable poolFactory = ICLPoolFactory(Base.CLPOOL_FACTORY);

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    ERC20 public token0; // OETHb
    ERC20 public token1; // WETH
    ERC20 public rewardToken;
    Vault public vault;
    StrategyAMO public strategy;

    ICLPool public pool;
    ICLGauge public gauge;
    INonfungiblePositionManager public nftManager;

    string public path;

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual {
        // 1. Create fork
        vm.createSelectFork("base", 17906760);

        // 2. Create Tokens
        token1 = ERC20(new MockERC20("Wrapped ETH", "WETH", 18));
        token0 = ERC20(new MockERC20("Origin ETH Base", "OETHb", 18));
        rewardToken = ERC20(new MockERC20("Reward Token", "RT", 18));
        require(address(token0) < address(token1), "Token0 must be less than Token1");
        // Note: if previous require fails, swap deployment order between token0 and token1.

        // 3. Whitelist token0 and token1 in Voter: Not needed anymore
        vm.startPrank(Base.GOV_VOTER);
        voter.whitelistToken(address(token0), true);
        voter.whitelistToken(address(token1), true);
        vm.stopPrank();

        path = string(abi.encodePacked(vm.projectRoot(), "/data/"));
        if (!vm.isDir(path)) {
            vm.createDir(string(abi.encodePacked(vm.projectRoot(), "/data/")), false);
        }
    }

    function initialize(uint256 ratio) public {
        // 1. Create Pool
        pool = ICLPool(
            poolFactory.createPool({
                tokenA: address(token0),
                tokenB: address(token1),
                tickSpacing: TICK_SPACING,
                sqrtPriceX96: getInitialPriceWithRatio(ratio)
            })
        );

        // 2. Create Gauge and get NFT Manager
        gauge = ICLGauge(payable(voter.createGauge(address(poolFactory), address(pool))));
        nftManager = INonfungiblePositionManager(payable(pool.nft()));

        // Deploy StrategyAMO and Vault
        strategy = new StrategyAMO(nftManager, pool, token0, token1, ratio);
        vault = new Vault(token0, token1, ratio, strategy);
        strategy.setVault(vault);

        // Approvals
        token0.approve(address(nftManager), type(uint256).max);
        token1.approve(address(nftManager), type(uint256).max);
        token1.approve(address(vault), type(uint256).max);
        nftManager.setApprovalForAll(address(gauge), true);

        // Label
        vm.label(address(token1), "WETH");
        vm.label(address(token0), "OETHb");
        vm.label(address(strategy), "StrategyAMO");
        vm.label(address(nftManager), "NFTManager");
        vm.label(address(pool), "CLPool OETHb/WETH");
        vm.label(address(gauge), "CLGauge OETHb/WETH");
    }

    function getInitialPriceWithRatio(uint256 ratio) public pure returns (uint160) {
        return (
            TickMath.getSqrtRatioAtTick(0) * uint160(ratio) + TickMath.getSqrtRatioAtTick(1) * uint160(1e18 - ratio)
        ) / 1e18;
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        if (amount0Delta > 0) token0.transfer(address(pool), uint256(amount0Delta));
        else if (amount1Delta > 0) token1.transfer(address(pool), uint256(amount1Delta));
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

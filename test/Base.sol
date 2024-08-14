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
    int24 public constant DEFAULT_MAX_TICK = 1_000;
    uint256 public constant DEFAULT_LIQUIDITY_DEPOSIT = 10 ether;

    ERC20 public immutable AERO = ERC20(Base.AERO);
    IVoter public immutable voter = IVoter(Base.VOTER);
    ICLPoolFactory public immutable poolFactory = ICLPoolFactory(Base.CLPOOL_FACTORY);

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    ERC20 public weth;
    ERC20 public oethb; // WETH
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
        vm.createSelectFork("base", 18000000);

        // 2. Create Tokens
        weth = ERC20(Base.WETH);
        oethb = ERC20(Base.OETHB);
        require(address(weth) < address(oethb), "Token0 must be less than Token1");
        MockERC20 impl = new MockERC20("Origin ETH Base", "OETHb", 18);
        vm.etch(address(oethb), address(impl).code);

        // 3. Whitelist token0 and token1 in Voter: Not needed anymore
        vm.startPrank(Base.GOV_VOTER);
        voter.whitelistToken(address(weth), true);
        voter.whitelistToken(address(oethb), true);
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
                tokenA: address(weth),
                tokenB: address(oethb),
                tickSpacing: TICK_SPACING,
                sqrtPriceX96: getInitialPriceWithRatio(ratio)
            })
        );

        // 2. Create Gauge and get NFT Manager
        gauge = ICLGauge(payable(voter.createGauge(address(poolFactory), address(pool))));
        nftManager = INonfungiblePositionManager(payable(pool.nft()));

        // Deploy StrategyAMO and Vault
        strategy = new StrategyAMO(nftManager, pool, weth, oethb, ratio);
        vault = new Vault(weth, oethb, ratio, strategy);
        strategy.setVault(vault);

        // Approvals
        weth.approve(address(nftManager), type(uint256).max);
        oethb.approve(address(nftManager), type(uint256).max);
        weth.approve(address(vault), type(uint256).max);
        oethb.approve(address(vault), type(uint256).max);
        nftManager.setApprovalForAll(address(gauge), true);

        // Label
        vm.label(address(weth), "WETH");
        vm.label(address(oethb), "OETHb");
        vm.label(address(strategy), "StrategyAMO");
        vm.label(address(nftManager), "NFTManager");
        vm.label(address(pool), "CLPool OETHb/WETH");
        vm.label(address(gauge), "CLGauge OETHb/WETH");
        vm.label(Base.SUGAR_HELPER, "SugarHelper");
    }

    function getInitialPriceWithRatio(uint256 ratio) public pure returns (uint160) {
        return (TickMath.getSqrtRatioAtTick(0) * 1e9 + TickMath.getSqrtRatioAtTick(1) * uint160(ratio))
            / uint160(1e9 + ratio);
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        if (amount0Delta > 0) weth.transfer(address(pool), uint256(amount0Delta));
        else if (amount1Delta > 0) oethb.transfer(address(pool), uint256(amount1Delta));
    }

    function _buyOETHb(uint256 amount) internal {
        _buyOETHb(amount, -DEFAULT_MAX_TICK);
    }

    function _buyOETHb(uint256 amount, int24 maxTick) internal {
        // Give user a bit more WETH
        deal(address(weth), address(this), amount * 110 / 100);
        // User swap WETH for OETHb in the pool
        pool.swap({
            recipient: address(this),
            zeroForOne: true,
            amountSpecified: int256(amount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(maxTick),
            data: ""
        });
    }

    function _sellOETHb(uint256 amount) internal {
        _sellOETHb(amount, DEFAULT_MAX_TICK);
    }

    function _sellOETHb(uint256 amount, int24 maxTick) internal {
        // Give user WETH
        deal(address(weth), address(this), amount);
        // User approve vault to take WETH
        weth.approve(address(vault), amount);
        // User mint OETHb against WETH
        vault.deposit(amount, address(this));
        // User swap OETHb for WETH in the pool
        pool.swap({
            recipient: address(this),
            zeroForOne: false,
            amountSpecified: -int256(amount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(maxTick),
            data: ""
        });
    }

    /// Note: weird issue of amountDesired shouldn't be 0 even if it's not used, for example deposit full outside of current tick.
    function _provideLiquidity(uint256 amount0, uint256 amount1, int24 tickLower, int24 tickUpper)
        internal
        returns (uint256 tokenId, uint128 liquidity, uint256 _amount0, uint256 _amount1)
    {
        if (amount0 > 1) {
            deal(address(weth), address(this), amount0);
        } else if (amount1 > 1) {
            deal(address(weth), address(this), amount1);
            vault.deposit(amount1, address(this));
        }
        return nftManager.mint(
            INonfungiblePositionManager.MintParams({
                token0: address(weth),
                token1: address(oethb),
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

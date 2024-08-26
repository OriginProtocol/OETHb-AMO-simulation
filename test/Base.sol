// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {Test} from "forge-std/Test.sol";

// Solmate and Solady
import {WETH} from "lib/solmate/src/tokens/WETH.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

// Interfaces -- Aerodrome
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ICLGauge} from "test/interfaces/ICLGauge.sol";
import {ISwapRouter} from "test/interfaces/ISwapRouter.sol";
import {ISugarHelper} from "test/interfaces/ISugarHelper.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Interfaces -- AMO
import {IVault} from "test/interfaces/IVault.sol";
import {IQuoterV2} from "test/interfaces/IQuoter.sol";
import {IAMOStrategy} from "test/interfaces/IAMOStrategy.sol";

// Utils
import {Base} from "test/utils/Addresses.sol";

abstract contract Base_Test_ is Test {
    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    int24 public constant DEFAULT_LOWER_TICK = -1;
    int24 public constant DEFAULT_UPPER_TICK = 0;
    int24 public constant DEFAULT_TICK_SPACING = 1;

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    WETH public weth; // Token 0
    ERC20 public oethb; // Token 1

    // Aerodrome
    ICLPool public pool;
    ICLGauge public gauge;
    IQuoterV2 public quoter;
    ISwapRouter public swapRouter;
    ISugarHelper public sugarHelper;
    INonfungiblePositionManager public nftManager;

    // AMO
    IVault public vault;
    IAMOStrategy public strategy;

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual {
        // 1. Create fork
        vm.createSelectFork("local");

        // 2. Fetch AMO strategy
        strategy = IAMOStrategy(Base.AMO_STRATEGY);

        // 3. Fect usefull contracts
        pool = strategy.clPool();
        weth = WETH(payable(pool.token0()));
        oethb = ERC20(pool.token1());
        gauge = ICLGauge(payable(pool.gauge()));
        nftManager = INonfungiblePositionManager(payable(pool.nft()));
        quoter = IQuoterV2(Base.QUOTERV2);
        sugarHelper = ISugarHelper(Base.SUGAR_HELPER);

        // 4. Fetch AMO Strategy
        vault = IVault(strategy.vaultAddress());
        swapRouter = strategy.swapRouter();

        // 5. Set AMO strategy as default strategy for WETH on vault
        vm.prank(address(strategy.governor()));
        vault.setAssetDefaultStrategy(address(weth), address(strategy));

        // 6. Approvals
        // --- Vault
        weth.approve(address(vault), type(uint256).max);
        oethb.approve(address(vault), type(uint256).max);
        // --- Pool
        weth.approve(address(pool), type(uint256).max);
        oethb.approve(address(pool), type(uint256).max);
        // --- NFTManager
        weth.approve(address(nftManager), type(uint256).max);
        oethb.approve(address(nftManager), type(uint256).max);
        // --- SwapRouter
        weth.approve(address(swapRouter), type(uint256).max);
        oethb.approve(address(swapRouter), type(uint256).max);

        // 7. Labels
        vm.label(address(weth), "WETH");
        vm.label(address(oethb), "OETHB");
        vm.label(address(pool), "CLPOOL");
        vm.label(address(gauge), "CLGAUGE");
        vm.label(address(quoter), "QuoterV2");
        vm.label(address(vault), "VAULT OETHb");
        vm.label(address(strategy), "AMOStrategy");
        vm.label(address(nftManager), "NFTManager");
        vm.label(address(Base.SUGAR_HELPER), "SugarHelper");
        vm.label(address(Base.AMO_STRATEGY_IMPL), "AMOStrategyImpl");
    }

    /// @notice Override the deal function to add the balanceBefore to amount minted
    /// Otherwise it will over write the final balance with the minted amount.
    function _deal(address token, address to, uint256 amount) internal {
        uint256 balanceBefore = ERC20(token).balanceOf(to);
        super.deal(token, to, amount + balanceBefore);
    }

    function deal(address token, address to, uint256 amount) internal override {
        if (amount == 0) return;
        if (to != address(this)) super.deal(token, to, amount);
        if (token == address(oethb)) {
            _deal(address(weth), address(this), amount);
            vault.mint(address(weth), amount, 0);
        } else {
            _deal(address(token), address(this), amount);
        }
    }
}

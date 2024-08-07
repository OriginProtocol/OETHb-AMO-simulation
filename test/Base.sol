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
import {AMO} from "src/AMO.sol";

abstract contract Base_Test_ is Test {
    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    int24 public constant LOWER_TICK = 0;
    int24 public constant UPPER_TICK = 1;
    int24 public constant TICK_SPACING = 1;
    uint256 public constant DEFAULT_AMOUNT = 100 ether;

    ERC20 public immutable AERO = ERC20(Base.AERO);
    IVoter public immutable voter = IVoter(Base.VOTER);
    ICLPoolFactory public immutable poolFactory = ICLPoolFactory(Base.CLPOOL_FACTORY);

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    address public feesVotingReward;

    AMO public amo;
    ERC20 public token0; // OETHb
    ERC20 public token1; // WETH
    ERC20 public rewardToken;

    ICLPool public pool;
    ICLGauge public gauge;
    INonfungiblePositionManager public nftManager;

    ////////////////////////////////////////////////////////////////
    /// --- STATE VARIABLES
    ////////////////////////////////////////////////////////////////
    uint256 public liquidityRatio = 8e17; // 80% OETHb, 20% WETH

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

        // 3. Whitelist token0 and token1 in Voter
        vm.startPrank(Base.GOV_VOTER);
        voter.whitelistToken(address(token0), true);
        voter.whitelistToken(address(token1), true);
        vm.stopPrank();

        // 4. Create Pool
        pool = ICLPool(
            poolFactory.createPool({
                tokenA: address(token0),
                tokenB: address(token1),
                tickSpacing: TICK_SPACING,
                sqrtPriceX96: getInitialPriceWithRatio()
            })
        );

        // 5. Create Gauge
        gauge = ICLGauge(payable(voter.createGauge({_poolFactory: address(poolFactory), _pool: address(pool)})));
        nftManager = INonfungiblePositionManager(payable(pool.nft()));
        feesVotingReward = gauge.feesVotingReward();

        // x. Deploy AMO
        amo = new AMO(nftManager, pool, token0, token1, liquidityRatio);

        // 6. Max approve all tokens
        token0.approve(address(nftManager), type(uint256).max);
        token1.approve(address(nftManager), type(uint256).max);
        nftManager.setApprovalForAll(address(gauge), true);

        // 7. Label contracts
        vm.label(address(token0), "OETHb");
        vm.label(address(token1), "WETH");
        vm.label(address(rewardToken), "Reward Token");
        vm.label(address(pool), "CLPool OETHb/WETH");
        vm.label(address(gauge), "CLGauge OETHb/WETH");
        vm.label(address(nftManager), "NFTManager");
        vm.label(feesVotingReward, "Fees Voting Reward");
        vm.label(address(voter), "Voter");
        vm.label(address(AERO), "AERO token");
        vm.label(address(amo), "AMO");
    }

    function getInitialPriceWithRatio() public view returns (uint160) {
        return (
            TickMath.getSqrtRatioAtTick(0) * uint160(liquidityRatio)
                + TickMath.getSqrtRatioAtTick(1) * uint160(1e18 - liquidityRatio)
        ) / 1e18;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Foundry
import {Test} from "forge-std/Test.sol";

// Solmate
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

// Aerodrome
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ICLFactory} from "test/interfaces/ICLFactory.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

// Internal utils
import {Base} from "test/utils/Addresses.sol";
import {TickMath} from "test/libraries/TickMath.sol";

contract Simulator is Test {
    ////////////////////////////////////////////////////////////////
    /// --- CONSTANTS & IMMUTABLES
    ////////////////////////////////////////////////////////////////
    int24 public constant TICK_SPACING = 1;
    uint160 public immutable INITIAL_SQRTPRICEX96 = TickMath.getSqrtRatioAtTick(0);

    ////////////////////////////////////////////////////////////////
    /// --- CONTRACTS & INTERFACES
    ////////////////////////////////////////////////////////////////
    ERC20 public token0; // OETHb
    ERC20 public token1; // WETH
    ICLPool public pool;
    ICLFactory public factory;
    INonfungiblePositionManager public nftManager;

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public {
        token1 = ERC20(new MockERC20("Wrapped ETH", "WETH", 18));
        token0 = ERC20(new MockERC20("Origin ETH Base", "OETHb", 18));
        factory = ICLFactory(Base.CLFACTORY);
        nftManager = INonfungiblePositionManager(payable(Base.NFT_POSITION_MANAGER));

        // Ensure token0 is less than token1, otherwise it will fail when compute pool address
        require(token0 < token1, "Token0 must be less than Token1");

        // Create fork
        vm.createSelectFork(vm.envString("BASE_PROVIDER_URL"), vm.envUint("BASE_BLOCK_NUMBER"));

        // Create pool with token0 and token1
        pool = ICLPool(
            factory.createPool({
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

        // Label all addresses
        vm.label(address(token0), "Token0");
        vm.label(address(token1), "Token1");
        vm.label(address(pool), "Pool T0/T1");
        vm.label(address(factory), "CLFactory");
        vm.label(Base.CLPOOL_IMPL, "CLPool Implementation");
        vm.label(address(nftManager), "NFT Position Manager");
    }

    function test() public {
        addLiquidity(100 ether, 100 ether);
        swap(address(token0), 10 ether);
    }

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
                amount0Desired: 100 ether,
                amount1Desired: 100 ether,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 100,
                sqrtPriceX96: 0
            })
        );

        return (tokenId, liquidity);
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

    ////////////////////////////////////////////////////////////////
    /// --- CALLBACK
    ////////////////////////////////////////////////////////////////
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {}
}

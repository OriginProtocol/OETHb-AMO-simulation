// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ISugarHelper {
    struct PopulatedTick {
        int24 tick;
        uint160 sqrtRatioX96;
        int128 liquidityNet;
        uint128 liquidityGross;
    }

    function estimateAmount0(uint256 amount1, address pool, uint160 sqrtRatioX96, int24 tickLow, int24 tickHigh)
        external
        view
        returns (uint256 amount0);
    function estimateAmount1(uint256 amount0, address pool, uint160 sqrtRatioX96, int24 tickLow, int24 tickHigh)
        external
        view
        returns (uint256 amount1);
    function fees(address positionManager, uint256 tokenId) external view returns (uint256 amount0, uint256 amount1);
    function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
        external
        pure
        returns (uint256);
    function getAmount0Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
        external
        pure
        returns (int256);
    function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, int128 liquidity)
        external
        pure
        returns (int256);
    function getAmount1Delta(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint128 liquidity, bool roundUp)
        external
        pure
        returns (uint256);
    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) external pure returns (uint256 amount0, uint256 amount1);
    function getLiquidityForAmounts(
        uint256 amount0,
        uint256 amount1,
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96
    ) external pure returns (uint256 liquidity);
    function getPopulatedTicks(address pool, int24 startTick)
        external
        view
        returns (PopulatedTick[] memory populatedTicks);
    function getSqrtRatioAtTick(int24 tick) external pure returns (uint160 sqrtRatioX96);
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) external pure returns (int24 tick);
    function poolFees(address pool, uint128 liquidity, int24 tickCurrent, int24 tickLower, int24 tickUpper)
        external
        view
        returns (uint256 amount0, uint256 amount1);
    function principal(address positionManager, uint256 tokenId, uint160 sqrtRatioX96)
        external
        view
        returns (uint256 amount0, uint256 amount1);
}

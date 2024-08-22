// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ISwapRouter} from "test/interfaces/ISwapRouter.sol";

interface IAMOStrategy {
    error PoolRebalanceOutOfBounds(uint256 currentPoolWethShare, uint256 requiredPoolWethShare);
    error OutsideExpectedTickRange(int24 currentTick, int24 lowerTick, int24 upperTick);

    function governor() external view returns (address);
    function rebalance(uint256 _amountToSwap, bool _swapWeth, uint256 _minTokenReceived) external;
    function clPool() external view returns (ICLPool);
    function vaultAddress() external view returns (address);
    function swapRouter() external view returns (ISwapRouter);
    function poolWethShareVarianceAllowed() external view returns (uint256);
    function poolWethShare() external view returns (uint256);
    function tokenId() external view returns (uint256);
    function withdrawAll() external;
    function setPoolWethShare(uint256 share) external;
    function setWithdrawLiquidityShare(uint128 share) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ICLPool} from "test/interfaces/ICLPool.sol";
import {ISwapRouter} from "test/interfaces/ISwapRouter.sol";

interface IAMOStrategy {
    function governor() external view returns (address);
    function rebalance(uint256 _amountToSwap, uint256 _minTokenReceived, bool _swapWeth) external;
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

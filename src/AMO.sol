// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {AMO_Actions} from "src/AMO_Actions.sol";

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

contract AMO is AMO_Actions {
    uint256 public immutable LIQUIDITY_RATIO;
    uint256 mintedOETHbForFree;

    constructor(
        INonfungiblePositionManager _nftManager,
        ICLPool _pool,
        ERC20 _token0,
        ERC20 _token1,
        uint256 _liquidityRatio
    ) AMO_Actions(_nftManager, _pool, _token0, _token1) {
        LIQUIDITY_RATIO = _liquidityRatio;
    }

    function checkBalance() external view returns (uint256) {
        return 0;
    }

    function rebalance() external {}

    function depositInitialLiquidity(uint256 amountWETH) external {
        uint256 amountOETHb = (amountWETH * LIQUIDITY_RATIO) / (1e18 - LIQUIDITY_RATIO);
        // 1. Need to receive WETH
        // 2. Need to mint OETHb
        _mintOETHb(amountOETHb, address(this));
        mintedOETHbForFree += amountOETHb;

        // 3. Add initial liquidity
        _addIinitialLiquidity(amountOETHb, amountWETH);
    }

    function removeAllLiquidity() external {
        // 1. Remove all liquidity
        (uint256 amountOETHb,) = _removeAllLiquidity();

        // 2. Burn OETHb
        //_burnOETHb(amountOETHb, address(this));
    }

    function mintOETHb(uint256 amount) external {
        token1.transferFrom(msg.sender, address(this), amount);
        _mintOETHb(amount, msg.sender);
    }

    function redeemOETHb(uint256 amount) external {
        token0.transferFrom(msg.sender, address(this), amount);
        _burnOETHb(amount, msg.sender);
        token1.transfer(msg.sender, amount);
    }
}

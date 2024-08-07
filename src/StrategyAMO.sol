// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ActionsAMO} from "src/ActionsAMO.sol";

import {Vault} from "src/Vault.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {ICLPool} from "test/interfaces/ICLPool.sol";
import {INonfungiblePositionManager} from "test/interfaces/INonfungiblePositionManager.sol";

contract StrategyAMO is ActionsAMO {
    uint256 public immutable LIQUIDITY_RATIO;

    Vault public vault;

    constructor(
        INonfungiblePositionManager _nftManager,
        ICLPool _pool,
        ERC20 _token0,
        ERC20 _token1,
        uint256 _liquidityRatio
    ) ActionsAMO(_nftManager, _pool, _token0, _token1) {
        LIQUIDITY_RATIO = _liquidityRatio;
    }

    function checkBalance() external view returns (uint256) {
        return token1.balanceOf(address(this));
    }

    function setVault(Vault _vault) external {
        vault = _vault;
        token0.approve(address(vault), type(uint256).max);
        token1.approve(address(vault), type(uint256).max);
    }

    function depositInPool(uint256 amountWETH) external {
        (, uint256 amountOETHb) = vault.depositInStrategy(amountWETH);
        if (tokenId == 0) _addIinitialLiquidity(amountOETHb, amountWETH);
        else _increaseLiquidity(amountOETHb, amountWETH);
    }

    function withdrawAllFromPool() external {
        (uint256 amountOETHb, uint256 amountWETH) = _removeAllLiquidity();
        vault.withdrawFromStrategy(amountOETHb, amountWETH);
    }
}

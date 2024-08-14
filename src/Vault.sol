// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

import {StrategyAMO} from "src/StrategyAMO.sol";

contract Vault {
    uint256 public ratio;
    uint256 public oethbMintedForAMO;
    uint256 public oethbDebt;
    uint256 public wethDebt;

    ERC20 public weth;
    ERC20 public oethb;
    StrategyAMO public strategy;

    constructor(ERC20 _weth, ERC20 _oeth, uint256 _ratio, StrategyAMO _strategy) {
        oethb = _oeth;
        weth = _weth;
        ratio = _ratio;
        strategy = _strategy;
    }

    function checkBalance() external view returns (uint256) {
        return weth.balanceOf(address(this)) + weth.balanceOf(address(strategy)) + oethbMintedForAMO;
    }

    function deposit(uint256 amount, address receiver) external {
        weth.symbol();
        weth.balanceOf(msg.sender);
        weth.transferFrom(msg.sender, address(this), amount);
        MockERC20(address(oethb)).mint(receiver, amount);
    }

    function withdraw(uint256 amount, address from) external {
        MockERC20(address(oethb)).burn(msg.sender, amount);
        weth.transfer(from, amount);
    }

    event log_named_uint(string name, uint256 value);

    function depositInStrategy(uint256 amountWETH) external returns (uint256, uint256) {
        require(msg.sender == address(strategy), "Vault: Only strategy");
        emit log_named_uint("Ratio", ratio);
        uint256 amountOETHb = amountWETH * ratio / 1e9;

        weth.transfer(address(strategy), amountWETH);
        MockERC20(address(oethb)).mint(address(strategy), amountOETHb);

        return (amountWETH, amountOETHb);
    }

    function withdrawFromStrategy(uint256 amountOETHb, uint256 amountWETH) external {
        require(msg.sender == address(strategy), "Vault: Only strategy");
        MockERC20(address(oethb)).burn(address(strategy), amountOETHb);
        weth.transferFrom(address(strategy), address(this), amountWETH);
        require(weth.balanceOf(address(strategy)) == 0, "Vault: WETH balance not 0");
        require(oethb.balanceOf(address(strategy)) == 0, "Vault: OETHb balance not 0");
    }

    /// @notice To use when the AMO as no more OETHb when doing rebalancing.
    function mintOETHbForFree(uint256 amount) external {
        oethbMintedForAMO += amount;
        oethbDebt += amount;
        MockERC20(address(oethb)).mint(msg.sender, amount);
    }

    /// @notice To use when the AMO as no more WETH when doing rebalancing.
    function transferWETHToStrategyForFree(uint256 amount) external {
        weth.transfer(address(strategy), amount);
    }

    function transferWETHToStrategyFromDAOTreasury(uint256 amount) external {
        wethDebt += amount;
        MockERC20(address(weth)).mint(msg.sender, amount);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

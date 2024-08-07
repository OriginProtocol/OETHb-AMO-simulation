// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC20} from "@solmate/tokens/ERC20.sol";
import {MockERC20} from "@solmate/test/utils/mocks/MockERC20.sol";

import {StrategyAMO} from "src/StrategyAMO.sol";

contract Vault {
    uint256 public ratio;

    ERC20 public weth;
    ERC20 public oethb;
    StrategyAMO public strategy;

    constructor(ERC20 _oeth, ERC20 _weth, uint256 _ratio, StrategyAMO _strategy) {
        oethb = _oeth;
        weth = _weth;
        ratio = _ratio;
        strategy = _strategy;
    }

    function checkBalance() external view returns (uint256) {
        return weth.balanceOf(address(this)) + strategy.checkBalance() + oethb.totalSupply();
    }

    function deposit(uint256 amount, address receiver) external {
        weth.transferFrom(msg.sender, address(this), amount);
        MockERC20(address(oethb)).mint(receiver, amount);
    }

    function withdraw(uint256 amount, address from) external {
        MockERC20(address(oethb)).burn(msg.sender, amount);
        weth.transfer(from, amount);
    }

    function depositInStrategy(uint256 amount) external returns (uint256, uint256) {
        require(msg.sender == address(strategy), "Vault: Only strategy");
        weth.transfer(address(strategy), amount);
        uint256 amountOETHb = (amount * ratio) / (1e18 - ratio);
        MockERC20(address(oethb)).mint(address(strategy), amountOETHb);

        return (amount, amountOETHb);
    }

    function withdrawFromStrategy(uint256 amountOETHb, uint256 amountWETH) external {
        require(msg.sender == address(strategy), "Vault: Only strategy");
        uint256 ratioAmountWETH = (1e18 - ratio) * amountOETHb / ratio;
        uint256 ratioAmountOETHb = ratio * amountWETH / (1e18 - ratio);
        MockERC20(address(oethb)).burn(address(strategy), min(amountOETHb, ratioAmountOETHb));
        weth.transferFrom(address(strategy), address(this), min(amountWETH, ratioAmountWETH));
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
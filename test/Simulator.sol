// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

// Solmate
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

// Internal for testing
import {Actions} from "test/Actions.sol";

contract Simulator is Actions {
    using FixedPointMathLib for uint256;

    ////////////////////////////////////////////////////////////////
    /// --- SETUP
    ////////////////////////////////////////////////////////////////
    function setUp() public virtual override {
        super.setUp();
    }

    ////////////////////////////////////////////////////////////////
    /// --- SIMULATION
    ////////////////////////////////////////////////////////////////
    function test1() public {
        (uint256 tokenId,) =
            addLiquidity(DEFAULT_AMOUNT.mulWadDown(liquidityRatio), DEFAULT_AMOUNT.mulWadUp(1e18 - liquidityRatio));
        stake(tokenId);
        swap(address(token0), 10 ether);
        nftManager.positions(tokenId);
    }
}

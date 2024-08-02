// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ICLGauge {
    event ClaimFees(address indexed from, uint256 claimed0, uint256 claimed1);
    event ClaimRewards(address indexed from, uint256 amount);
    event Deposit(address indexed user, uint256 indexed tokenId, uint128 indexed liquidityToStake);
    event NotifyReward(address indexed from, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed tokenId, uint128 indexed liquidityToStake);

    receive() external payable;

    function WETH9() external view returns (address);
    function deposit(uint256 tokenId) external;
    function earned(address account, uint256 tokenId) external view returns (uint256);
    function fees0() external view returns (uint256);
    function fees1() external view returns (uint256);
    function feesVotingReward() external view returns (address);
    function gaugeFactory() external view returns (address);
    function getReward(uint256 tokenId) external;
    function getReward(address account) external;
    function initialize(
        address _pool,
        address _feesVotingReward,
        address _rewardToken,
        address _voter,
        address _nft,
        address _token0,
        address _token1,
        int24 _tickSpacing,
        bool _isPool
    ) external;
    function isPool() external view returns (bool);
    function lastUpdateTime(uint256) external view returns (uint256);
    function left() external view returns (uint256);
    function nft() external view returns (address);
    function notifyRewardAmount(uint256 _amount) external;
    function notifyRewardWithoutClaim(uint256 _amount) external;
    function onERC721Received(address, address, uint256, bytes memory) external returns (bytes4);
    function periodFinish() external view returns (uint256);
    function pool() external view returns (address);
    function rewardGrowthInside(uint256) external view returns (uint256);
    function rewardRate() external view returns (uint256);
    function rewardRateByEpoch(uint256) external view returns (uint256);
    function rewardToken() external view returns (address);
    function rewards(uint256) external view returns (uint256);
    function stakedByIndex(address depositor, uint256 index) external view returns (uint256);
    function stakedContains(address depositor, uint256 tokenId) external view returns (bool);
    function stakedLength(address depositor) external view returns (uint256);
    function stakedValues(address depositor) external view returns (uint256[] memory staked);
    function supportsPayable() external view returns (bool);
    function tickSpacing() external view returns (int24);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function voter() external view returns (address);
    function withdraw(uint256 tokenId) external;
}

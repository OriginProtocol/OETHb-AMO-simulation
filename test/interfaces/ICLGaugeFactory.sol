// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ICLGaugeFactory {
    event SetNotifyAdmin(address indexed notifyAdmin);

    function createGauge(
        address _forwarder,
        address _pool,
        address _feesVotingReward,
        address _rewardToken,
        bool _isPool
    ) external returns (address _gauge);
    function implementation() external view returns (address);
    function nft() external view returns (address);
    function notifyAdmin() external view returns (address);
    function setNonfungiblePositionManager(address _nft) external;
    function setNotifyAdmin(address _admin) external;
    function voter() external view returns (address);
}

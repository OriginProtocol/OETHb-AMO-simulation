// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IFactoryRegistry {
    error FallbackFactory();
    error InvalidFactoriesToPoolFactory();
    error PathAlreadyApproved();
    error PathNotApproved();
    error SameAddress();
    error ZeroAddress();

    event Approve(address indexed poolFactory, address indexed votingRewardsFactory, address indexed gaugeFactory);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetManagedRewardsFactory(address indexed _newRewardsFactory);
    event Unapprove(address indexed poolFactory, address indexed votingRewardsFactory, address indexed gaugeFactory);

    function approve(address poolFactory, address votingRewardsFactory, address gaugeFactory) external;
    function factoriesToPoolFactory(address poolFactory)
        external
        view
        returns (address votingRewardsFactory, address gaugeFactory);
    function fallbackPoolFactory() external view returns (address);
    function isPoolFactoryApproved(address poolFactory) external view returns (bool);
    function managedRewardsFactory() external view returns (address);
    function owner() external view returns (address);
    function poolFactories() external view returns (address[] memory);
    function poolFactoriesLength() external view returns (uint256);
    function renounceOwnership() external;
    function setManagedRewardsFactory(address _newManagedRewardsFactory) external;
    function transferOwnership(address newOwner) external;
    function unapprove(address poolFactory) external;
}

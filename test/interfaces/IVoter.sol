// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IVoter {
    error AlreadyVotedOrDeposited();
    error DistributeWindow();
    error FactoryPathNotApproved();
    error GaugeAlreadyKilled();
    error GaugeAlreadyRevived();
    error GaugeDoesNotExist(address _pool);
    error GaugeExists();
    error GaugeNotAlive(address _gauge);
    error InactiveManagedNFT();
    error MaximumVotingNumberTooLow();
    error NonZeroVotes();
    error NotAPool();
    error NotApprovedOrOwner();
    error NotEmergencyCouncil();
    error NotGovernor();
    error NotMinter();
    error NotWhitelistedNFT();
    error NotWhitelistedToken();
    error SameValue();
    error SpecialVotingWindow();
    error TooManyPools();
    error UnequalLengths();
    error ZeroAddress();
    error ZeroBalance();

    event Abstained(
        address indexed voter,
        address indexed pool,
        uint256 indexed tokenId,
        uint256 weight,
        uint256 totalWeight,
        uint256 timestamp
    );
    event DistributeReward(address indexed sender, address indexed gauge, uint256 amount);
    event GaugeCreated(
        address indexed poolFactory,
        address indexed votingRewardsFactory,
        address indexed gaugeFactory,
        address pool,
        address bribeVotingReward,
        address feeVotingReward,
        address gauge,
        address creator
    );
    event GaugeKilled(address indexed gauge);
    event GaugeRevived(address indexed gauge);
    event NotifyReward(address indexed sender, address indexed reward, uint256 amount);
    event Voted(
        address indexed voter,
        address indexed pool,
        uint256 indexed tokenId,
        uint256 weight,
        uint256 totalWeight,
        uint256 timestamp
    );
    event WhitelistNFT(address indexed whitelister, uint256 indexed tokenId, bool indexed _bool);
    event WhitelistToken(address indexed whitelister, address indexed token, bool indexed _bool);

    function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint256 _tokenId) external;
    function claimFees(address[] memory _fees, address[][] memory _tokens, uint256 _tokenId) external;
    function claimRewards(address[] memory _gauges) external;
    function claimable(address) external view returns (uint256);
    function createGauge(address _poolFactory, address _pool) external returns (address);
    function depositManaged(uint256 _tokenId, uint256 _mTokenId) external;
    function distribute(address[] memory _gauges) external;
    function distribute(uint256 _start, uint256 _finish) external;
    function emergencyCouncil() external view returns (address);
    function epochGovernor() external view returns (address);
    function epochNext(uint256 _timestamp) external pure returns (uint256);
    function epochStart(uint256 _timestamp) external pure returns (uint256);
    function epochVoteEnd(uint256 _timestamp) external pure returns (uint256);
    function epochVoteStart(uint256 _timestamp) external pure returns (uint256);
    function factoryRegistry() external view returns (address);
    function forwarder() external view returns (address);
    function gaugeToBribe(address) external view returns (address);
    function gaugeToFees(address) external view returns (address);
    function gauges(address) external view returns (address);
    function governor() external view returns (address);
    function initialize(address[] memory _tokens, address _minter) external;
    function isAlive(address) external view returns (bool);
    function isGauge(address) external view returns (bool);
    function isTrustedForwarder(address forwarder) external view returns (bool);
    function isWhitelistedNFT(uint256) external view returns (bool);
    function isWhitelistedToken(address) external view returns (bool);
    function killGauge(address _gauge) external;
    function lastVoted(uint256) external view returns (uint256);
    function length() external view returns (uint256);
    function maxVotingNum() external view returns (uint256);
    function minter() external view returns (address);
    function notifyRewardAmount(uint256 _amount) external;
    function poke(uint256 _tokenId) external;
    function poolForGauge(address) external view returns (address);
    function poolVote(uint256, uint256) external view returns (address);
    function pools(uint256) external view returns (address);
    function reset(uint256 _tokenId) external;
    function reviveGauge(address _gauge) external;
    function setEmergencyCouncil(address _council) external;
    function setEpochGovernor(address _epochGovernor) external;
    function setGovernor(address _governor) external;
    function setMaxVotingNum(uint256 _maxVotingNum) external;
    function totalWeight() external view returns (uint256);
    function updateFor(address _gauge) external;
    function updateFor(uint256 start, uint256 end) external;
    function updateFor(address[] memory _gauges) external;
    function usedWeights(uint256) external view returns (uint256);
    function ve() external view returns (address);
    function vote(uint256 _tokenId, address[] memory _poolVote, uint256[] memory _weights) external;
    function votes(uint256, address) external view returns (uint256);
    function weights(address) external view returns (uint256);
    function whitelistNFT(uint256 _tokenId, bool _bool) external;
    function whitelistToken(address _token, bool _bool) external;
    function withdrawManaged(uint256 _tokenId) external;
}

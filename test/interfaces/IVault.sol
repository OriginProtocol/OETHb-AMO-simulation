// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IVault {
    type UnitConversion is uint8;

    struct Asset {
        bool isSupported;
        UnitConversion unitConversion;
        uint8 decimals;
        uint16 allowedOracleSlippageBps;
    }

    event AllocateThresholdUpdated(uint256 _threshold);
    event AssetAllocated(address _asset, address _strategy, uint256 _amount);
    event AssetDefaultStrategyUpdated(address _asset, address _strategy);
    event AssetRemoved(address _asset);
    event AssetSupported(address _asset);
    event CapitalPaused();
    event CapitalUnpaused();
    event GovernorshipTransferred(address indexed previousGovernor, address indexed newGovernor);
    event MaxSupplyDiffChanged(uint256 maxSupplyDiff);
    event Mint(address _addr, uint256 _value);
    event NetOusdMintForStrategyThresholdChanged(uint256 _threshold);
    event OusdMetaStrategyUpdated(address _ousdMetaStrategy);
    event PendingGovernorshipTransfer(address indexed previousGovernor, address indexed newGovernor);
    event PriceProviderUpdated(address _priceProvider);
    event RebasePaused();
    event RebaseThresholdUpdated(uint256 _threshold);
    event RebaseUnpaused();
    event Redeem(address _addr, uint256 _value);
    event RedeemFeeUpdated(uint256 _redeemFeeBps);
    event StrategistUpdated(address _address);
    event StrategyAddedToMintWhitelist(address indexed strategy);
    event StrategyApproved(address _addr);
    event StrategyRemoved(address _addr);
    event StrategyRemovedFromMintWhitelist(address indexed strategy);
    event SwapAllowedUndervalueChanged(uint256 _basis);
    event SwapSlippageChanged(address _asset, uint256 _basis);
    event Swapped(
        address indexed _fromAsset, address indexed _toAsset, uint256 _fromAssetAmount, uint256 _toAssetAmount
    );
    event SwapperChanged(address _address);
    event TrusteeAddressChanged(address _address);
    event TrusteeFeeBpsChanged(uint256 _basis);
    event VaultBufferUpdated(uint256 _vaultBuffer);
    event YieldDistribution(address _to, uint256 _yield, uint256 _fee);

    fallback() external;

    function allocate() external;
    function burnForStrategy(uint256 amount) external;
    function cacheWETHAssetIndex() external;
    function calculateRedeemOutputs(uint256 _amount) external view returns (uint256[] memory);
    function checkBalance(address _asset) external view returns (uint256);
    function getAllAssets() external view returns (address[] memory);
    function getAllStrategies() external view returns (address[] memory);
    function getAssetConfig(address _asset) external view returns (Asset memory config);
    function getAssetCount() external view returns (uint256);
    function getStrategyCount() external view returns (uint256);
    function initialize(address _priceProvider, address _oToken) external;
    function isSupportedAsset(address _asset) external view returns (bool);
    function mint(address _asset, uint256 _amount, uint256 _minimumOusdAmount) external;
    function mintForStrategy(uint256 amount) external;
    function priceUnitMint(address asset) external view returns (uint256 price);
    function priceUnitRedeem(address asset) external view returns (uint256 price);
    function rebase() external;
    function redeem(uint256 _amount, uint256 _minimumUnitAmount) external;
    function redeemAll(uint256 _minimumUnitAmount) external;
    function totalValue() external view returns (uint256 value);
    function weth() external view returns (address);
    function wethAssetIndex() external view returns (uint256);

    function addStrategyToMintWhitelist(address strategyAddr) external;
    function allowedSwapUndervalue() external view returns (uint256 value);
    function approveStrategy(address _addr) external;
    function assetDefaultStrategies(address) external view returns (address);
    function autoAllocateThreshold() external view returns (uint256);
    function cacheDecimals(address _asset) external;
    function capitalPaused() external view returns (bool);
    function claimGovernance() external;
    function depositToStrategy(address _strategyToAddress, address[] memory _assets, uint256[] memory _amounts)
        external;
    function governor() external view returns (address);
    function isGovernor() external view returns (bool);
    function isMintWhitelistedStrategy(address) external view returns (bool);
    function maxSupplyDiff() external view returns (uint256);
    function netOusdMintForStrategyThreshold() external view returns (uint256);
    function netOusdMintedForStrategy() external view returns (int256);
    function ousdMetaStrategy() external view returns (address);
    function pauseCapital() external;
    function pauseRebase() external;
    function priceProvider() external view returns (address);
    function rebasePaused() external view returns (bool);
    function rebaseThreshold() external view returns (uint256);
    function redeemFeeBps() external view returns (uint256);
    function removeAsset(address _asset) external;
    function removeStrategy(address _addr) external;
    function removeStrategyFromMintWhitelist(address strategyAddr) external;
    function setAdminImpl(address newImpl) external;
    function setAssetDefaultStrategy(address _asset, address _strategy) external;
    function setAutoAllocateThreshold(uint256 _threshold) external;
    function setMaxSupplyDiff(uint256 _maxSupplyDiff) external;
    function setNetOusdMintForStrategyThreshold(uint256 _threshold) external;
    function setOracleSlippage(address _asset, uint16 _allowedOracleSlippageBps) external;
    function setOusdMetaStrategy(address _ousdMetaStrategy) external;
    function setPriceProvider(address _priceProvider) external;
    function setRebaseThreshold(uint256 _threshold) external;
    function setRedeemFeeBps(uint256 _redeemFeeBps) external;
    function setStrategistAddr(address _address) external;
    function setSwapAllowedUndervalue(uint16 _basis) external;
    function setSwapper(address _swapperAddr) external;
    function setTrusteeAddress(address _address) external;
    function setTrusteeFeeBps(uint256 _basis) external;
    function setVaultBuffer(uint256 _vaultBuffer) external;
    function strategistAddr() external view returns (address);
    function supportAsset(address _asset, uint8 _unitConversion) external;
    function swapCollateral(
        address _fromAsset,
        address _toAsset,
        uint256 _fromAssetAmount,
        uint256 _minToAssetAmount,
        bytes memory _data
    ) external returns (uint256 toAssetAmount);
    function swapper() external view returns (address swapper_);
    function transferGovernance(address _newGovernor) external;
    function transferToken(address _asset, uint256 _amount) external;
    function trusteeAddress() external view returns (address);
    function trusteeFeeBps() external view returns (uint256);
    function unpauseCapital() external;
    function unpauseRebase() external;
    function vaultBuffer() external view returns (uint256);
    function withdrawAllFromStrategies() external;
    function withdrawAllFromStrategy(address _strategyAddr) external;
    function withdrawFromStrategy(address _strategyFromAddress, address[] memory _assets, uint256[] memory _amounts)
        external;
}

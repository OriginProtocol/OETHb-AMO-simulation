# Objectif: Simulate AMO behavior for OETHb

## How does it work
- Using Foundry, it is running 5 differents situations (see below), and store data in a JSON.
- The JSON are then used to generate graph for a better visualisation.
- Graphs are stored in a new generate folder `data/graphs/`

## How to use it

### First file the .env
- `PROVIDER_URL_KEY` is mandatory. It is a alchemy API key. If you don't want to use Alchemy, change the RPC itself on the `foundry.toml`.
- `BASESCAN_API_KEY` is optional. It is useful when debugging.

#### Run Simulations
``` 
make tests
```
#### Generate graphs
```
make graphs
```

#### Run Simulation and generate graphs
```
make all
```

## Situations

### Initialization
All the situations have the same initialization using an initial ratio.
1. Create the pool:
  - WETH as token0
  - OETHb as token1, 
  - tick_spacing of 1
  - initial sqrtPriceX96 using initial ratio.
2. Create a gauge for the pool
3. Deploy Strategy (AMO) and Vault (1:1 WETH/OETHb minter)

### Vault Balance
The vault balance is always calculated using the same formula:

`Vault Balance = WETH.balanceOf(address(vault)) + WETH.balanceOf(address(strategy)) + oethbInPoolInOurPosition`

`oethbInPoolInOurPosition` means the amount of OETHb that the strategy has deposited in the pool between the ticks 0 and 1.


### Situation 1
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity. `Amount0 * Ratio = Amount1`
- `Amount`: Amount of WETH that will be deposited initially.

What's happening:
- Alice deposit `Amount` of WETH in the Vault and receive `Amount` of OETHb.
- Strategy starts the AMO and mint `Amount * Ratio` of OETHb
- Strategy takes the initial `Amount` of WETH and the minted amount of OETHb and deposit both on the pool.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 2A and 2B
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity.
- `Amount`: Amount of OETHb that will be buy in the pool.

What's happening:
- Alice deposit `10 ether` of WETH in the Vault and receive `10 ether` of OETHb.
- Strategy starts the AMO and mint `10 ethers * Ratio` of OETHb.
- Strategy takes the initial `10 ether` of WETH and the minted amount of OETHb and deposit both on the pool.
- In situation A:
  - Bob buy `Amount` of OETHb from the pool.
- In situation B:
  - Bob deposit `Amount` of WETH in the vault, get `Amount` of OETHb.
  - Bob sell `Amount` of OETHb in the pool.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 3A and 3B
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity.
- `Amount`: Amount of OETHb that will be provided as liquidity in the pool.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `10 ether` of WETH in the Vault and receive `10 ether` of OETHb.
- Strategy starts the AMO and mint `10 ethers * Ratio` of OETHb.
- Strategy takes the initial `10 ether` of WETH and the minted amount of OETHb and deposit both on the pool.
- In situation A:
  - Bob deposit `Amount` of WETH in the vault, get `Amount` of OETHb.
  - Bob provides `Amount` liquidity of OETHb between `-ticks-1` and `-ticks`.
- In situation B:
  - Bob provides `Amount` liquidity of WETH between `ticks` and `ticks +1`.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 4A and 4B
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity.
- `Amount`: Amount of OETHb that will be buy in the pool.
- `Rebalance`: % of the liquidity that will be removed before rebalancing.

What's happening:
- Alice deposit `10 ether` of WETH in the Vault and receive `10 ether` of OETHb.
- Strategy starts the AMO and mint `10 ethers * Ratio` of OETHb.
- Strategy takes the initial `10 ether` of WETH and the minted amount of OETHb and deposit both on the pool.
- In situation A:
  - Bob buy `Amount` of OETHb from the pool with maxPrice to ticks 0.
- In situation B:
  - Bob deposit `Amount` of WETH in the vault, get `Amount` of OETHb.
  - Bob sell `Amount` of OETHb in the pool with maxPrice to ticks 1.
- Rebalance Liquidity:
  - Remove `Rebalance`% of the liquidity from the pool.
  - Buy or sell OETH with liquidity pulled from pool to push price to initial ratio, between ticks 0 and 1.
  - Deposit remaining tokens as liquidity in the pool between ticks 0 and 1.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

Note: When doing rebalancing, we are checking 2 things:
- sqrtPriceX96 after swap is close from sqrtTargetedPriceX96 with a tolerence of 0.000001%
- Amount of WETH deposited as liquidity * ratio is equal to the amount of token1 with a tolerence of 0.05%.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 5A and 5B
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity.
- `Amount`: Amount of OETHb that will be buy in the pool.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `10 ether` of WETH in the Vault and receive `10 ether` of OETHb.
- Strategy starts the AMO and mint `10 ethers * Ratio` of OETHb.
- Strategy takes the initial `10 ether` of WETH and the minted amount of OETHb and deposit both on the pool.
- In situation A:
  - Bob deposit `Amount` of WETH in the vault, get `Amount` of OETHb.
  - Bob provides `Amount` liquidity of OETHb between `-ticks-1` and `-ticks`.
  - Bob buy `Amount` of OETHb from the pool with maxPrice of `-ticks-1`, to push price in lower ticks.
- In situation B:
  - Bob provides `Amount` liquidity of WETH between `ticks` and `ticks +1`.
  - Bob deposit `Amount` of WETH in the vault, get `Amount` of OETHb.
  - Bob sell `Amount` of OETHb in the pool with maxPrice to ticks 1, to push price i higher ticks.
- Rebalance Liquidity:
  - Remove `Rebalance`% of the liquidity from the pool.
  - Buy or sell OETH with liquidity pulled from pool to push price to initial ratio, between ticks 0 and 1.
  - Deposit remaining tokens as liquidity in the pool between ticks 0 and 1.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

Note: When doing rebalancing, we are checking 2 things:
- sqrtPriceX96 after swap is close from sqrtTargetedPriceX96 with a tolerence of 0.000001%
- Amount of WETH deposited as liquidity * ratio is equal to the amount of token1 with a tolerence of 0.05%.
Note 2: 
- If there is not enough of OETHb after removing the liquidity to push the price back between ticks 0 and 1, then the vault mint it for free to the the strategy.
- If there is not enought of WETH after removing the liquidity, the strategy tries to pull WETH from the Vault to rebalance. If after this, there is still not enough WETH to push the price back, then we are not monitoring this situation.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`


### Situation 6A
Input parameters:
- `Ratio`: Initial and target ratio when deposit initial liquidity.
- `Amount`: Amount of WETH that will be provided as liquidity between ticks 0 and 1.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `10 ether` of WETH in the Vault and receive `10 ether` of OETHb.
- Strategy starts the AMO and mint `10 ethers * Ratio` of OETHb.
- Strategy takes the initial `10 ether` of WETH and the minted amount of OETHb and deposit both on the pool.
- In situation A:
  - Bob deposit `10 ethers` of WETH in the vault, get `10 ethers` of OETHb.
  - Bob provides `10 ethers` liquidity of OETHb between `-ticks-1` and `-ticks`.
  - Bob buy `10 ethers * ratio * 110%` of OETHb from the pool with maxPrice of `-ticks-1`, to push price in lower ticks.
  - Bob provides `Amount` liquidity of WETH between ticks 0 and 1.
- Rebalance Liquidity:
  - Remove `99%` of the liquidity from the pool.
  - Buy or sell OETH with liquidity pulled from pool to push price to initial ratio, between ticks 0 and 1.
  - Deposit remaining tokens as liquidity in the pool between ticks 0 and 1.
- Strategy remove all the liquidity from the pool.
- The Vault takes back all the WETH from strategy and burn all OEHTb that hold the Strategy. 

Note: When doing rebalancing, we are checking 2 things:
- sqrtPriceX96 after swap is close from sqrtTargetedPriceX96 with a tolerence of 0.000001%
- Amount of WETH deposited as liquidity * ratio is equal to the amount of token1 with a tolerence of 0.05%.
Note 2: 
- If there is not enough of OETHb after removing the liquidity to push the price back between ticks 0 and 1, then the vault mint it for free to the the strategy.
- If there is not enought of WETH after removing the liquidity, the strategy tries to pull WETH from the Vault to rebalance. If after this, there is still not enough WETH to push the price back, then we are not monitoring this situation.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

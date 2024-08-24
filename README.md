# Objectif: Simulate AMO behavior for OETHb

## How does it work
- Using Foundry, it is running 5 differents situations (see below), and store data in a JSON.
- The JSON are then used to generate graph for a better visualisation.
- Graphs are stored in a new generate folder `data/graphs/`

## How to use it

### First, on this branch, run 
```
yarn run node:base
```

#### Run Simulations
``` 
make test
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

### Situation 1
Input parameters:
- `Share`: Target amount of WETH in the pool between tick -1 and 0, 1e18 is 100%.
- `Amount`: Amount of WETH that will be deposited initially.

What's happening:
- Alice deposit `Amount` of WETH in the Vault and receive `Amount` of OETHb.
- Strategy set the `setAllowedPoolWethShareInterval` using ±5% of `Share`.
- Vault allocate `WETH` to the AMO.
- Strategy rebalance by swapping `WETH`.
- Vault `withdrawAll` from AMO.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 2A and 2B
Input parameters:
- `Share`: Target amount of WETH in the pool between tick -1 and 0, 1e18 is 100%.
- `Amount`: Amount of OETHb that will be buy in the pool.

What's happening:
- Alice deposit `DEFAULT_INITIAL_DEPOSIT` of WETH in the Vault and receive `DEFAULT_INITIAL_DEPOSIT` of OETHb.
- Strategy set the `setAllowedPoolWethShareInterval` using ±5% of `Share`.
- Vault allocate `WETH` to the AMO.
- Strategy rebalance by swapping `WETH`.
- Alice swap `Amount` of WETH for OETHb (situation A) or OETHb for WETH (situation B)
- Vault `withdrawAll` from AMO.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 3A and 3B
Input parameters:
- `Share`: Target amount of WETH in the pool between tick -1 and 0, 1e18 is 100%.
- `Amount`: Amount of OETHb that will be provided as liquidity in the pool.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `DEFAULT_INITIAL_DEPOSIT` of WETH in the Vault and receive `DEFAULT_INITIAL_DEPOSIT` of OETHb.
- Strategy set the `setAllowedPoolWethShareInterval` using ±5% of `Share`.
- Vault allocate `WETH` to the AMO.
- Strategy rebalance by swapping `WETH`.
- Alice provide `amount` of liquidity between `ticks` and `ticks + 1` (situation A) or `-ticks - 1` and `-ticks` (situation B)
- Vault `withdrawAll` from AMO.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

### Situation 4A and 4B
- Removed.

### Situation 5A and 5B
Input parameters:
- `Share`: Target amount of WETH in the pool between tick -1 and 0, 1e18 is 100%.
- `Amount`: Amount of OETHb that will be provided as liquidity in the pool.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `DEFAULT_INITIAL_DEPOSIT` of WETH in the Vault and receive `DEFAULT_INITIAL_DEPOSIT` of OETHb.
- Strategy set the `setAllowedPoolWethShareInterval` using ±5% of `Share`.
- Vault allocate `WETH` to the AMO.
- Strategy rebalance by swapping `WETH`.
- Alice provide `DEFAULT_INITIAL_DEPOSIT` of liquidity between `-ticks` and `-ticks - 1` (situation A) or `ticks + 1` and `-ticks` (situation B)
- Alice swap `amount` of `WETH` for `OETHb` (situation A), of `OETHb` for `WETH` (situation B).
- Strategy rebalance by swapping `OETHb` (situation A), `WETH` (situation B).
- Vault `withdrawAll` from AMO.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`


### Situation 6A
Input parameters:
- `Share`: Target amount of WETH in the pool between tick -1 and 0, 1e18 is 100%.
- `Amount`: Amount of OETHb that will be provided as liquidity in the pool.
- `Ticks`: Ticks values where liquidity will be deposited

What's happening:
- Alice deposit `DEFAULT_INITIAL_DEPOSIT` of WETH in the Vault and receive `DEFAULT_INITIAL_DEPOSIT` of OETHb.
- Strategy set the `setAllowedPoolWethShareInterval` using ±5% of `Share`.
- Vault allocate `WETH` to the AMO.
- Strategy rebalance by swapping `WETH`.
- Alice provide `DEFAULT_INITIAL_DEPOSIT` of liquidity between `-ticks` and `-ticks - 1`
- Alice swap `DEFAULT_INITIAL_DEPOSIT` of `WETH` for `OETHb`.
- Alice provide `amount` of liquidity between ticks -1 and 0.
- Strategy rebalance by swapping `OETHb`.
- Vault `withdrawAll` from AMO.

What's verified:
- That the `(Vault Balance - TotalSupply) / 1e18 > 0`

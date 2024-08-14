import json
import os
import matplotlib.pyplot as plt
from itertools import cycle

json_file_path = os.path.join('data', 'Simulation5A.json')

with open(json_file_path, 'r') as file:
    data = json.load(file)

ratios = data['inputs']['Ratio']
amounts = data['inputs']['Amount']
rebalance_percentages = data['inputs']['Rebalance Percentage']

fig, axs = plt.subplots(len(amounts), 1, figsize=(12, len(amounts) * 6))
if len(amounts) == 1:
    axs = [axs]

colors = plt.rcParams['axes.prop_cycle'].by_key()['color']
color_cycle = cycle(colors)

for i, amount in enumerate(amounts):
    for rebalance_percentage in rebalance_percentages:
        differences = []
        #oethb_debt = []
        for ratio in ratios:
            supply_diff = data['outputs']['TotalSupplyAfter'][str(ratio)][str(amount)][str(rebalance_percentage)] - \
                          data['outputs']['TotalSupplyBefore'][str(ratio)][str(amount)][str(rebalance_percentage)]
            vault_diff = data['outputs']['VaultBalanceAfter'][str(ratio)][str(amount)][str(rebalance_percentage)] - \
                         data['outputs']['VaultBalanceBefore'][str(ratio)][str(amount)][str(rebalance_percentage)]
            differences.append(vault_diff - supply_diff)
            #oethb_debt.append(data['outputs']['OETHbDebt'][str(ratio)][str(amount)][str(rebalance_percentage)])
        
        color = next(color_cycle)
        axs[i].plot(ratios, differences, label=f'Rebalance %: {int(rebalance_percentage)/1e18:.2f}', marker='o', color=color)
        #axs[i].plot(ratios, oethb_debt, label=f'OETHbDebt (Rebalance %: {int(rebalance_percentage)/1e18:.2f})', 
                    #linestyle='--', marker='s', color=color)
    
    axs[i].set_title(f'Amount: {int(amount)/1e18:.0f}', fontsize=14)
    axs[i].set_xlabel('Ratio', fontsize=12)
    axs[i].set_ylabel('Value', fontsize=12)
    axs[i].set_ylim([-1e20, 1e20])
    axs[i].legend()
    axs[i].grid(True)

fig.suptitle('Simulation5A Results', fontsize=16)
plt.tight_layout(rect=[0, 0, 1, 0.96])

output_dir = os.path.join('data', 'graphs')
os.makedirs(output_dir, exist_ok=True)

plt.savefig(os.path.join(output_dir, 'Simulation5A.png'))
#plt.show()
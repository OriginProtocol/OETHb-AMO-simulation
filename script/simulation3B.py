import json
import os
import matplotlib.pyplot as plt

json_file_path = os.path.join('data', 'Simulation3B.json')

with open(json_file_path, 'r') as file:
    data = json.load(file)

ratios = data['inputs']['Ratio']
amounts = data['inputs']['Amount']
ticks = data['inputs']['Ticks']

fig, axs = plt.subplots(len(amounts), 1, figsize=(12, len(amounts) * 6))

for i, amount in enumerate(amounts):
    for tick in ticks:
        differences = []
        for ratio in ratios:
            supply_diff = data['outputs']['TotalSupplyAfter'][str(ratio)][str(amount)][str(tick)] - \
                          data['outputs']['TotalSupplyBefore'][str(ratio)][str(amount)][str(tick)]
            vault_diff = data['outputs']['VaultBalanceAfter'][str(ratio)][str(amount)][str(tick)] - \
                         data['outputs']['VaultBalanceBefore'][str(ratio)][str(amount)][str(tick)]
            differences.append(vault_diff - supply_diff)
        
        axs[i].plot(ratios, differences, label=f'Ticks: {tick}', marker='o')
    
    axs[i].set_title(f'Amount: {int(amount)/1e18:.0f}', fontsize=14)
    axs[i].set_xlabel('Ratio', fontsize=12)
    axs[i].set_ylabel('Difference', fontsize=12)
    axs[i].set_ylim([-1e20, 1e20])
    axs[i].legend()
    axs[i].grid(True)

fig.suptitle('Simulation3B Results', fontsize=16)
plt.tight_layout(rect=[0, 0, 1, 0.96])

output_dir = os.path.join('data', 'graphs')
os.makedirs(output_dir, exist_ok=True)

plt.savefig(os.path.join(output_dir, 'Simulation3B.png'))
plt.show()
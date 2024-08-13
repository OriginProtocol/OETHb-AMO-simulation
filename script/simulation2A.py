import json
import os
import matplotlib.pyplot as plt

# Define the correct path to the JSON file
json_file_path = os.path.join('data', 'Simulation2A.json')

# Load the JSON data
with open(json_file_path, 'r') as file:
    data = json.load(file)

# Extract the necessary data (assuming similar structure)
ratios = data['inputs']['Ratio']
amounts = data['inputs']['Amount']

total_supply_before = data['outputs']['TotalSupplyBefore']
vault_balance_before = data['outputs']['VaultBalanceBefore']
total_supply_after = data['outputs']['TotalSupplyAfter']
vault_balance_after = data['outputs']['VaultBalanceAfter']

# Create the graph with subplots
fig, axs = plt.subplots(len(amounts), 1, figsize=(10, len(amounts) * 5))

for i, amount in enumerate(amounts):
    difference = []
    
    for ratio in ratios:
        supply_diff = total_supply_after[str(ratio)][str(amount)] - total_supply_before[str(ratio)][str(amount)]
        vault_diff = vault_balance_after[str(ratio)][str(amount)] - vault_balance_before[str(ratio)][str(amount)]
        difference.append(vault_diff - supply_diff)
    
    # Plot the data for this amount
    axs[i].plot(ratios, difference, label='Difference (VaultBalance - TotalSupply)', marker='o')
    axs[i].set_title(f'Difference for Amount {int(amount)/1e18:.0f}', fontsize=14)
    axs[i].set_xlabel('Ratio', fontsize=12)
    axs[i].set_ylabel('Difference', fontsize=12)
    axs[i].set_ylim([-1e21, 1e21])  # Set y-axis limits
    axs[i].legend()
    axs[i].grid(True)

# Set the main title and save the figure
fig.suptitle('Simulation2A Results', fontsize=16)
plt.tight_layout(rect=[0, 0, 1, 0.96])

# Define the output directory and create it if it doesn't exist
output_dir = os.path.join('data', 'graphs')
os.makedirs(output_dir, exist_ok=True)

# Save the figure
plt.savefig(os.path.join(output_dir, 'Simulation2A.png'))
plt.show()

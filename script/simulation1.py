import json
import matplotlib.pyplot as plt
import numpy as np
import os

# Load the JSON data
with open('data/Simulation1.json', 'r') as file:
    data = json.load(file)

# Extract the relevant data
ratios = [int(ratio) / 1e18 for ratio in data['inputs']['Ratio']]
amounts = [int(amount) / 1e18 for amount in data['inputs']['Amount']]

# Function to format large numbers
def format_large_number(n):
    return f"{n:.2f}"

# Create the graph
fig, ax = plt.subplots(figsize=(14, 8))  # Increased figure width

colors = ['blue', 'red', 'green']  # Colors for different amounts
markers = ['o', 's', '^']  # Markers for different amounts
linestyles = ['-', '--']  # Line styles for TotalSupply and VaultBalance

for idx, amount in enumerate(amounts):
    total_supply_values = [float(data['outputs']['TotalSupplyAfter'][str(int(ratio*1e18))][str(int(amount*1e18))])/1e18 for ratio in ratios]
    vault_balance_values = [float(data['outputs']['VaultBalanceAfter'][str(int(ratio*1e18))][str(int(amount*1e18))])/1e18 for ratio in ratios]
    
    # Plot real values
    ax.plot(ratios, total_supply_values, color=colors[idx], linestyle=linestyles[0], 
            label=f'TotalSupply (Amount: {format_large_number(amount)})', marker=markers[idx], markersize=6)
    ax.plot(ratios, vault_balance_values, color=colors[idx], linestyle=linestyles[1], 
            label=f'VaultBalance (Amount: {format_large_number(amount)})', marker=markers[idx], markersize=6)
    
    # Calculate relative difference
    diff_values = np.array(vault_balance_values) - np.array(total_supply_values)
    relative_diff = diff_values / np.array(total_supply_values)
    
    # Add text to show maximum relative difference
    max_rel_diff = np.max(relative_diff)
    ax.text(0.02, 0.98 - 0.05*idx, f'Max Relative Difference ({format_large_number(amount)}): {max_rel_diff:.2e}', 
            transform=ax.transAxes, verticalalignment='top', color=colors[idx], fontsize=8)

ax.set_xlabel('Ratio')
ax.set_ylabel('Amount')
ax.set_ylim(0, 60)  # Set y-axis limit from 0 to 60
ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), fontsize=8)
ax.grid(True, which='both', linestyle='--', alpha=0.7)
ax.set_title('VaultBalance vs TotalSupply for Different Amounts and Ratios')

# Adjust the layout
plt.tight_layout()
plt.subplots_adjust(right=0.80)  # Increased right margin for legend

# Create the directory if it doesn't exist
os.makedirs('script/graphs', exist_ok=True)

# Save the figure
plt.savefig('script/graphs/Simulation1.png', dpi=300, bbox_inches='tight')
plt.close()

print("Generated graph 'Simulation1.png' in the 'script/graphs' folder.")
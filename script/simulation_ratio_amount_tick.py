import json
import os
import sys
import matplotlib.pyplot as plt

PLOT_DIFF = True

# Load JSON data from file
with open(sys.argv[1], "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

# Determine the number of ticks
num_ticks = len(inputs["Tick"])
# Determine the number of amounts
num_amounts = len(inputs["Amount"])
# Determine the number of ratios
num_ratios = len(inputs["Ratio"])
# Determine the number of graphs
num_graph = num_ratios

# Create a figure with subplots based on the number of ticks
fig, axes = plt.subplots(1, num_graph, figsize=(24,8))

# Add a big title for the whole image
fig.suptitle("Simulation Results for "+(sys.argv[1])[5:-5], fontsize=14, fontweight="bold")

for i, amount in enumerate(inputs["Amount"]):
    amount_str = str(amount)
    for j, ratio in enumerate(inputs["Ratio"]):
        ratio_str = str(ratio)
        # Calculate the difference between Vault Balance and TotalSupply, divided by 1e18
        diff = [(outputs["VaultBalanceAfter"][ratio_str][amount_str][str(tick)] - outputs["TotalSupplyAfter"][ratio_str][amount_str][str(tick)]) / 1e18 for tick in inputs["Tick"]]

        # Plot the difference with marked simulation points
        axes[j].plot(inputs["Tick"], diff, label=f"Amount: {amount / 1e18:.0f} eth", marker="o", markersize=4)
        axes[j].set_title(f"Ratio: {ratio / 1e16} %", fontsize=10)
        axes[j].set_xlabel("Tick", fontsize=8)
        
        # Plot y-axis label only once
        if (j == 0):
            axes[j].set_ylabel("(Vault Balance - TotalSupply) / 1e18", fontsize=8)
        else :
            axes[j].set_ylabel("")

        # Set y-axis to symlog scale between -1e2 and 1e2
        axes[j].set_yscale('symlog', linthresh=1e-5)  # Use symlog to handle both positive and negative values
        axes[j].set_xscale('log')
        axes[j].set_ylim(-1e4, 1e4)
        axes[j].grid(True, which="both", linestyle="--", alpha=0.5)  # Add grid

        axes[j].legend()

        # Add text boxes with scientific notation for each point
        if (PLOT_DIFF):
            for k, (x, y) in enumerate(zip(inputs["Tick"], diff)):
                axes[j].annotate(f'{y:.2e}', 
                                (x, y),
                                xytext=(3, 3), 
                                textcoords='offset points',
                                bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="gray", alpha=0.8))
    
# Adjust the layout to prevent overlapping
#plt.tight_layout(rect=[0, 0, 1, 0.96])


# Create the "data/graphs" folder if it doesn't exist
os.makedirs("data/graphs", exist_ok=True)

# Save the figure as a PNG file
plt.savefig(f"data/graphs/"+(sys.argv[1])[5:-5]+".png", dpi=300)
print(f"Saved data/graphs/"+(sys.argv[1])[5:-5]+".png")

#plt.show()
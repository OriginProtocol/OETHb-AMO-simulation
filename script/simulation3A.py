import json
import os
import matplotlib.pyplot as plt
import numpy as np

# Load JSON data from file
with open("data/Simulation3A.json", "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

# Calculate the number of rows and columns for subplots
num_amounts = len(inputs["Amount"])
num_ticks = len(inputs["Ticks"])
fig, axes = plt.subplots(num_amounts, num_ticks, figsize=(5*num_ticks, 5*num_amounts), squeeze=False)

# Add a big title for the whole image
fig.suptitle("Simulation 3A Results", fontsize=16, fontweight="bold")

# Iterate over each Amount and Ticks combination
for i, amount in enumerate(inputs["Amount"]):
    for j, ticks in enumerate(inputs["Ticks"]):
        ax = axes[i, j]
        
        # Calculate (Vault Balance - TotalSupply) / 1e18 for each Ratio
        diff = []
        for ratio in inputs["Ratio"]:
            ratio_str = str(ratio)
            amount_str = str(amount)
            ticks_str = str(ticks)
            
            vault_balance = outputs["VaultBalanceAfter"][ratio_str][amount_str][ticks_str]
            total_supply = outputs["TotalSupplyAfter"][ratio_str][amount_str][ticks_str]
            
            diff.append((vault_balance - total_supply) / 1e18)
        
        # Plot the difference with marked simulation points
        ax.plot(inputs["Ratio"], diff, label="(Vault Balance - TotalSupply) / 1e18", marker="o")
        
        # Set plot title and labels
        ax.set_title(f"Amount: {amount / 1e18:.0f} * 1e18, Ticks: {ticks}")
        ax.set_xlabel("Ratio")
        ax.set_ylabel("(Vault Balance - TotalSupply) / 1e18")
        
        # Set y-axis to symlog scale between -1e2 and 1e2
        ax.set_yscale('symlog', linthresh=1)  # Use symlog to handle both positive and negative values
        ax.set_ylim(-1e2, 1e2)
        
        ax.grid(True, which="both", linestyle="--", alpha=0.7)  # Add grid
        ax.ticklabel_format(style="sci", scilimits=(0, 0), axis="x")  # Set scientific notation for x-axis tick labels
        
        # Set x-axis ticks to match the actual Ratio values
        ax.set_xticks(inputs["Ratio"])
        ax.set_xticklabels([f"{ratio / 1e9:.1f}" for ratio in inputs["Ratio"]], rotation=45)
        
        ax.legend()

        # Add text boxes with scientific notation for each point
        for x, y in zip(inputs["Ratio"], diff):
            ax.annotate(f'{y:.2e}', 
                        (x, y),
                        xytext=(5, 5), 
                        textcoords='offset points',
                        bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="gray", alpha=0.8),
                        fontsize=6) 
            
# Adjust layout
plt.tight_layout(rect=[0, 0.03, 1, 0.95])

# Create the "data/graphs" folder if it doesn't exist
os.makedirs("data/graphs", exist_ok=True)

# Save the graph as an image file
plt.savefig("data/graphs/Simulation3A.png", dpi=300, bbox_inches="tight")
print("Simulation 3A graph saved successfully!")

# Optionally, display the plot (comment out if not needed)
#plt.show()
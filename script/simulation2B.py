import json
import os
import matplotlib.pyplot as plt
import numpy as np

# Load JSON data from file
with open("data/Simulation2B.json", "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

# Determine the number of amounts
num_amounts = len(inputs["Amount"])

# Create a figure with subplots based on the number of amounts
fig, axes = plt.subplots(1, num_amounts, figsize=(5 * num_amounts, 5))

# Add a big title for the whole image
fig.suptitle("Simulation 2B Results", fontsize=16, fontweight="bold")

# Ensure axes is always a list, even for a single subplot
if num_amounts == 1:
    axes = [axes]

# Iterate over each amount
for i, amount in enumerate(inputs["Amount"]):
    amount_str = str(amount)
    
    # Calculate the difference between Vault Balance and TotalSupply, divided by 1e18
    diff = [(outputs["VaultBalanceAfter"][str(ratio)][amount_str] - outputs["TotalSupplyAfter"][str(ratio)][amount_str]) / 1e18
            for ratio in inputs["Ratio"]]
    
    # Plot the difference with marked simulation points
    axes[i].plot(inputs["Ratio"], diff, label="(Vault Balance - TotalSupply) / 1e18", marker="o")
    axes[i].set_title(f"Amount: {amount / 1e18:.0f} * 1e18")
    axes[i].set_xlabel("Ratio")
    axes[i].set_ylabel("(Vault Balance - TotalSupply) / 1e18")
    
    # Set y-axis to symlog scale between -1e2 and 1e2
    axes[i].set_yscale('symlog', linthresh=1)  # Use symlog to handle both positive and negative values
    axes[i].set_ylim(-1e2, 1e2)
    
    axes[i].grid(True, which="both", linestyle="--", alpha=0.7)  # Add grid
    axes[i].ticklabel_format(style="sci", scilimits=(0, 0), axis="x")  # Set scientific notation for x-axis tick labels
    
    # Set x-axis ticks to match the actual Ratio values
    axes[i].set_xticks(inputs["Ratio"])
    axes[i].set_xticklabels([f"{ratio / 1e9:.1f}" for ratio in inputs["Ratio"]], rotation=45)
    
    axes[i].legend()

    for j, (x, y) in enumerate(zip(inputs["Ratio"], diff)):
        axes[i].annotate(f'{y:.2e}', 
                        (x, y),
                        xytext=(5, 5), 
                        textcoords='offset points',
                        bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="gray", alpha=0.8),
                        fontsize=8)

# Adjust spacing between subplots and the big title
plt.tight_layout(rect=[0, 0.03, 1, 0.95])

# Create the "data/graphs" folder if it doesn't exist
os.makedirs("data/graphs", exist_ok=True)

# Save the graph as an image file with the name "Simulation2B_Modified.png"
plt.savefig("data/graphs/Simulation2B.png", dpi=300)  # Increase DPI for better image quality
print("Simulation 2B graph saved successfully!")

# Display the graph
#plt.show()
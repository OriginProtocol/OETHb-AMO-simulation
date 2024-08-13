import json
import os
import matplotlib.pyplot as plt
import numpy as np

# Load JSON data from file
with open("data/Simulation1.json", "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

# Create a figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Add a big title for the whole image
fig.suptitle("Simulation 1 Results", fontsize=16, fontweight="bold")

# Iterate over each amount
for i, amount in enumerate(inputs["Amount"]):
    amount_str = str(amount)
    
    # Calculate the difference between total value difference and vault balance difference
    diff = [(outputs["TotalSupplyAfter"][str(ratio)][amount_str] - outputs["TotalSupplyBefore"][str(ratio)][amount_str]) - 
            (outputs["VaultBalanceAfter"][str(ratio)][amount_str] - outputs["VaultBalanceBefore"][str(ratio)][amount_str])
            for ratio in inputs["Ratio"]]
    
    # Plot the difference with marked simulation points
    axes[i].plot(inputs["Ratio"], diff, label="Difference", marker="o")
    axes[i].set_title(f"Amount: {amount / 1e18:.2f} * 1e18")
    axes[i].set_xlabel("Ratio")
    axes[i].set_ylabel("Difference")
    axes[i].set_ylim(-1e18, 1e18)  # Set y-axis limits
    axes[i].grid(True, which="both", linestyle="--", alpha=0.7)  # Add grid
    axes[i].ticklabel_format(style="sci", scilimits=(0, 0), axis="both")  # Set scientific notation for tick labels
    
    # Set custom x-axis tick locations and labels
    x_ticks = np.array([8, 8.050, 8.100, 8.150, 8.200]) * 1e17
    axes[i].set_xticks(x_ticks)
    axes[i].set_xticklabels([f"{tick / 1e17:.3f}" for tick in x_ticks])
    
    axes[i].legend()

# Adjust spacing between subplots and the big title
plt.tight_layout(rect=[0, 0.03, 1, 0.95])

# Create the "data/graphs" folder if it doesn't exist
os.makedirs("data/graphs", exist_ok=True)

# Save the graph as an image file with the name "Simulation1.png"
plt.savefig("data/graphs/Simulation1.png", dpi=300)  # Increase DPI for better image quality

# Display the graph
plt.show()
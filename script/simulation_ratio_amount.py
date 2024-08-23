import json
import os
import sys
import matplotlib.pyplot as plt

# Load JSON data from file
with open(sys.argv[1], "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

# Determine the number of amounts
num_amounts = len(inputs["Amount"])

# Create a figure
fig, ax = plt.subplots(figsize=(12, 8))

# Add a big title for the whole image
fig.suptitle("Simulation Results for "+(sys.argv[1])[5:-5], fontsize=14, fontweight="bold")

for i, amount in enumerate(inputs["Amount"]):
    amount_str = str(amount)
    
    # Calculate the difference between Vault Balance and TotalSupply, divided by 1e18
    diff = [(outputs["VaultBalanceAfter"][str(ratio)][amount_str] - outputs["TotalSupplyAfter"][str(ratio)][amount_str]) / 1e18 for ratio in inputs["Ratio"]]

    # Convert ratios to percentages for better readability
    ratios_percent = [ratio / 1e16 for ratio in inputs["Ratio"]]

    # Plot the difference with marked simulation points
    ax.plot(ratios_percent, diff, label=f"Amount: {amount / 1e18:.0f} eth", marker="o", markersize=4)

ax.set_xlabel("Ratio (%)", fontsize=8)
ax.set_ylabel("(Vault Balance - TotalSupply) / 1e18", fontsize=8)

# Set y-axis to symlog scale
ax.set_yscale('symlog', linthresh=1e-5)  # Use symlog to handle both positive and negative values
ax.set_ylim(-1e4, 1e4) 
ax.grid(True, which="both", linestyle="--", alpha=0.5)  # Add grid

ax.legend()

# Add text boxes with scientific notation for each point
for line in ax.get_lines():
    for x, y in zip(line.get_xdata(), line.get_ydata()):
        ax.annotate(f'{y:.2e}', 
                    (x, y),
                    xytext=(3, 3), 
                    textcoords='offset points',
                    fontsize=8,
                    bbox=dict(boxstyle="round,pad=0.3", fc="white", ec="gray", alpha=0.8))

# Create the "data/graphs" folder if it doesn't exist
os.makedirs("data/graphs", exist_ok=True)

# Save the figure as a PNG file
plt.savefig("data/graphs/"+(sys.argv[1])[5:-5]+".png", dpi=300)
print(f"Saved data/graphs/"+(sys.argv[1])[5:-5]+".png")

# Uncomment the next line if you want to display the plot
# plt.show()
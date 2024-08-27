import json
import math
import os
import sys
import matplotlib.pyplot as plt

PLOT_DIFF = False
BASE = 1.0001

def price_to_tick(sqrt_price_X96):
    p = ((sqrt_price_X96) / 2**96)**2
    i = math.log(p) / math.log(BASE)
    return round(i, 1)

# Load JSON data from file
with open('data/Simulation7.json', "r") as file:
    data = json.load(file)

# Extract inputs and outputs
inputs = data["inputs"]
outputs = data["outputs"]

fig, axes = plt.subplots(figsize=(18,8))

diff = [(outputs["VaultBalanceAfter"][str(price)] - outputs["TotalSupplyAfter"][str(price)])/float(1e18) for price in data["inputs"]["Price"]]
ticks = [price_to_tick(price) for price in data["inputs"]["Price"]]

axes.plot(ticks, diff, label="Price", marker="o", markersize=4)
axes.set_title("Benefit after rebalancing from price at tick", fontsize=12)
axes.set_yscale('symlog', linthresh=1e-6)  # Use symlog to handle both positive and negative values
axes.set_xscale('symlog', linthresh=1e-1)  # Use symlog to handle both positive and negative values
axes.set_ylabel("(Vault Balance - TotalSupply) / 1e18", fontsize=8)
axes.set_xlabel("Tick", fontsize=8)
axes.grid(True, which="both", linestyle="--", alpha=0.5)  # Add grid
axes.axvline(x=-0.2, color="red", linestyle="--", alpha=0.5)
axes.axvline(x=-1, color="black", linestyle="-", alpha=0.5)
axes.axvline(x=0, color="black", linestyle="-", alpha=0.5)

os.makedirs("data/graphs", exist_ok=True)

plt.savefig("data/graphs/Simulation7.png", dpi=300)

#plt.show()
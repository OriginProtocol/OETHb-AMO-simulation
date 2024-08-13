# Makefile for VaultBalance vs TotalSupply graph generation

# Python executable
PYTHON := python3

# Virtual environment directory
VENV := venv

# Python script name
SCRIPT := script/simulation1.py

# Output image name
OUTPUT := vault_balance_vs_total_supply.png

# Default target
all: run

# Create virtual environment
$(VENV)/bin/activate:
	$(PYTHON) -m venv $(VENV)

# Install dependencies
install: $(VENV)/bin/activate
	$(VENV)/bin/pip install matplotlib

# Run the script
run: install
	$(VENV)/bin/python $(SCRIPT)

# Clean up generated files and virtual environment
clean:
	rm -f $(OUTPUT)
	rm -rf $(VENV)

# Phony targets
.PHONY: all install run clean
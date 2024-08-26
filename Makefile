# Variables
PYTHON = python3
VENV_DIR = venv
SCRIPT_DIR = script
DATA_DIR = data
GRAPHS_DIR = $(DATA_DIR)/graphs

# List of all simulations
SIMULATIONS = 1 2A 2B 3A 3B 5A 5B 6A

all: test graphs

test:
	mkdir -p $(DATA_DIR)
	@forge test --summary 

test-f-%:
	@FOUNDRY_MATCH_TEST=$* make test

test-c-%:
	@FOUNDRY_MATCH_CONTRACT=$* make test

# Default target to run all simulations
graphs: $(VENV_DIR)/bin/activate $(addprefix sim-,$(SIMULATIONS))
	@echo "All simulations completed successfully!"

# Function to determine which script to use
sim_script = $(if $(filter 3A 3B 5A 5B 6A,$1),simulation_ratio_amount_tick.py,simulation_ratio_amount.py)

# Generate graphs target for simulation4B
simulation7: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation7.."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_7.py
	@echo "Graphs generated successfully for simulation4B!"

# Generate explicit targets for each simulation
define simulation_target
sim-$(1): $$(VENV_DIR)/bin/activate
	@echo "Generating graphs for Simulation$(1)..."
	@. $$(VENV_DIR)/bin/activate && \
	$$(PYTHON) $$(SCRIPT_DIR)/$$(call sim_script,$(1)) $$(DATA_DIR)/Simulation$(1).json
	@echo "Graphs generated successfully for Simulation$(1)!"
endef

$(foreach sim,$(SIMULATIONS),$(eval $(call simulation_target,$(sim))))

# Create virtual environment target
$(VENV_DIR)/bin/activate: requirements.txt
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate && pip install -r requirements.txt
	@echo "Virtual environment created successfully!"

# Create or update requirements.txt with matplotlib
requirements.txt:
	@echo "Creating or updating requirements.txt with matplotlib..."
	@touch requirements.txt
	@grep -q "matplotlib" requirements.txt || echo "matplotlib" >> requirements.txt

# Clean target
clean:
	@echo "Cleaning up..."
	@forge clean
	@rm -rf $(DATA_DIR) $(VENV_DIR) requirements.txt
	@echo "Cleanup completed!"

# Help target
help:
	@echo "Available targets:"
	@echo "  all             - Run tests and generate graphs for all simulations"
	@echo "  graphs          - Generate graphs for all simulations"
	@echo "  sim-<number>    - Generate graphs for a specific simulation (e.g., make sim-5A)"
	@echo "  clean           - Clean up generated graphs and virtual environment"
	@echo "  help            - Show this help message"

.PHONY: all tests test graphs clean help $(addprefix sim-,$(SIMULATIONS))
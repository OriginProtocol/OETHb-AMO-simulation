# Variables
PYTHON = python3
VENV_DIR = venv
SCRIPT_DIR = script

DATA_DIR = data
GRAPHS_DIR = $(DATA_DIR)/graphs


all:
	@$(MAKE) tests
	@$(MAKE) graphs

tests:
	mkdir -p data
	@forge test --summary -v

# Default target
graphs: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for all simulations ..."
	@. $(VENV_DIR)/bin/activate && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation1.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation2A.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation2B.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation3A.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation3B.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation5A.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation5B.json && \
	$(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation6A.json
	@echo "Graphs generated successfully for all simulations!"


# Generate graphs target for Simulation1
simulation1: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for Simulation1..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation1.json
	@echo "Graphs generated successfully for Simulation1!"

# Generate graphs target for Simulation2A
simulation2A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for Simulation2A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation2A.json
	@echo "Graphs generated successfully for Simulation2A!"

# Generate graphs target for simulation2B
simulation2B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation2B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount.py $(DATA_DIR)/Simulation2B.json
	@echo "Graphs generated successfully for simulation2B!"

# Generate graphs target for simulation3A
simulation3A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation3A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation3A.json
	@echo "Graphs generated successfully for simulation3A!"

# Generate graphs target for simulation3B
simulation3B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation3B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation3B.json
	@echo "Graphs generated successfully for simulation3B!"

# Generate graphs target for simulation4A
#simulation4A: $(VENV_DIR)/bin/activate
#	@echo "Generating graphs for simulation4A..."
#	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4A) $(DATA_DIR)/Simulation4A.json
#	@echo "Graphs generated successfully for simulation4A!"

# Generate graphs target for simulation4B
#simulation4B: $(VENV_DIR)/bin/activate
#	@echo "Generating graphs for simulation4B..."
#	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4B) $(DATA_DIR)/Simulation4B.json
#	@echo "Graphs generated successfully for simulation4B!"

# Generate graphs target for simulation5A
simulation5A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation5A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation5A.json
	@echo "Graphs generated successfully for simulation5A!"

# Generate graphs target for simulation5B
simulation5B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation5B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation5B.json
	@echo "Graphs generated successfully for simulation5B!"

# Generate graphs target for simulation6A
simulation6A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation6A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/simulation_ratio_amount_tick.py  $(DATA_DIR)/Simulation6A.json
	@echo "Graphs generated successfully for simulation6A!"


# Create virtual environment target
$(VENV_DIR)/bin/activate: requirements.txt
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate; pip install -r requirements.txt || true
	@echo "Virtual environment created successfully!"

# Create or update requirements.txt with matplotlib
requirements.txt:
	@echo "Creating or updating requirements.txt with matplotlib..."
	@touch requirements.txt
	@grep -q "matplotlib" requirements.txt || echo "matplotlib" >> requirements.txt

# Clean target
clean:
	@echo "Cleaning up..."
	@rm -rf $(GRAPHS_DIR)/*
	@rm -rf $(VENV_DIR)
	@echo "Cleanup completed!"

# Help target
help:
	@echo "Available targets:"
	@echo "  all             - Generate graphs for Simulation1 (default target)"
	@echo "  simulation2A    - Generate graphs for Simulation2A"
	@echo "  clean           - Clean up generated graphs and virtual environment"
	@echo "  help            - Show this help message"

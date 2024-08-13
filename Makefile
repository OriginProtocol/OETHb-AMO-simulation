# Variables
PYTHON = python3
VENV_DIR = venv
SCRIPT_DIR = script
SCRIPT = simulation1.py
SCRIPT2A = simulation2A.py
SCRIPT2B = simulation2B.py
DATA_DIR = data
GRAPHS_DIR = $(DATA_DIR)/graphs
JSON_FILE1 = Simulation1.json
JSON_FILE2A = Simulation2A.json
JSON_FILE2B = Simulation2B.json

# Default target
all: generate_graphs

# Generate graphs target for Simulation1
generate_graphs: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for Simulation1..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT) $(DATA_DIR)/$(JSON_FILE1)
	@echo "Graphs generated successfully for Simulation1!"

# Generate graphs target for Simulation2A
simulation2A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for Simulation2A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT2A) $(DATA_DIR)/$(JSON_FILE2A)
	@echo "Graphs generated successfully for Simulation2A!"

# Generate graphs target for simulation2B
simulation2B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation2B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT2B) $(DATA_DIR)/$(JSON_FILE2B)
	@echo "Graphs generated successfully for simulation2B!"

# Create virtual environment target
$(VENV_DIR)/bin/activate: requirements.txt
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@. $(VENV_DIR)/bin/activate; pip install -r requirements.txt || true
	@echo "Virtual environment created successfully!"

# Create empty requirements.txt if it doesn't exist
requirements.txt:
	@echo "Creating empty requirements.txt..."
	@touch requirements.txt

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

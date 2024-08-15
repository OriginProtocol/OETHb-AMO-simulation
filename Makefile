# Variables
PYTHON = python3
VENV_DIR = venv
SCRIPT_DIR = script
SCRIPT = simulation1.py
SCRIPT2A = simulation2A.py
SCRIPT2B = simulation2B.py
SCRIPT3A = simulation3A.py
SCRIPT3B = simulation3B.py
SCRIPT4A = simulation4A.py
SCRIPT4B = simulation4B.py
SCRIPT5A = simulation5A.py
SCRIPT5B = simulation5B.py
DATA_DIR = data
GRAPHS_DIR = $(DATA_DIR)/graphs
JSON_FILE1 = Simulation1.json
JSON_FILE2A = Simulation2A.json
JSON_FILE2B = Simulation2B.json
JSON_FILE3A = Simulation3A.json
JSON_FILE3B = Simulation3B.json
JSON_FILE4A = Simulation4A.json
JSON_FILE4B = Simulation4B.json
JSON_FILE5A = Simulation5A.json
JSON_FILE5B = Simulation5B.json

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
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT) $(DATA_DIR)/$(JSON_FILE1) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT2A) $(DATA_DIR)/$(JSON_FILE2A) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT2B) $(DATA_DIR)/$(JSON_FILE2B) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT3A) $(DATA_DIR)/$(JSON_FILE3A) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT3B) $(DATA_DIR)/$(JSON_FILE3B) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4A) $(DATA_DIR)/$(JSON_FILE4A) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4B) $(DATA_DIR)/$(JSON_FILE4B) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT5A) $(DATA_DIR)/$(JSON_FILE5A) && \
	$(PYTHON) $(SCRIPT_DIR)/$(SCRIPT5B) $(DATA_DIR)/$(JSON_FILE5B)
	@echo "Graphs generated successfully for Simulation1!"


# Generate graphs target for Simulation1
simulation1: $(VENV_DIR)/bin/activate
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

# Generate graphs target for simulation3A
simulation3A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation3A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT3A) $(DATA_DIR)/$(JSON_FILE3A)
	@echo "Graphs generated successfully for simulation3A!"

# Generate graphs target for simulation3B
simulation3B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation3B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT3B) $(DATA_DIR)/$(JSON_FILE3B)
	@echo "Graphs generated successfully for simulation3B!"

# Generate graphs target for simulation4A
simulation4A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation4A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4A) $(DATA_DIR)/$(JSON_FILE4A)
	@echo "Graphs generated successfully for simulation4A!"

# Generate graphs target for simulation4B
simulation4B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation4B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT4B) $(DATA_DIR)/$(JSON_FILE4B)
	@echo "Graphs generated successfully for simulation4B!"

# Generate graphs target for simulation5A
simulation5A: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation5A..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT5A) $(DATA_DIR)/$(JSON_FILE5A)
	@echo "Graphs generated successfully for simulation5A!"

# Generate graphs target for simulation5B
simulation5B: $(VENV_DIR)/bin/activate
	@echo "Generating graphs for simulation5B..."
	@. $(VENV_DIR)/bin/activate; $(PYTHON) $(SCRIPT_DIR)/$(SCRIPT5B) $(DATA_DIR)/$(JSON_FILE5B)
	@echo "Graphs generated successfully for simulation5B!"

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

include .env
export

# --- I/O colors ---
GREEN_START = "\033[1;32m"
GREEN_END = "\033[0m"

# ---- Define target paths ----
# R targets
R_LIBS = $(wildcard ./src/lib/*.R)
R_DATA = $(patsubst ./src/data/%.qmd, ./bin/src/data/%.pdf, $(wildcard ./src/data/*.qmd))
R_ANALYSIS = $(patsubst ./src/analysis/%.qmd, ./bin/src/analysis/%.pdf, $(wildcard ./src/analysis/*.qmd))
{%- if cookiecutter.use_stata -%}
# Stata targets
STATA_DATA = $(patsubst ./src/data/%.do, ./bin/src/data/%.log, $(wildcard ./src/data/*.do))
STATA_ANALYSIS = $(patsubst ./src/analysis/%.do, ./bin/src/analysis/%.log, $(wildcard ./src/analysis/*.do))
{% endif %}
# LaTex targets
PDF_FILES = $(patsubst ./tex/%,./bin/tex/%.pdf,$(wildcard ./tex/*)) 


# ---- Main targets ----
all: $(PDF_FILES)
.SECONDARY: $(R_ANALYSIS) $(R_DATA) {% if cookiecutter.use_stata %}$(STATA_ANALYSIS) $(STATA_DATA){% endif %}
.PHONY: all clean fresh clear-cache tests initialize

# ---- Step 1: Data ----
./bin/src/data/%.pdf: ./src/data/%.qmd $(R_LIBS)
	@echo 🗄️ $(GREEN_START)Data processing: $<...$(GREEN_END)
	@quarto render $<
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)
{% if cookiecutter.use_stata -%}
./bin/src/data/%.log: ./src/data/%.do
	@echo 🗄️ $(GREEN_START)Data processing: $<...$(GREEN_END)
	@stata-mp -b do $<
	@mv $(notdir $@) $@
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)
{% endif %}
# Step 2: Analysis
./bin/src/analysis/%.pdf: ./src/analysis/%.qmd $(R_DATA) $(R_LIBS) {% if cookiecutter.use_stata %}$(STATA_DATA){% endif %}
	@echo 📊 $(GREEN_START)Running analysis: $<...$(GREEN_END)
	@quarto render $<
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)
{% if cookiecutter.use_stata %}
./bin/src/analysis/%.log: ./src/analysis/%.do $(STATA_DATA) $(R_DATA) $(R_LIBS)
	@echo 📊 $(GREEN_START)Running analysis: $<...$(GREEN_END)
	@stata-mp -b do $<
	@mv $(notdir $@) $@
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)
{% endif %}
# Step 3: Paper
./bin/tex/%.pdf: ./tex/%/main.tex $(R_DATA) $(R_ANALYSIS) {% if cookiecutter.use_stata %}$(STATA_DATA) $(STATA_ANALYSIS){% endif %}
	@echo 📝 $(GREEN_START)Compiling $< ...$(GREEN_END)
	@mkdir -p ./bin/tex/
	@cd $(dir $<) &&\
	 latexmk -pdf -quiet\
	 -interaction=nonstopmode $(notdir $<)
	@cp $(basename $<).pdf $@
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)

# Clean up intermediate files
clean:
	@echo 🧹 $(GREEN_START)Cleaning up...$(GREEN_END)
	@find ./tex -type f \( -name '*.aux' -o -name '*.bbl' -o -name '*.blg' -o -name '*.fdb_latexmk' -o -name '*.fls' -o -name '*.log' -o -name '*.out' -o -name '*.synctex.gz' \) -delete
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)

# Delete all targets
fresh: 
	@echo 😵 $(GREEN_START)Deleting all targets...$(GREEN_END)
	@find ./bin -type f -name "*.pdf" -delete
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)

# Clear cache of .qmd files
clear-cache: 
	@echo 📦 $(GREEN_START)Clearing cache...$(GREEN_END)
	@find ./src -depth -type d -name "*_cache" -exec rm -rf {} \;
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)

# Run tests
tests: 
	@echo 🧪 $(GREEN_START)Running tests...$(GREEN_END)
	@Rscript -e "testthat::test_dir('tests')"

# Initialize directories
initialize: 
	@echo 🛠️ $(GREEN_START)Initializing directories...$(GREEN_END)
	@mkdir -p ./assets/tables
	@mkdir -p ./assets/figures
	@mkdir -p ./data
	@mkdir -p ./bin/src/data
	@mkdir -p ./bin/src/analysis
	@mkdir -p ./bin/tex
	@echo ✅ $(GREEN_START)Done!$(GREEN_END)

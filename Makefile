export

# --- I/O colors ---
GREEN_START = \033[1;32m
GREEN_END = \033[0m

# ---- Define target paths ----
# R targets
R_LIBS = $(wildcard ./src/lib/*.R)
R_DATA = $(patsubst ./src/data/%.qmd, ./bin/src/data/%.pdf, $(wildcard ./src/data/*.qmd))
R_ANALYSIS = $(patsubst ./src/analysis/%.qmd, ./bin/src/analysis/%.pdf, $(wildcard ./src/analysis/*.qmd))
STATA_DATA = $(patsubst ./src/data/%.do, ./bin/src/data/%.log, $(wildcard ./src/data/*.do))
STATA_ANALYSIS = $(patsubst ./src/analysis/%.do, ./bin/src/analysis/%.log, $(wildcard ./src/analysis/*.do))

# LaTex targets
PDF_FILES = $(patsubst ./tex/%,./bin/tex/%.pdf,$(wildcard ./tex/*)) 


# ---- Main targets ----
all: $(PDF_FILES)
.SECONDARY: $(R_ANALYSIS) $(R_DATA) $(STATA_ANALYSIS) $(STATA_DATA)
.PHONY: all clean fresh clear-cache tests initialize

# ---- functions ----

# build_tex
# -----------
# Compiles a LaTeX file in ./tex/DIR/main.tex and copies the resulting PDF to ./bin/tex/DIR.pdf
# Arguments:
#   $1 - Path to the LaTeX main.tex file (e.g., tex/article/main.tex)
define build_tex
	$(eval TARGET := $(patsubst tex/%/main.tex,bin/tex/%.pdf,$(1)))
	@echo "📝 $(GREEN_START)Compiling $(1) -> $(TARGET)...$(GREEN_END)"
	@mkdir -p ./bin/tex/
	@cd $(dir $(1)) &&\
		latexmk -pdf -quiet\
		-interaction=nonstopmode $(notdir $(1))
	@cp $(basename $(1)).pdf $(TARGET)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef


# build_qmd
# -----------
# Renders a Quarto document (.qmd) and generates a PDF output in the bin directory
# Arguments:
#   $1 - Path to the .qmd file (e.g., src/analysis/main.qmd -> bin/src/analysis/main.pdf)
define build_qmd
	$(eval TARGET := $(patsubst %.qmd,bin/%.pdf,$(1)))
	@echo "📄 $(GREEN_START)Rendering $(1) -> $(TARGET)...$(GREEN_END)"
	@quarto render $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

# build_do
# ----------
# Executes a Stata .do file and moves the resulting .log file to the bin directory
# Arguments:
#   $1 - Path to the .do file (e.g., src/data/data.do -> bin/src/data/data.log)
define build_do
	$(eval TARGET := $(patsubst %.do,bin/%.log,$(1)))
	@echo "📄 $(GREEN_START)Running $(1) -> $(TARGET)...$(GREEN_END)"
	@stata-mp -b do $(1)
	@mkdir -p $(dir $(TARGET))
	@mv $(notdir $(TARGET)) $(TARGET)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

define build_R
	@echo "📄 $(GREEN_START)Running $(1)...$(GREEN_END)"
	@Rscript $(1)
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"
endef

# ---- Step 1: Data ----
./bin/src/data/%.pdf: ./src/data/%.qmd $(R_LIBS)
	@echo "🗄️ $(GREEN_START)Data processing$(GREEN_END)"
	@$(call build_qmd,$<)

# ./bin/src/data/%.log: ./src/data/%.do
# 	@echo "🗄️ $(GREEN_START)Data processing$(GREEN_END)"
# 	@$(call build_stata,$<)

# ---- Step 2: Analysis ----
./bin/src/analysis/%.pdf: ./src/analysis/%.qmd $(R_DATA) $(R_LIBS)
	@echo "📊 $(GREEN_START)Running analysis$(GREEN_END)"
	@$(call build_qmd,$<)

# ./bin/src/analysis/%.log: ./src/analysis/%.do $(STATA_DATA) $(R_LIBS)
# 	@echo "📊 $(GREEN_START)Running analysis$(GREEN_END)"
# 	@$(call build_qmd,$<)

# ---- Step 3: Paper ----
./bin/tex/%.pdf: ./tex/%/main.tex $(R_ANALYSIS) # $(STATA_ANALYSIS)
	@$(call build_tex,$<)

# Clean up intermediate files
clean:
	@echo "🧹 $(GREEN_START)Cleaning up...$(GREEN_END)"
	@find ./tex -type f ! -name '*.tex' -delete
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

# Delete all targets
fresh: 
	@echo "😵 $(GREEN_START)Deleting all targets and intermediary files...$(GREEN_END)"
	@find ./bin -type f -name "*.pdf" -delete
	@find ./bin -type f -name "*.log" -delete
	@find ./bin -type f -name "*.log" -delete
	@find ./assets/tables -type f ! -name ".gitignore" -delete
	@find ./assets/figures -type f ! -name ".gitignore" -delete
	@find ./data/processed -type f ! -name ".gitignore" -delete
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

# Clear cache of .qmd files
clear-cache: 
	@echo ""📦 $(GREEN_START)Clearing cache...$(GREEN_END)""
	@find ./src -depth -type d -name "*_cache" -exec rm -rf {} \;
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

# Run tests
tests: 
	@echo "🧪 $(GREEN_START)Running tests...$(GREEN_END)"
	@Rscript -e "testthat::test_dir('tests')"

# Create symlinks to assets and library.bib in each LaTeX subdirectory
symlinks: 
	@echo "🛠️ $(GREEN_START)Creating symlinks to assets folder and library.bib...$(GREEN_END)"
	@for dir in ./tex/*/; do \
		if [ -d "$$dir" ]; then \
			echo "Creating symlinks in $$dir..."; \
			ln -sf "../../library.bib" "$$dir/library.bib"; \
			ln -sf "../../assets" "$$dir/assets"; \
		fi; \
	done
	@echo "✅ $(GREEN_START)Done!$(GREEN_END)"

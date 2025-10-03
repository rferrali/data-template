# {{ cookiecutter.project_name }}

__{{ cookiecutter.first_name }} {{ cookiecutter.last_name }}, {{ cookiecutter.institution }} <[{{ cookiecutter.email }}](mailto:{{ cookiecutter.email }})>__

## Usage

After install, start the dev container, then open an R session and run: 

```r
# initialize renv
renv::init()
# for a pleasant development experience with VS Code
renv::install(c("httpgd", "languageserver", "ManuelHentschel/vscDebugger"))
# for unit testing
renv::install(c("testthat", "withr"))
# packages required for the demo
renv::install(c("tidyverse", "modelsummary"))
```

In the terminal, if you would like to run the demo with Stata, run:

```bash
# for the demo
stata-mp -b do setup.do
```



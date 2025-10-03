clear
doenv using ".env"
import delimited ./data/data_stata.csv
regress y x1 x2
etable, export("./assets/tables/table_stata.tex", replace tableonly)
coefplot
graph export "./assets/figures/figure_stata.pdf", width(6.2) height(4)
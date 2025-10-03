clear
doenv using ".env"
set obs 300
gen x1 = rnormal()
gen x2 = rnormal()
gen y = x1 - 2 * x2 + rnormal()
export delimited ./data/data_stata.csv
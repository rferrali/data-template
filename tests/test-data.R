testthat::test_that(
  "data.csv has the right properties",
  {
    library(tidyverse)
    withr::local_dir("..")
    df <- read_csv("./data/data.csv")
    testthat::expect_gt(mean(df$x1), -.5)
    testthat::expect_lt(mean(df$x1), .5)
    testthat::expect_gt(sd(df$x1), .5)
    testthat::expect_lt(sd(df$x1), 1.5)
  }
)

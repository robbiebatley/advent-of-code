library(slider)
library(purrr)

input <- file.path("day1", "input.txt") |>
  readLines(warn = FALSE) |>
  as.numeric()

input |>
  diff() |>
  keep(\(x) x > 0) |>
  length()

input |>
  slide_sum(before = 2, complete = TRUE) |>
  discard(is.na) |>
  diff() |>
  keep(\(x) x > 0) |>
  length()

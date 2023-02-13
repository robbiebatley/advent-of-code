library(tidyverse)

input <- file.path("day5", "input.txt") |>
  readLines(warn = FALSE)

# Part 1
tibble(raw = input) |>
  separate(raw, c("from_x", "from_y", "to_x", "to_y"), convert = TRUE) |>
  filter(from_x == to_x | from_y == to_y) |>
  mutate(x = map2(from_x, to_x, seq), y = map2(from_y, to_y, seq)) |>
  unnest(c(x, y)) |>
  count(x, y) |>
  filter(n > 1) |>
  nrow()

# Part 2
tibble(raw = input) |>
  separate(raw, c("from_x", "from_y", "to_x", "to_y"), convert = TRUE) |>
  mutate(x = map2(from_x, to_x, seq), y = map2(from_y, to_y, seq)) |>
  unnest(c(x, y)) |>
  count(x, y) |>
  filter(n > 1) |>
  nrow()

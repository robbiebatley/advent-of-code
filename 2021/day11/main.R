library(purrr)
library(dplyr)

# Input -------------------
parse_input <- function(path){
  path |>
    readLines(warn = FALSE) |>
    strsplit("") |>
    sapply(as.integer) |>
    t()
}

example <- parse_input(file.path("day11", "example.txt"))
input <- parse_input(file.path("day11", "input.txt"))

# Part 1 -----------------
cell_update <- function(flashes, n_row, n_col){
  flashes |>
    as_tibble() |>
    full_join(expand.grid(x = -1:1, y = -1:1), by = character()) |>
    mutate(i = row + x, j = col + y) |>
    filter(i > 0, i <= n_row, j > 0, j <= n_col) |>
    count(i, j)
}

do_step <- function(x){
  x <- x + 1L
  has_flashed <- matrix(FALSE, nrow(x), ncol(x))
  flashes <- which(x > 9 & !has_flashed, arr.ind = TRUE)
  while(nrow(flashes) > 0){
    has_flashed[flashes] <- TRUE
    cell_updates <- cell_update(flashes, nrow(x), ncol(x))
    loc <- as.matrix(cell_updates[, c("i", "j")])
    x[loc] <- x[loc] + cell_updates[["n"]]
    flashes <- which(x > 9 & !has_flashed, arr.ind = TRUE)
  }
  x[x > 9] <- 0
  x
}

count_flashes <- function(input, n_steps){
  n <- 0
  for (step in 1:n_steps){
    input <- do_step(input)
    n <- n + sum(input == 0)
  }
  n
}
testthat::expect_equal(count_flashes(example, 10), 204)
testthat::expect_equal(count_flashes(example, 100), 1656)

count_flashes(input, 100)

# Part 2 ----------
find_sync <- function(input){
  required_flashes <- length(input)
  i <- 0
  while (i < 1000){
    i <- i + 1
    input <- do_step(input)
    if (sum(input == 0) == required_flashes) return(i)
  }
  NA_real_
}
testthat::expect_equal(find_sync(example), 195)

find_sync(input)

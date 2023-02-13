library(tidyverse)
library(tidygraph)

# Input --------------------------

parse_input <- function(file){
  file |>
    readLines(warn = FALSE) |>
    str_split("") |>
    map(as.integer) |>
    reduce(rbind) |>
    unname()
}

example <- parse_input(file.path("day15", "example.txt"))
input <- parse_input(file.path("day15", "input.txt"))


# Part 1 ------------------------
build_graph <- function(input){
  n_nodes <- length(input)
  n_row <- nrow(input)
  n_col <- ncol(input)
  nodes <- tibble(name = seq_len(n_nodes))

  col_offset <- rep(0:(n_col - 1) * n_col, each = n_col - 1)
  x <- rep(1:(n_row - 1), n_col)
  y <- seq_len(n_nodes - n_row)
  edges <-
    # vertical movements
    tibble(from = c(x, x + 1), to = c(x + 1, x)) |>
    mutate(across(c(from, to), `+`, col_offset)) |>
    # horizontal movements
    bind_rows(tibble(from = c(y, y + n_row), to = c(y + n_row, y))) |>
    mutate(weight = input[to])

  tbl_graph(nodes = nodes, edges = edges)
}

find_shortest_path <- function(input){
  input |>
    build_graph() |>
    to_shortest_path(1, length(input), weights = weight) |>
    pluck("shortest_path") %E>%
    mutate(total_dist = sum(weight)) |>
    slice(1) |>
    pull(total_dist)
}

testthat::expect_equal(example |> find_shortest_path(), 40)
input |> find_shortest_path()

# Part 2 ------------------------
expanded_cave <- function(cave){
  cave <- cbind(cave, cave + 1, cave + 2, cave + 3, cave + 4)
  cave <- rbind(cave, cave + 1, cave + 2, cave + 3, cave + 4)
  (cave - 1) %% 9 + 1
}

testthat::expect_equal(example |> expand_cave() |> find_shortest_path(), 315)
input |> expand_cave() |> find_shortest_path()

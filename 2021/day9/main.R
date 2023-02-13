library(tidyverse)

parse_input <- function(path){
  path |>
    readLines(warn = FALSE) |>
    strsplit("") |>
    sapply(as.numeric) |>
    t()
}

example <- parse_input(file.path("day9", "input_example.txt"))
input <- parse_input(file.path("day9", "input.txt"))

# Part 1 --------
find_low_points <- function(x){
  down <- rbind(x[1:(nrow(x) -1), ] < x[2:nrow(x), ], TRUE)
  up <- rbind(TRUE, x[1:(nrow(x) -1), ] >= x[2:nrow(x), ])
  right <- cbind(x[, 1:(ncol(x) -1)] < x[, 2:ncol(x)], TRUE)
  left <- cbind(TRUE, x[, 1:(ncol(x) -1)] >= x[, 2:ncol(x)])
  x[down & up & right & left]
}

part1 <- function(x) sum(find_low_points(x) + 1)
testthat::expect_equal(part1(example), 15)
sum(find_low_points(input) + 1)

# Part 2 ----------------------
find_low_index <- function(x){
  down <- rbind(x[1:(nrow(x) -1), ] < x[2:nrow(x), ], TRUE)
  up <- rbind(TRUE, x[1:(nrow(x) -1), ] >= x[2:nrow(x), ])
  right <- cbind(x[, 1:(ncol(x) -1)] < x[, 2:ncol(x)], TRUE)
  left <- cbind(TRUE, x[, 1:(ncol(x) -1)] >= x[, 2:ncol(x)])
  which(down & up & right & left, arr.ind = TRUE)
}

# BFS tree search
basin_size <- function(x, i, j){
  seen <- list()
  queue <- list(c(i, j))
  size <- 0
  while (length(queue) > 0){
    point <- queue[1]
    queue <- queue[-1]
    if (point %in% seen) next
    seen <- append(seen, point)
    point <- unlist(point)
    val <- x[t(point)]
    if (val == 9) next
    size <- size + 1
    # Add new points to queue
    i <- point[1]
    j <- point[2]
    if (i > 1) queue <- append(queue, list(c(i - 1, j)))
    if (i < nrow(x)) queue <- append(queue, list(c(i + 1, j)))
    if (j > 1) queue <- append(queue, list(c(i, j - 1)))
    if (j < ncol(x)) queue <- append(queue, list(c(i, j + 1)))
  }
  size
}
testthat::expect_equal(basin_size(example, 1, 2), 3)

part2 <- function(input){
  find_low_index(input) |>
    as_tibble() |>
    mutate(size = map2_dbl(row, col, \(x, y) basin_size(input, x, y))) |>
    slice_max(size, n = 3, with_ties = FALSE) |>
    pull(size) |>
    prod()
}

testthat::expect_equal(part2(example), 1134)
part2(input)

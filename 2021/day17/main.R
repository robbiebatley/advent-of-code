library(purrr)
library(stringr)

# Input ---------

bounds <- readLines("day17/input.txt", warn = FALSE) |>
  str_match("target area: x=(?<x>.*), y=(?<y>.*)")

x_bounds <- bounds[, "x"] |>
  str_split_1(fixed("..")) |>
  as.numeric()

y_bounds <- bounds[, "y"] |>
  str_split_1(fixed("..")) |>
  as.numeric()

# Works out number of steps until y is in range given velocity
y_steps <- function(velocity, y_bounds,  y = 0, step = 1, steps = c()){
  new_y <- y + velocity
  if (new_y <= y_bounds[2] & new_y >= y_bounds[1]) steps <- c(steps, step)
  if (new_y < y_bounds[1]) return(steps)
  y_steps(velocity - 1, y_bounds, new_y, step + 1, steps)
}

# Checks if there is an x which would put us in range
x_in_range <- function(steps, x_bounds){
  x_init <- 0
  while(TRUE){
    x_velocity <- seq(from = x_init, by = -1, length.out = steps)
    x <- sum(x_velocity * (x_velocity > 0))
    if (x >= x_bounds[1] & x <= x_bounds[2]) return(TRUE)
    if (x > x_bounds[2]) return(FALSE)
    x_init <- x_init + 1
  }
}

# for a given y velocity checks if there is a solution which lands in box
check_y <- function(velocity, x_bounds, y_bounds){
  steps <- y_steps(velocity, y_bounds)
  any(map_lgl(steps, \(n) x_in_range(n, x_bounds)))
}

max_height <- function(velocity) velocity * (velocity + 1) / 2

testthat::expect_equal(
  keep(1:100, \(v) check_y(v, c(20, 30), c(-10, -5))) |>
    max() |>
    max_height(),
  45
)

keep(1:100, \(v) check_y(v, x_bounds, y_bounds)) |>
  max() |>
  max_height()

# Part 2 -------------------

xs_in_range <- x_in_range <- function(steps, x_bounds){
  out <- vector(mode = "numeric")
  x_init <- 0
  while(TRUE){
    x_velocity <- seq(from = x_init, by = -1, length.out = steps)
    x <- sum(x_velocity * (x_velocity > 0))
    if (x >= x_bounds[1] & x <= x_bounds[2]) out <- c(out, x_init)
    if (x > x_bounds[2]) return(out)
    x_init <- x_init + 1
  }
}

check_y2 <- function(velocity, x_bounds, y_bounds){
  steps <- y_steps(velocity, y_bounds)
  map(steps, \(n) xs_in_range(n, x_bounds)) |>
    as_vector() |>
    unique() |>
    length()
}

testthat::expect_equal(
  map_dbl(-100:100, \(v) check_y2(v, c(20, 30), c(-10, -5))) |>
    sum(),
  112
)

map_dbl(-100:100, \(v) check_y2(v, x_bounds, y_bounds)) |>
  sum()

library(tidyverse)

# Input ---------
parse_input <- function(path){
  raw_input <- readLines(path, warn = FALSE)
  split_index <- which(raw_input == "")

  dots <- raw_input[1:(split_index - 1)] |>
    str_split(",") |>
    map(as.numeric) |>
    map(\(x) complex(real = x[1], imaginary = x[2])) |>
    list_simplify()

  folds <- raw_input[(split_index + 1):length(raw_input)] |>
    str_remove("^fold along ") |>
    str_split("=")

  list("dots" = dots, "folds" = folds)
}

example <- parse_input(file.path("day13", "example.txt"))
input <- parse_input(file.path("day13", "input.txt"))

# Part 1 ------------
fold_y <- function(dots, loc) {
  x <- Re(dots)
  y <- Im(dots)
  moved_dots <- complex(real = x[y > loc], imaginary = 2 * loc - y[y > loc])
  union(dots[y < loc], moved_dots)
}

fold_x <- function(dots, i) {
  x <- Re(dots)
  y <- Im(dots)
  moved_dots <- complex(real = 2 * i - x[x > i], imaginary = y[x > i])
  union(dots[x < i], moved_dots)
}

do_fold <- function(dots, instruction){
  do.call(
    paste0("fold_", instruction[1]),
    list(dots, as.numeric(instruction[2]))
  )
}

testthat::expect_length(do_fold(example$dots, example$folds[[1]]), 17)

do_fold(input$dots, input$folds[[1]]) |>
  length()

# Part 2 -----------
reduce(input$folds, do_fold, .init = input$dots) |>
  enframe(name = NULL, value = "complex") |>
  ggplot(aes(Re(complex), -Im(complex))) +
  geom_tile() +
  theme_void()

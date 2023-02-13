library(tidyverse)

# Input ------
parse_input <- function(path){
  raw <- readLines(path, warn = FALSE)
  algo <- str_split_1(raw[1], "") == "#"
  image <- raw[3:length(raw)] |>
    str_split("") |>
    map(\(x) x == "#") |>
    reduce(rbind) |>
    unname()
  list("algo" = algo, "image" = image)
}

example <- file.path("day20/example.txt") |> parse_input()
input <- file.path("day20/input.txt") |> parse_input()

# Part 1 -----
bitvec_to_num <- function(x) sum(2 ^ seq(length(x)-1, 0) * x)

enhance_pixel <- function(image, algo, i, j){
  index <- image[(i-1):(i+1), (j-1):(j+1)] |>
    t() |>
    as.vector() |>
    bitvec_to_num()
  algo[index + 1]
}

enhance_image <- function(image, algo, default = FALSE){
  image_row <- nrow(image)
  image_col <- ncol(image)
  expanded_image <- matrix(default, image_row + 4, image_col + 4)
  expanded_image[3:(image_row + 2), 3:(image_col + 2)] <- image
  out <- expanded_image
  for (i in seq(2, image_row + 3)){
    for (j in seq(2, image_col + 3)){
      out[i, j] <- enhance_pixel(expanded_image, algo, i, j)
    }
  }
  # Trim excess
  out[seq(2, image_row + 3), seq(2, image_col + 3)]
}

# apply image enhancement n times
enhance_image_n <- function(image, algo, n){
  default_fn <- function(x) FALSE
  if (algo[1]) default_fn <- function(x) !as.logical(x %% 2)
  for (i in seq_len(n)){
    image <- enhance_image(image, algo, default_fn(i))
  }
  image
}

# Part 1 -------
testthat::expect_equal(
  sum(enhance_image_n(example$image, example$algo, 2)),
  35
)

enhance_image_n(input$image, input$algo, 2) |>
  sum()

# Part 2 ------
testthat::expect_equal(
  sum(enhance_image_n(example$image, example$algo, 50)),
  3351
)

enhance_image_n(input$image, input$algo, 50) |>
  sum()

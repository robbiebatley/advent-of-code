library(purrr)

input <- file.path("day3", "input.txt") |>
  readLines(warn = FALSE) |>
  strsplit("") |>
  sapply(as.numeric) |>
  t()

# Part 1
binary_to_int <- function(x) sum(2 ^ seq.int(from = length(x) - 1, to = 0) * x)

more_ones <- colSums(input) > (nrow(input) / 2)
gamma <- binary_to_int(more_ones)
epsilon <- binary_to_int(!more_ones)
gamma * epsilon

# Part 2
most_common <- function(x) as.numeric(sum(x) >= length(x) / 2)

oxygen <- function(input, i = 1){
  if (!is.matrix(input)){
    return(input)
  }
  most_common_digit <- most_common(input[, i])
  input <- input[input[,i] == most_common_digit, ]
  oxygen(input, i + 1)
}

least_common <- function(x) as.numeric(sum(x) < length(x) / 2)
co2 <- function(input, i = 1){
  if (!is.matrix(input)){
    return(input)
  }
  least_common_digit <- least_common(input[, i])
  input <- input[input[,i] == least_common_digit, ]
  co2(input, i + 1)
}

o2_rating <- input |> oxygen() |> binary_to_int()
co2_rating <- input |> co2() |> binary_to_int()

o2_rating * co2_rating

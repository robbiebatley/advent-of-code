library(tidyverse)

# Parse input -------------
parse_input <- function(path){
  path |>
    readLines(warn = FALSE) |>
    enframe(value = "raw", name = NULL) |>
    separate(raw, c("input", "output"), sep = " \\| ") |>
    mutate(across(c(input, output), map, str_split_1, " "))
}

example <- parse_input(file.path("day8", "input_example.txt"))
input <- parse_input(file.path("day8", "input.txt"))

# Part 1 --------------------
part1 <- function(input){
  lengths <- c(2, 4, 3, 7)
  input |>
    select(output) |>
    unnest(output) |>
    mutate(output_length = nchar(output)) |>
    filter(output_length %in% lengths) |>
    nrow()
}

testthat::expect_equal(part1(example), 26)
part1(input)

# Part 2 -----
sort_chars <- function(x){
  x |>
    str_split("") |>
    map(sort) |>
    map_chr(paste, collapse = "")
}
testthat::expect_equal(sort_chars("bac"), "abc")
testthat::expect_equal(sort_chars(c("bac", "fed")), c("abc", "def"))

char_vec <- function(x) str_split_1(x, "")
testthat::expect_equal(char_vec("abc"), c("a", "b", "c"))

char_subset <- function(candidates, chars){
  candidates |>
    keep(\(x) all(chars %in% str_split_1(x, "")))
}
testthat::expect_equal(char_subset(c("acd", "abc", "bcd"), c("a", "b")), "abc")

solve_key <- function(input){
  input <- sort_chars(input)
  one <- input[nchar(input) == 2]
  four <- input[nchar(input) == 4]
  seven <- input[nchar(input) == 3]
  eight <- input[nchar(input) == 7]

  # resolve length 5
  len_5 <- input[nchar(input) == 5]
  three <- char_subset(len_5, char_vec(one))
  five <- char_subset(len_5, setdiff(char_vec(four), char_vec(one)))
  two <- setdiff(len_5, c(three, five))

  len_6 <- input[nchar(input) == 6]
  six <- setdiff(len_6, char_subset(len_6, char_vec(one)))
  nine <- char_subset(len_6, char_vec(four))
  zero <- setdiff(len_6, c(six, nine))
  out <- 0:9
  names(out) <- c(zero, one, two, three, four, five, six, seven, eight, nine)
  out
}

decipher <- function(x, key){
  sum(key[sort_chars(x)] * 10 ^ seq(length(x) - 1, 0))
}

part2 <- function(input){
  input |>
    mutate(
      key = map(input, solve_key),
      plain_text = map2_dbl(output, key, decipher)
    ) |>
    pull(plain_text) |>
    sum()
}

testthat::expect_equal(part2(example),61229)

part2(input)

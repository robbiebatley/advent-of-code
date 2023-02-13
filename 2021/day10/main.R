library(collections)
library(purrr)

# Input ------
parse_input <- function(path){
  path |>
    readLines(warn = FALSE) |>
    strsplit("")
}

example <- parse_input(file.path("day10", "example.txt"))
input <- parse_input(file.path("day10", "input.txt"))

# Part 1 -------
opens <- c("(", "[", "{", "<")
closes <- c(")", "]", "}", ">")
scores <- c(")" = 3, "]" = 57, "}" = 1197, ">" = 25137)

find_corrupted_char <- function(x){
  s <- stack()
  for (c in x){
    if (c %in% opens){
      s$push(c)
      next
    }
    if (s$size() == 0) return(c)
    m <- opens[closes == c]
    if (s$pop() != m) return(c)
  }
  NA_character_
}

part1 <- function(input){
  illegal_chars <- input |>
    map_chr(find_corrupted_char) |>
    discard(is.na)

  sum(scores[illegal_chars])
}

testthat::expect_equal(part1(example), 26397)
part1(input)

# Part 2 -------

complete_seq <- function(x){
  s <- stack()
  for (c in x){
    if (c %in% opens){
      s$push(c)
      next
    }
    if (s$size() == 0) return(NA_character_)
    m <- opens[closes == c]
    if (s$pop() != m) return(NA_character_)
  }
  s$as_list() |>
    list_simplify() |>
    map_chr(\(x) closes[x == opens])
}

testthat::expect_equal(complete_seq(example[[1]]),
                       c("}", "}", "]", "]", ")", "}", ")", "]"))

score <- function(x){
  scores <- c(")" = 1, "]" = 2, "}" = 3, ">" = 4)
  reduce(x, \(x, y) 5*x + scores[y], .init = 0) |>
    unname()
}

testthat::expect_equal(score(complete_seq(example[[1]])), 288957)

part2 <- function(input){
  input |>
    map(complete_seq) |>
    discard(anyNA) |>
    map_dbl(score) |>
    median()
}

testthat::expect_equal(part2(example), 288957)

part2(input)

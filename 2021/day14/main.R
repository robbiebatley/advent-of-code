library(tidyverse)

parse_input <- function(path){
  raw <- readLines(path, warn = FALSE)

  chars <- str_split_1(raw[1], "")
  n_chars <- length(chars)
  pairs <- tibble(
   a = chars[seq_len(n_chars - 1)],
   b = chars[seq(2, n_chars)]
  ) |>
    count(a, b)

  rules <- tibble(raw = raw[seq(3, length(raw))]) |>
    separate(raw, c("pair", "to"), sep = " -> ") |>
    separate(pair, c("a", "b"), sep = 1) |>
    select(a, b, to)

  list(pairs = pairs, rules = rules, last_char = chars[n_chars])
}

example <- parse_input(file.path("day14", "example.txt"))
input <- parse_input(file.path("day14", "input.txt"))

do_step <- function(pairs, rules){
  matches <- pairs |>
    left_join(rules, by = c("a", "b"))

  left <- matches |>
    select(a, b = to, n)

  right <- matches |>
    select(a = to, b, n)

  bind_rows(left, right) |>
    group_by(a, b) |>
    summarise(n = sum(n), .groups = "drop")
}

do_n_steps <- function(pairs, rules, n){
  reduce(seq_len(n), \(x, y) do_step(x, rules), .init = pairs)
}

count_chars <- function(pairs, last_char){
  pairs |>
    select(char = a, n) |>
    group_by(char) |>
    summarise(n = sum(n), .groups = "drop") |>
    mutate(n = if_else(char == last_char, n + 1L, n))
}

do_n_steps(example$pairs, example$rules, 10) |>
  count_chars(example$last_char)

part1 <- function(input, n_steps){
  do_n_steps(input$pairs, input$rules, n_steps) |>
    count_chars(input$last_char) |>
    summarise(answer = max(n) - min(n)) |>
    pull(answer)
}

testthat::expect_equal(part1(example, 10), 1588)

part1(input, 10)

# Part 2 ------------------
op <- options("scipen" = 99)
part1(input, 40)
options(op)

library(tidyverse)

input <- file.path("day4", "input.txt") |>
  readLines(warn = FALSE)

numbers <- input[1] |>
  stringr::str_split_1(",") |>
  as.numeric()

parse_boards <- function(input){
  tibble(raw = input[-1]) |>
    mutate(board = cumsum(raw == "")) |>
    filter(raw != "") |>
    group_by(board) |>
    mutate(row = row_number()) |>
    ungroup() |>
    separate_rows(raw, sep = " ", convert = TRUE) |>
    filter(!is.na(raw)) |>
    group_by(board, row) |>
    mutate(col = row_number()) |>
    ungroup() |>
    select(board, row, col, number = raw) |>
    mutate(called = FALSE)
}

update_board <- function(boards, number_called){
  boards |>
    mutate(called = if_else(number == number_called, TRUE, called))
}

check_bingo <- function(boards){
  called_numbers <- boards |> filter(called == TRUE)

  row_bingo <- called_numbers |>
    count(board, row) |>
    filter(n == 5) |>
    select(board)

  col_bingo <- called_numbers |>
    count(board, col) |>
    filter(n == 5) |>
    select(board)

  bind_rows(row_bingo, col_bingo)
}

play_bingo <- function(boards, numbers, round = 1) {
  boards <- update_board(boards, numbers[round])
  bingo <- check_bingo(boards)
  if (nrow(bingo) > 0){
    winning_boards <- boards |>
      semi_join(bingo, by = "board") |>
      mutate(number_called = numbers[round])
    return(winning_boards)
  }
  play_bingo(boards, numbers, round + 1)
}

input |>
  parse_boards() |>
  play_bingo(numbers) |>
  filter(called == FALSE) |>
  group_by(board, number_called) |>
  summarise(sum_numbers = sum(number), .groups = "drop") |>
  mutate(final_score = number_called * sum_numbers) |>
  pull(final_score)

# Part 2
play_bingo2 <- function(boards, numbers, round = 1) {
  boards <- update_board(boards, numbers[round])
  bingo <- check_bingo(boards)
  if (n_distinct(boards$board) == n_distinct(bingo$board)){
    losing_boards <- boards |>
      mutate(number_called = numbers[round])
    return(losing_boards)
  }
  boards <- anti_join(boards, bingo, by = "board")
  play_bingo2(boards, numbers, round + 1)
}

input |>
  parse_boards() |>
  play_bingo2(numbers) |>
  filter(called == FALSE) |>
  group_by(board, number_called) |>
  summarise(sum_numbers = sum(number), .groups = "drop") |>
  mutate(final_score = number_called * sum_numbers) |>
  pull(final_score)

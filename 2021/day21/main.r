library(tidyverse)
library(R6)

# Input ---------
read_start_position <- function(path){
  match <- path |>
    read_lines() |>
    str_match("Player [1|2] starting position: (?<start>\\d+)")
  as.numeric(match[, "start"])
}

example <- file.path("day21/example.txt")  |>
  read_start_position()

input <- file.path("day21/input.txt")  |>
  read_start_position()

# Game ----------
mod1p <- function(x, n) (x - 1) %% n + 1

DeterministicDice <- R6Class(
  "DeterministicDice",
  public = list(
    initialize = function(){
      private$rolls <- 0
      private$state <- 0
    },
    roll = function(){
      private$rolls <- private$rolls + 3
      out <- private$state + 1:3
      private$state <- out[3]
      sum(out)
    },
    get_roll_count = function() private$rolls
  ),
  private = list(
    rolls = NULL,
    state = NULL
  )
)

DiracDice <- R6Class(
  "DiracDice",
  public = list(
    dice = NULL,
    pos = NULL,
    score = NULL,
    next_player = NULL,
    n_players = NULL,
    n_turns = NULL,
    weight = NULL,
    initialize = function(start_pos, dice){
      self$pos <- start_pos
      self$score <- rep(0, length(start_pos))
      self$dice <- dice$new()
      self$next_player <- 1
      self$n_turns <- 0
      self$weight <- 1
    },
    turn = function(roll = self$dice$roll()){
      player <- self$next_player
      new_pos <- mod1p(self$pos[player] + roll, 10)
      self$pos[player] <- new_pos
      self$score[player] <- self$score[player] + new_pos
      self$next_player <- mod1p(player + 1, length(self$score))
      self$n_turns <- self$n_turns + 1
      invisible(self)
    },
    play = function(winning_score){
      while (max(self$score) < winning_score){
        self$turn()
      }
      invisible(self)
    },
    update_weight = function(w){
      self$weight <- self$weight * w
      invisible(self)
    }
  )
)

# Part 1 -------------
part1 <- function(start_pos){
  game <- DiracDice$new(start_pos, DeterministicDice)$play(1000)
  min(game$score) * game$dice$get_roll_count()
}

testthat::expect_equal(part1(example), 739785)

part1(input)

# Part 2 --------------

# General approach is to consider how many paths lead to player x winning in y turns
DummyDice <- R6Class(
  "DummyDice",
  public = list(initialize = function()invisible(self))
)

# Figure out number of turns to get to a score of 21
turns_to_win <- function(start_pos){
  rolls <- 3:9
  weights <- c(1, 3, 6, 7, 6, 3, 1)
  out <- vector(mode = "numeric", length = 20)
  queue <- list(DiracDice$new(start_pos, DummyDice))
  while (length(queue) > 0){
    game <- queue[[1]]
    queue <- queue[-1]
    turn <- game$n_turns + 1
    games <- map2(rolls, weights, \(x, y) game$clone()$turn(x)$update_weight(y))
    finished_games <- games |>
      keep(\(x) x$score >= 21) |>
      map_dbl(\(x) x$weight) |>
      sum()
    if (finished_games > 0) out[turn] <- out[turn] + finished_games
    queue <- games |>
      keep(\(x) x$score < 21) |>
      c(queue)
  }
  # Clean up output
  out <- enframe(out, name = "turns", value = "terminal_paths") |>
    filter(terminal_paths > 0)
  # Figure out how many paths are still live at each turn
  live_paths <- vector(mode = "numeric", length = nrow(out))
  live_paths[1] <- 27 ^ out$turns[1] - out$terminal_paths[1]
  for (i in 2:nrow(out)){
    live_paths[i] <- 27 * live_paths[i - 1] - out$terminal_paths[i]
  }
  out$live_paths <- live_paths
  out
}

player1 <- turns_to_win(example[1])
player2 <- turns_to_win(example[2])

testthat::expect_equal(
  sum(player1$terminal_paths * lag(player2$live_paths, default = 27^2)),
  444356092776315
)
testthat::expect_equal(
  sum(player2$terminal_paths * player1$live_paths),
  341960390180808
)

player1 <- turns_to_win(input[1])
player2 <- turns_to_win(input[2])

player1_wins <- sum(player1$terminal_paths * lag(player2$live_paths, default = 27^2))
player2_wins <- sum(player2$terminal_paths * player1$live_paths)

op <- options("scipen" = 99)
max(player1_wins, player2_wins)
options(op)

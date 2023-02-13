library(tidyverse)
library(zeallot)

# Parse input ---------
# Inputs seem reasonably dense, store as matrix
parse_input <- function(path){
  path |>
    read_lines() |>
    str_trim() |>
    str_split("") |>
    reduce(rbind) |>
    unname()
}

example <- file.path("day25", "example.txt") |>
  parse_input()

input <- file.path("day25", "input.txt") |>
  parse_input()

# Part 1 ----------
mod1p <- function(x, n) (x - 1) %% n + 1

do_step <- function(seafloor){

  # East herd
  current_loc <- which(seafloor == ">", arr.ind = TRUE)
  next_loc <- cbind(
    current_loc[, "row"],
    mod1p(current_loc[, "col"] + 1, ncol(seafloor))
  )
  can_move <- seafloor[next_loc] == "."
  seafloor[current_loc[can_move, , drop = FALSE]] <- "."
  seafloor[next_loc[can_move, , drop = FALSE]] <- ">"
  cucumbers_moved <- sum(can_move)

  # South herd
  current_loc <- which(seafloor == "v", arr.ind = TRUE)
  next_loc <- cbind(
    mod1p(current_loc[, "row"] + 1, nrow(seafloor)),
    current_loc[, "col"]
  )
  can_move <- seafloor[next_loc] == "."
  seafloor[current_loc[can_move, , drop = FALSE]] <- "."
  seafloor[next_loc[can_move, , drop = FALSE]] <- "v"
  cucumbers_moved <- cucumbers_moved + sum(can_move)

  list(seafloor, cucumbers_moved)
}

solve_p1 <- function(seafloor){
  i <- 0
  repeat {
    i <- i + 1
    c(seafloor, cucumbers_moved) %<-% do_step(seafloor)
    if (cucumbers_moved == 0) return(i)
  }
}

testthat::expect_equal(example |> solve_p1(), 58)

input |> solve_p1()

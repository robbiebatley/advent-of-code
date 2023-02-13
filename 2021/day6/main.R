library(purrr)

# simulate 1 fish from 6
sim_1fish <- function(steps){
  out <- vector("list", steps)
  start_fish <- rep(0, 9)
  start_fish[7] <- 1
  out[[1]] <- start_fish
  for (i in 2:length(out)){
    prev_fish <- out[[i - 1]]
    n_new_fish = prev_fish[1]
    new_fish <- c(prev_fish[2:9], n_new_fish)
    new_fish[7] <- new_fish[7] + n_new_fish
    out[[i]] <- new_fish
  }
  map_dbl(out, sum)
}

sim_fish <- function(input, steps){
  fish_growth <- sim_1fish(steps + 6)
  map_dbl(input, function(x) fish_growth[steps + 7 - x]) |>
    sum()
}

input <- file.path("day6", "input.txt")  |>
  readLines(warn = FALSE) |>
  stringr::str_split(",", simplify = TRUE) |>
  as.numeric()

# Part 1
sim_fish(input, 80)

# Part 2
op <- options("scipen" = 99)
sim_fish(input, 256)
options(op)

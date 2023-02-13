library(tidyverse)

# Input -------
parse_start_position <- function(path){
  path |>
    read_lines() |>
    keep_at(3:4) |>
    str_remove_all("#| ") |>
    str_split("") |>
    list_transpose()
}

example <- file.path("day23/example.txt") |> parse_start_position()
input <- file.path("day23/input.txt") |> parse_start_position()

# Part 1 ----------

# Represent state of system using a numeric vector where first position holds score
# I.e.
# score: 1
# #################
# #23. 4. 5. 6. 78#
# ###9 #11#13#15##
#   #10#12#14#16#
#   #############

starting_state <- function(x){
  out <- vector(mode = "numeric", length = 16)
  # Score
  out[1] <- 0
  # amphipod starting position
  out[9:16] <- x |>
    as_vector() |>
    map_dbl(\(x) which(x == LETTERS[1:4]))
  out
}

exit_chamber <- function(state, i, chamber_loc = get_chamber){
  loc <- chamber_loc(i)
  chamber <- state[loc]
  if (all(chamber %in% c(0, i))) return(NULL)
  # Find first filled spot
  dist_to_door <- 1
  while (chamber[dist_to_door] == 0) dist_to_door <- dist_to_door + 1
  amphipod <- chamber[dist_to_door]
  state[loc[dist_to_door]] <- 0
  cost_per_step <- 10 ^ (amphipod - 1)
  # check which states can move to
  out <- vector(mode = "list", length = 7)
  # chambers to left
  cost <- state[1] + (dist_to_door - 1) * cost_per_step
  for (j in seq(i + 1, 1, -1)){
    # If space is blocked stop moving
    if (state[j + 1] != 0) break
    if (j == 1) cost <- cost + cost_per_step
    else cost <- cost + 2 * cost_per_step
    out[[j]] <- state
    out[[j]][1] <- cost
    out[[j]][j + 1] <- amphipod
  }
  # chambers to right
  cost <- state[1] + (dist_to_door - 1) * cost_per_step
  for (j in seq(i+2, 7)){
    # If space is blocked stop moving
    if (state[j + 1] != 0) break
    if (j == 7) cost <- cost + cost_per_step
    else cost <- cost + 2 * cost_per_step
    out[[j]] <- state
    out[[j]][1] <- cost
    out[[j]][j + 1] <- amphipod
  }
  out |> discard(is.null)
}

enter_chamber <- function(state, i, chamber_loc = get_chamber) {
  # Check if amphipod of type i is in hallway
  if (!i %in% state[2:8]) return(NULL)
  # Check if there is free spot to move into chamber
  c_loc <- chamber_loc(i)
  chamber <- state[c_loc]
  if (any(!chamber %in% c(0, i))) return(NULL)
  cost_per_step <- 10 ^ (i - 1)
  # Adjust state to allow for movement from into chamber
  dist_to_door <- length(chamber)
  while (chamber[dist_to_door] != 0) dist_to_door <- dist_to_door - 1
  state[1] <- state[1] + (dist_to_door - 1) * cost_per_step
  state[c_loc[dist_to_door]] <- i
  loc <- which(state[2:8] == i) + 1
  out <- vector(mode = "list", length = length(loc))
  for (j in seq_along(loc)) {
    l <- loc[j]
    new_state <- state
    new_state[l] <- 0
    # determine route to door
    if (l <= i + 2) route <- seq(l, i + 2, 1)
    else route <- seq(i + 3, l, 1)
    if (any(new_state[route] != 0)) next
    new_state[1] <-
      state[1] + (2 * length(route) - any(l %in% c(2, 8))) * cost_per_step
    new_state[l] <- 0
    out[[j]] <- new_state
  }
  out |> discard(is.null)
}

get_neighbours <- function(state, chamber_loc = get_chamber){
  c(
    map(1:4, \(i) exit_chamber(state, i, chamber_loc)),
    map(1:4, \(i) enter_chamber(state, i, chamber_loc))
  ) |>
    list_flatten() |>
    discard(is_null)
}

next_node <- function(h){
  best <- Inf
  state <- NULL
  maphash(h, \(k, v){
    if (!is.null(v) && v < best) {
      best <<- v
      state <<- k
    }
  })
  c(best, state)
}

dijkstra <- function(start, end, chamber_loc = get_chamber){
  state_index <- seq(2, length(start))
  queue <- hashtab()
  sethash(queue, start[state_index], start[1])
  while (length(queue) > 0) {
    state <- next_node(queue)
    remhash(queue, state[state_index])
    if (all(state[state_index] == end)) return(state[1])
    neighbours <- get_neighbours(state, chamber_loc)
    for (n in neighbours){
      current <- gethash(queue, n[state_index], nomatch = Inf)
      if (n[1] < current) sethash(queue, n[state_index], n[1])
    }
  }
}

get_chamber <- function(i) 7:8 + 2 * i

target <- c(0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4)

input |>
  starting_state() |>
  dijkstra(target, get_chamber)

# Part 2 -------------

get_chamber2 <- function(i) 5:8 + 4 * i

target2 <- c(rep(0, 7), rep(1, 4), rep(2, 4), rep(3, 4), rep(4, 4))

starting_state2 <- function(input) {
  orig <- input |> starting_state()
  c(orig[1:9], 4, 4, orig[10:11], 3, 2, orig[12:13], 2, 1, orig[14:15], 1, 3, orig[16])
}

input |>
  starting_state2() |>
  dijkstra(target2, get_chamber2)

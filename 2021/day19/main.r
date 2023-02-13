library(tidyverse)

# Read input
parse_input <- function(path){
  path |>
    readLines(warn = FALSE) |>
    enframe(name = NULL) |>
    mutate(scanner = cumsum(value == "")) |>
    filter(
      str_starts(value, "--- scanner", negate = TRUE),
      value != ""
    ) |>
    mutate(value = map(str_split(value, ","), as.numeric)) |>
    group_by(scanner) |>
    summarise(value = list(value)) |>
    pull(value)
}

example <- file.path("day19/example.txt") |>
  parse_input()

input <- file.path("day19/input.txt") |>
  parse_input()

# Construct all possible rotations
rotate <- function(x, y, z){
  # Rotation matrix for 90 degrees
  Rx1 <- matrix(c(1, 0, 0, 0, 0, 1, 0, -1, 0), 3, 3)
  Ry1 <- matrix(c(0, 0, -1, 0, 1, 0, 1, 0, 0), 3, 3)
  Rz1 <- matrix(c(0, 1, 0, -1, 0, 0, 0, 0, 1), 3, 3)

  `%^%` <- function(x, n) reduce(replicate(n, x, simplify = FALSE), `%*%`)

  Rx <- Rx1 %^% x
  Ry <- Ry1 %^% y
  Rz <- Rz1 %^% z

  Rx %*% Ry %*% Rz
}

rotations <- expand_grid(x = 1:4, y = 1:4, z=1:4) |>
  pmap(rotate) |>
  unique()

# Check if there is a translation which matches 12 or more beacons
translate_beacons <- function(a, b){
  # Checking for 12 or more matching points
  for (i in seq_along(a)){
    for (j in seq_along(b)){
      delta <- a[[i]] - b[[j]]
      b_d <- map(b, \(x) x + delta)
      n_matches <- sum(a %in% b_d)
      if (n_matches >= 12){
        return(list("scanner_location" = delta, "beacons" = b_d))
      }
    }
  }
  NULL
}

match_beacons <- function(a, b){
  # Trying all rotations of b
  for (r in rotations){
    b_r <- map(b, \(x) as.vector(x %*% r))
    matched <- translate_beacons(a, b_r)
    if (!is.null(matched)) return(matched)
  }
  NULL
}

position_scanners <- function(beacons){
  n_scanners <- length(beacons)
  scanner_location <- vector(mode = "list", length = n_scanners)
  scanner_location[[1]] <- c(0, 0, 0)
  queue <- 1
  while (length(queue) > 0){
    print(glue::glue("matching on scanner {queue[1] - 1}"))
    known_beacons <- beacons[[queue[1]]]
    queue <- queue[-1]
    for (i in seq_along(scanner_location)){
      if (!is.null(scanner_location[[i]])) next
      print(glue::glue("  checking scanner {i - 1}"))
      matched_beacons <- match_beacons(known_beacons, beacons[[i]])
      if (is.null(matched_beacons)) next
      print(glue::glue("    matched scanner {i - 1}"))
      queue <- union(queue, i)
      # shift matched scanner to be on same coordinate system as first scanner
      beacons[[i]] <- matched_beacons$beacons
      scanner_location[[i]] <- matched_beacons$scanner_location
    }
  }
  list("scanner_location" = scanner_location, "beacons" = beacons)
}

example_scanners <- position_scanners(example)
input_scanners <- position_scanners(input)

# Part 1 -----------
part1 <- function(beacons){
  beacons |>
    list_flatten() |>
    unique() |>
    length()
}
testthat::expect_equal(part1(example_scanners$beacons), 79)

part1(input_scanners$beacons)

# Part 2 --------
part2 <- function(scanner_location){
  expand_grid(a = scanner_location, b = scanner_location) |>
    mutate(dist = map2_dbl(a, b, \(x, y) sum(abs(x - y)))) |>
    summarise(max_dist = max(dist)) |>
    pull(max_dist)
}
testthat::expect_equal(part2(example_scanners$scanner_location), 3621)

part2(input_scanners$scanner_location)

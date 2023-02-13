library(stringr)
library(purrr)
library(R7)

input <- file.path("day2", "input.txt") |>
  readLines(warn = FALSE)

extract_movements <- function(input, pattern){
  re <- regex(paste0(pattern, " (\\d+)"))
  str_match(input, re)[,2] |>
    discard(is.na) |>
    as.numeric() |>
    sum()
}

horizontal <- extract_movements(input, "forward")
vertical <- extract_movements(input, "down") - extract_movements(input, "up")
horizontal * vertical

# Part 2
submarine <- new_class(
  "submarine",
  properties = list(
    horizontal = class_numeric,
    vertical = class_numeric,
    aim = class_numeric
  )
)

forward <- new_generic("forward", "s", function(s, x) R7_dispatch())
method(forward, submarine) <- function(s, x){
  s@horizontal <- s@horizontal + x
  s@vertical <- s@vertical + x * s@aim
  s
}

down <- new_generic("down", "s", function(s, x) R7_dispatch())
method(down, submarine) <- function(s, x){
  s@aim <- s@aim + x
  s
}

up <- new_generic("up", "s", function(s, x) R7_dispatch())
method(up, submarine) <- function(s, x){
  s@aim <- s@aim - x
  s
}

move_submarine <- function(s, instruction){
  instruction <- unlist(strsplit(instruction, " "))
  fn <- instruction[1]
  x <- as.numeric(instruction[2])
  do.call(fn, list(s, x))
}

sub <- reduce(input, move_submarine, .init = submarine(0, 0, 0))
sub@horizontal * sub@vertical

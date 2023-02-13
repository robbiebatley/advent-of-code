library(tidyverse)

# Input ----------------------
parse_input <- function(path) {
  path |>
    read_lines() |>
    as_tibble() |>
    transmute(
      state = (str_extract(value, "^(on|off)") == "on"),
      cube = value |>
        str_remove_all("on |off |x=|y=|z=") |>
        str_replace_all(fixed(".."), ",") |>
        str_split(",") |>
        map(as.numeric)
    )
}

example <- file.path("day22/example.txt") |> parse_input()
example2 <- file.path("day22/example2.txt") |> parse_input()
input <- file.path("day22/input.txt") |> parse_input()

# Part 1 -----------------------------
is_initialisation_cube <- function(cube)
  all(abs(cube) <= 50)

# do a and b overlap
cube_overlap <- function(a, b) {
  all(a[1] <= b[2], a[2] >= b[1],
      a[3] <= b[4], a[4] >= b[3],
      a[5] <= b[6], a[6] >= b[5])
}

# does a contain b
cube_contains <- function(a, b) {
  all(a[1] <= b[1], a[2] >= b[2],
      a[3] <= b[3], a[4] >= b[4],
      a[5] <= b[5], a[6] >= b[6])
}

split_axis <- function(a, b) {
  if (b[1] <= a[1]) {
    if (b[2] >= a[2])
      return(list(a))
    return(list(c(a[1], b[2]), c(b[2] + 1, a[2])))
  }
  if (b[2] >= a[2])
    return(list(c(a[1], b[1] - 1), c(b[1], a[2])))
  list(c(a[1], b[1] - 1), c(b[1], b[2]), c(b[2] + 1, a[2]))
}

# split cube a where b intersect and removes any cube that overlaps b
split_cube <- function(a, b) {
  expand_grid(x = split_axis(a[1:2], b[1:2]),
              y = split_axis(a[3:4], b[3:4]),
              z = split_axis(a[5:6], b[5:6])) |>
    pmap(c) |>
    discard(\(x) cube_conatins(b, x))
}

reboot <- function(input) {
  active_cubes <- list()
  for (j in seq_len(nrow(input))) {
    state <- input[["state"]][j]
    cube <- input[["cube"]][[j]]
    active_cubes <- active_cubes |>
      # Remove all cubes contained within current cube
      discard(\(x) cube_conatins(cube, x)) |>
      # split any overlapping cubes
      map(\(x) {
        if (cube_overlap(cube, x))
          return(split_cube(x, cube))
        x
      }) |>
      # Add current cube if required
      c(if (state)
        list(cube)) |>
      list_flatten()

    print(glue::glue("step {j}: Number active cubes {length(active_cubes)}"))
  }
  active_cubes
}

# Calculate how many nodes are on after reboot
n_nodes_on <- function(df) {
  df |>
    reboot() |>
    map_dbl(\(x) (x[2] - x[1] + 1) * (x[4] - x[3] + 1) * (x[6] - x[5] + 1)) |>
    sum()
}

testthat::expect_equal(example |>
                         filter(map_lgl(cube, is_initialisation_cube)) |>
                         n_nodes_on(),
                       590784)

testthat::expect_equal(n_nodes_on(example2), 2758514936282235)

# Part 1 ------
input |>
  filter(map_lgl(cube, is_initialisation_cube)) |>
  n_nodes_on()

# Part 2 ------
op <- options("scipen" = 99)
n_nodes_on(input)
options(op)

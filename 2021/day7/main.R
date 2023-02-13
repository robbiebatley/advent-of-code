
input <- file.path("day7", "input.txt") |>
  readLines(warn = FALSE) |>
  stringr::str_split_1(",") |>
  as.numeric()

# Median minimises L1 loss
(input - median(input)) |> abs() |> sum()

# Part 2
loss <- function(x, y){
  diff = abs(x - y)
  sum(diff * (diff + 1) / 2)
}

x_optim <- optimise(loss, c(min(input), max(input)), y = input)

c(floor(x_optim$minimum), ceiling(x_optim$minimum)) |>
  purrr::map_dbl(loss, input) |>
  min()

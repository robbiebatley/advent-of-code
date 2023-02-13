library(tidyverse)

# Parse input --------
input <- file.path("day24/input.txt") |>
  read_lines()

# Instructions repeat 14 times with only three differences
# Below is general pattern:
# inp w
# mul x 0
# add x z
# mod x 26
# div z (shift 1 | 26)
# add x (integer i)
# eql x w
# eql x 0
# mul y 0
# add y 25
# mul y x
# add y 1
# mul z y
# mul y 0
# add y w
# add y (integer j)
# mul y x
# add z y

# This simplifies to the following function
# which is essentially adding or removing digits to 26 base number
# (add if shift == 1 or subtracting if shift == 26)
f <- function(z, w, i, j, shift){
  z_new <- z
  if (shift == 26) z_new <- trunc(z / 26)
  # This condition will increase order of z
  # so need to avoid when shift == 26
  if ((z %% 26) + i != w) return(26 * z_new + w + j)
  z_new
}

# To make two ops cancel out need the following to hold
# w1 + j1 + i2 = w2
# E.g.
map_dbl(0:10, \(x){
  x |>
    f1(w = 9, i = 15, j = 2, 1) |>
    f1(w = 2, i = -9, j = 6, 26)
})

# Pull out instructions which change on at each step
input_tidy <- input |>
  enframe(name = NULL, value = "raw") |>
  mutate(iter = cumsum(str_detect(raw, "inp "))) |>
  group_by(iter) |>
  mutate(id = row_number()) |>
  ungroup() |>
  filter(id %in% c(5, 6, 16)) |>
  mutate(id = case_when(id == 5 ~ "shift",
                        id == 6 ~ "i",
                        id == 16 ~ "j")) |>
  pivot_wider(names_from = id, values_from = raw) |>
  mutate(across(
    c(shift, i, j),
    \(x) str_remove_all(x, "(div|add) [x-z] ") |> as.numeric()
  ))

# Pair inputs which will cancel each other out
a <- vector(mode = "numeric", length = 7)
b <- vector(mode = "numeric", length = 7)
index <- 1
stack <- c()
for (i in 1:14){
  if (input_tidy$shift[i] == 1) stack <- c(i, stack)
  else {
    a[index] <- stack[1]
    b[index] <- i
    stack <- stack[-1]
    index <- index + 1
  }
}

valid_digits <- tibble(a, b) |>
  inner_join(input_tidy |> select(a = iter, j), by = "a") |>
  inner_join(input_tidy |> select(b = iter, i), by = "b") |>
  crossing(digit_a = 1:9, digit_b = 1:9) |>
  filter(digit_a + j + i == digit_b)

# Part 1 ---------------
max_digits <- valid_digits |>
  group_by(a) |>
  slice_max(digit_a, n = 1) |>
  ungroup()

bind_rows(
  max_digits |> select(index = a, digit = digit_a),
  max_digits |> select(index = b, digit = digit_b)
) |>
  arrange(index) |>
  pull(digit) |>
  paste0(collapse = "")

# Part 2 ---------------
min_digits <- valid_digits |>
  group_by(a) |>
  slice_min(digit_a, n = 1) |>
  ungroup()

bind_rows(
  min_digits |> select(index = a, digit = digit_a),
  min_digits |> select(index = b, digit = digit_b)
) |>
  arrange(index) |>
  pull(digit) |>
  paste0(collapse = "")

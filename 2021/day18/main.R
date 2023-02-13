library(tidyverse)

# Input -------
parse_list <- function(str){
  str <-str |>
    str_replace_all(fixed("["), fixed("list(")) |>
    str_replace_all(fixed("]"), fixed(")"))
  eval(parse(text = str))
}

input <- file.path("day18/input.txt") |>
  readLines(warn = FALSE) |>
  map(parse_list)

# Part 1 -------
add_pair1 <- function(l, r) list(l, r)

testthat::expect_equal(
  add_pair1(parse_list("[1,2]"), parse_list("[[3,4],5]")),
  parse_list("[[1,2],[[3,4],5]]")
)

# pluck sometimes returns weird values
vec_index <- function(x, i) reduce(i, `[[`, .init = x)

# Build list of indexes
get_indicies <- function(x){
  n_elements <- length(unlist(x))
  indexes <- vector(mode = "list", length = n_elements)
  i <- 1L
  index <- 1L
  while (i <= n_elements){
    while (is.list(vec_index(x, index))){
      index <- c(index, 1L)
    }
    indexes[[i]] <- index
    while (i < n_elements){
      if (index[length(index)] == 1L){
        index[length(index)] <- 2L
        break
      }
      index <- index[1L:(length(index) - 1L)]
    }
    i <- i + 1L
  }
  indexes
}

explode <- function(x){
  indexes <- get_indicies(x)
  for (i in seq_along(indexes)){
    # No explosion
    index <- indexes[[i]]
    if (length(index) <= 4) next
    # Has number to left
    if (i > 1){
      l <- indexes[[i-1]] |> as.list()
      pluck(x, !!!l) <- pluck(x, !!!l) + vec_index(x, index)
    }
    # Has number to right
    if (i < length(indexes) - 1){
      r <- indexes[[i+2]] |> as.list()
      pluck(x, !!!r) <- pluck(x, !!!r) + vec_index(x, indexes[[i+1]])
    }
    index <- index[1:(length(index) -1)] |> as.list()
    pluck(x, !!!index) <- 0
    return(x)
  }
  x
}

testthat::expect_equal(
  parse_list("[[[[[9,8],1],2],3],4]") |>
    explode(),
  parse_list("[[[[0,9],2],3],4]")
)

testthat::expect_equal(
  parse_list("[7,[6,[5,[4,[3,2]]]]]") |>
    explode(),
  parse_list("[7,[6,[5,[7,0]]]]")
)

testthat::expect_equal(
  parse_list("[[6,[5,[4,[3,2]]]],1]") |>
    explode(),
  parse_list("[[6,[5,[7,0]]],3]")
)

testthat::expect_equal(
  parse_list("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]") |>
    explode(),
  parse_list("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
)

testthat::expect_equal(
  parse_list("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]") |>
    explode(),
  parse_list("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
)

splits <- function(x){
  indexes <- get_indicies(x)
  for (i in seq_along(indexes)){
    index <- indexes[[i]] |> as.list()
    val <- pluck(x, !!!index)
    if (val <= 9) next
    pluck(x, !!!index) <- list(val %/% 2, val %/% 2 + val %%2)
    return(x)
  }
  x
}

reduce_pair <- function(x){
  x_new <- explode(x)
  if (!identical(x_new, x)) return(reduce_pair(x_new))
  x_new <- splits(x)
  if (!identical(x_new, x)) return(reduce_pair(x_new))
  x
}

add_pair <- function(l, r){
  add_pair1(l, r) |> reduce_pair()
}

testthat::expect_equal(
  add_pair(parse_list("[[[[4,3],4],4],[7,[[8,4],9]]]"), parse_list("[1,1]")),
  parse_list("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
)

testthat::expect_equal(
  c("[1,1]", "[2,2]", "[3,3]", "[4,4]") |>
    map(parse_list) |>
    reduce(add_pair),
  parse_list("[[[[1,1],[2,2]],[3,3]],[4,4]]")
)

testthat::expect_equal(
  c("[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]") |>
    map(parse_list) |>
    reduce(add_pair),
  parse_list("[[[[3,0],[5,3]],[4,4]],[5,5]]")
)

testthat::expect_equal(
  c("[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]") |>
    map(parse_list) |>
    reduce(add_pair),
  parse_list("[[[[5,0],[7,4]],[5,5]],[6,6]]")
)

testthat::expect_equal(
  c(
    "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
    "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
    "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
    "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
    "[7,[5,[[3,8],[1,4]]]]",
    "[[2,[2,2]],[8,[8,1]]]",
    "[2,9]",
    "[1,[[[9,3],9],[[9,0],[0,7]]]]",
    "[[[5,[7,4]],7],1]",
    "[[[[4,2],2],6],[8,7]]"
  ) |>
    map(parse_list) |>
    reduce(add_pair),
  parse_list("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")
)

magnitude <- function(x){
  l <- x[[1]]
  r <- x[[2]]
  if (is.list(l)) l <- magnitude(l)
  if (is.list(r)) r <- magnitude(r)
  3 * l + 2 * r
}

testthat::expect_equal(
  "[[1,2],[[3,4],5]]" |>
    parse_list() |>
    magnitude(),
  143
)

testthat::expect_equal(
  "[[1,2],[[3,4],5]]" |>
    parse_list() |>
    magnitude(),
  143
)

testthat::expect_equal(
  "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]" |>
    parse_list() |>
    magnitude(),
  1384
)

testthat::expect_equal(
  "[[[[1,1],[2,2]],[3,3]],[4,4]]" |>
    parse_list() |>
    magnitude(),
  445
)

testthat::expect_equal(
  "[[[[3,0],[5,3]],[4,4]],[5,5]]" |>
    parse_list() |>
    magnitude(),
  791
)

testthat::expect_equal(
  "[[[[5,0],[7,4]],[5,5]],[6,6]]" |>
    parse_list() |>
    magnitude(),
  1137
)

testthat::expect_equal(
  "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]" |>
    parse_list() |>
    magnitude(),
  3488
)


final_sum <- reduce(input, add_pair)

final_sum |> magnitude()

# Part 2 -------

# Algorithm is very slow but will eventually get the answer
best <- 0
n <- length(input)
for (i in seq_len(n)){
  for (j in seq_len(n)){
    if (i == j) next
    m <- add_pair(input[[i]], input[[j]]) |>
      magnitude()
    if (m > best) best <- m
  }
}
best


library(tidyverse)
library(R6)

# Part 1 -------------------

hex_lookup <- c(
  "0" = "0000",
  "1" = "0001",
  "2" = "0010",
  "3" = "0011",
  "4" = "0100",
  "5" = "0101",
  "6" = "0110",
  "7" = "0111",
  "8" = "1000",
  "9" = "1001",
  "A" = "1010",
  "B" = "1011",
  "C" = "1100",
  "D" = "1101",
  "E" = "1110",
  "F" = "1111"
)

hex_to_binary <- function(hex){
  hex |>
    str_split_1("") |>
    map_chr(\(x) hex_lookup[x == names(hex_lookup)]) |>
    str_split("") |>
    unlist() |>
    as.integer()
}
testthat::expect_equal(
  "D2FE28" |> hex_to_binary() |> paste(collapse = ""),
  "110100101111111000101000"
)

binary_to_int <- function(bin){
  sum(bin * 2 ^ c((length(bin)-1):0))
}

# Using R6 class so that we can keep track of where we are up to when processing
# binary string
Transmission <- R6Class(
  "Transmission",
  public = list(
    binary = NULL,
    index = 1,
    initialize = function(hex){
      self$binary <- hex_to_binary(hex)
    },
    parse_packet = function(){
      version <- private$read_int(3)
      type <- private$read_int(3)
      # literal
      if (type == 4){
        value = private$read_literal()
        return(list("version" = version, "type" = type, "value" = value))
      } 
      # operators
      length_type_id <- private$read_int(1)
      if (length_type_id == 0){
        values <- list()
        n_bits <- private$read_int(15)
        stop_index <- self$index + n_bits
        while (self$index < stop_index){
          values <- c(values, list(self$parse_packet()))
        }
        return(list("version" = version, "type" = type, "value" = values))
      }
      n_packets <- private$read_int(11)
      values <- vector(mode = "list", length = n_packets)
      for (i in seq_len(n_packets)){
        values[[i]] <- self$parse_packet()
      }
      list("version" = version, "type" = type, "value" = values)
    }
  ),
  private = list(
    read_int = function(len){
      i <- self$index
      self$index <- i + len
      binary_to_int(self$binary[i:(i + len - 1)])
    },
    read_literal = function(){
      start_index <- self$index
      # number of digits in packet
      n_digits <- min(which(self$binary[seq(start_index, length(self$binary), by = 5)] == 0))
      end_index <- start_index + 5 * n_digits - 1
      loc <- setdiff(seq(start_index, end_index), seq(start_index, end_index, by = 5))
      self$index <- end_index + 1
      binary_to_int(self$binary[loc])
    }
  )
)

testthat::expect_equal(
  Transmission$new("D2FE28")$parse_packet(),
  list("version" = 6, "type" = 4, "value" = 2021)
)

Transmission$new("38006F45291200")$parse_packet()
Transmission$new("EE00D40C823060")$parse_packet()

sum_versions <- function(x){
  v <- x$version
  if (!is.list(x$value)) return(v)
  v + sum(purrr::map_int(x$value, sum_versions))
}

part1 <- function(hex){
  Transmission$new(hex)$parse_packet() |> sum_versions()
}

testthat::expect_equal(part1("8A004A801A8002F478"), 16)
testthat::expect_equal(part1("C0015000016115A2E0802F182340"), 23)
testthat::expect_equal(part1("A0016C880162017C3686B18A3D4780"), 31)

readLines("day16/input.txt", warn = FALSE) |>
  part1()

# Part 2 ------

do_ops <- function(x){
  type <- x$type
  if (type == 4) return(x$value)
  op <- c("sum", "prod", "min", "max", "identity", ">", "<", "==")[type + 1]
  do.call(op, purrr::map(x$value, do_ops)) |> 
    as.numeric()
}

part2 <- function(hex){
  Transmission$new(hex)$parse_packet() |> do_ops()
}

testthat::expect_equal(part2("C200B40A82"), 3)
testthat::expect_equal(part2("04005AC33890"), 54)
testthat::expect_equal(part2("880086C3E88112"), 7)
testthat::expect_equal(part2("CE00C43D881120"), 9)
testthat::expect_equal(part2("D8005AC2A8F0"), 1)
testthat::expect_equal(part2("F600BC2D8F"), 0)
testthat::expect_equal(part2("9C005AC2F8F0"), 0)
testthat::expect_equal(part2("9C0141080250320F1802104A08"), 1)

readLines("day16/input.txt", warn = FALSE) |>
  part2()

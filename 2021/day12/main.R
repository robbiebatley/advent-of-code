# Input --------
get_edges <- function(path) {
  edge_df <- path |>
    readr::read_delim("-", col_types = "cc", col_names = c("from", "to"))

  edges <- c(edge_df$to, edge_df$from)
  names(edges) <- c(edge_df$from, edge_df$to)
  # Remove paths back to start or from end
  edges[edges != "start" & names(edges) != "end"]
}

example <- get_edges(file.path("day12", "example.txt"))
example2 <- get_edges(file.path("day12", "example2.txt"))
example3 <- get_edges(file.path("day12", "example3.txt"))
input <- get_edges(file.path("day12", "input.txt"))

# Part 1 -------
get_neighbours <- function(edges, node) unname(edges[names(edges) == node])
testthat::expect_setequal(get_neighbours(example, "start"), c("A", "b"))

is_lower <- function(x) tolower(x) == x

dfs <- function(input, node = "start", path = c()){
  if (node == "end") return(1)
  if (is_lower(node) && node %in% path) return(0)
  path <- c(path, node)
  path <- c(path, node)
  neighbours <- get_neighbours(input, node)
  out <- 0
  for (n in neighbours){
    out <- out + dfs(input, n, path)
  }
  out
}

testthat::expect_equal(dfs(example), 10)
testthat::expect_equal(dfs(example2), 19)
testthat::expect_equal(dfs(example3), 226)

dfs(input)

# Part 2 --------

# DFS avoids need to keep track of all paths
dfs2 <- function(input, node = "start", path = c(), dup = NULL){
  if (node == "end") return(1)
  if (is_lower(node) && node %in% path){
    if (!is.null(dup)) return(0)
    dup <- node
  }
  path <- c(path, node)
  neighbours <- get_neighbours(input, node)
  out <- 0
  for (n in neighbours){
    out <- out + dfs(input, n, path, dup)
  }
  out
}
testthat::expect_equal(dfs2(example), 36)
testthat::expect_equal(dfs2(example2), 103)
testthat::expect_equal(dfs2(example3), 3509)

dfs2(input)

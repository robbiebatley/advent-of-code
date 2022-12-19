input = readlines("day12/input.txt")

"""Convert input into matrix with hieghts, starting coordinates and end coordinates"""
parse_input = function(input)

    input = [input[i][j] for i in eachindex(input), j in eachindex(input[1])]

    start_index = findfirst(x -> x == 'S', input)
    end_index = findfirst(x -> x == 'E', input)

    # Convert chars to int
    input[start_index] = 'a'
    input[end_index] = 'e'
    char_match = Dict(v => i for (i, v) in enumerate('a':'z'))
    out = [char_match[input[i, j]] for i in 1:size(input)[1], j in 1:size(input)[2]]    

    out, start_index, end_index
end

grid, start_index, end_index = parse_input(input)

# Part 1 --------
"""Calculate vector of valid moves based on current location"""
valid_moves = function(grid::Matrix, index::CartesianIndex)
    rows, cols = size(grid)
    current_level = grid[index]
    [(-1,0), (1,0), (0,-1), (0, 1)] |>
        x -> [CartesianIndex(index[1] + p, index[2] + q) for (p, q) in x] |>
        x -> filter(x -> 1 <= x[1] <= rows && 1 <= x[2] <= cols, x) |>
        x -> filter(x -> grid[x] <= current_level + 1, x)
end

""" Caculate minimum number of steps to get to end """
shortest_path = function(grid::Matrix, start_index::CartesianIndex, end_index::CartesianIndex)
    visited = Set([start_index])
    queue = [(start_index, 0)]
    while length(queue) > 0
        # Need to do FIFO so that shorter paths processed first
        index, dist = popat!(queue, 1)
        if (index == end_index) 
            return dist
        end
        for neighbour in valid_moves(grid, index)
            (neighbour in visited) && continue
            push!(queue, (neighbour, dist + 1))
            push!(visited, neighbour)
        end
    end
    -1
end

shortest_path(grid, start_index, end_index)

# Part 2 ----------
findall(x -> x == 1, grid) |>
    x -> map(y -> shortest_path(grid, y, end_index), x) |>
    x -> filter(y -> y > 0, x) |>
    minimum

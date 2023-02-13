using DataStructures

Coord = Tuple{Int, Int}

# Input ------------------------
function parse_input(path)
    Dict(
        (i, j) => parse(Int, c)
        for (i, r) in enumerate(readlines(path)) 
            for (j, c) in enumerate(r)
    )
end

example = parse_input("day15/example.txt")
input = parse_input("day15/input.txt")

# Part 1 -----------------------
function get_neighbours(node, n_row, n_col)
    x, y = node
    ((x + δx, y + δy) 
        for (δx,δy)  in ((0, 1), (0, -1), (1, 0), (-1, 0)) 
            if 1 <= x + δx <= n_row && 1 <= y + δy <= n_col
    )
end

function dijkstra(cave)
    n_row = maximum(x for (x, _) in keys(cave))
    n_col = maximum(y for (_, y) in keys(cave))
    max_dist = sum(values(cave))
    dist = DefaultDict{Coord, Int}(max_dist)
    dist[(1,1)] = 0
    pq = PriorityQueue{Coord, Int}()
    pq[(1,1)] = 0
    while !isempty(pq)
        node = dequeue!(pq)
        for new_node in get_neighbours(node, n_col, n_row)
            new_dist = dist[node] + cave[new_node]
            dist[new_node] < new_dist && continue
            dist[new_node] = new_dist
            pq[new_node] = new_dist
        end
    end
    dist[(n_row, n_col)]
end

dijkstra(example)
dijkstra(input)

# Part 2 ----------------------------
function expand_cave(cave)
    n_row = maximum(x for (x, _) in keys(cave))
    n_col = maximum(y for (_, y) in keys(cave))
    new_cave = Dict{Coord, Int}()
    for (key, val) in cave, δx in 0:4, δy in 0:4
        x, y = key
        new_cave[(x + δx * n_row, y + δy * n_col)] = mod1(val + δx + δy, 9)
    end
    new_cave
end

example |> expand_cave |> dijkstra
input |> expand_cave |> dijkstra

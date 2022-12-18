input = readlines("day16/input.txt")

# Parse input
parse_line = function(line)
    r = r"Valve (?<node>\w+) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<to>.*)"
    node, rate, to = match(r, line)
    rate = parse(Int64, rate)
    to = strip.(split(to, ","))
    node, rate, to
end

parse_input = function(input)
    flow_rates = Dict{String, Int64}()
    edges = Dict{String, Vector{String}}()
    for line in input
        node, rate, to = parse_line(line)
        edges[node] = to
        if rate > 0
            flow_rates[node] = rate
        end
    end
    flow_rates, edges
end

flow_rate, edges = parse_input(input)

# Input contains lots of values with zero flow rate. 
# Reduce dimensionality of problem by just considering non-zero valves

""" Calculate distance between nodes """
shortest_path = function(edges::Dict{String, Vector{String}}, start_node::String, end_node::String)
    visited = Set([start_node])
    queue = [(start_node, 0)]
    while length(queue) > 0
        # Need to do FIFO so that shorter paths processed first
        node, dist = popat!(queue, 1)
        if (node == end_node) 
            return dist
        end
        for neighbour in edges[node]
            (neighbour in visited) && continue
            push!(queue, (neighbour, dist + 1))
            push!(visited, neighbour)
        end
    end
    -1
end

distance_to_nodes = Dict{Tuple{String, String}, Int64}()
for from in push!(collect(keys(flow_rate)), "AA"), to in keys(flow_rate)
    (from == to) && continue
    distance_to_nodes[(from, to)] = shortest_path(edges, from, to)
end

# Breadth first search through nodes
search = function(flow_rate, distance_to_nodes)

    all_nodes = flow_rate |> keys |> collect
    states = Dict{Tuple{String, Set{String}}, Int64}()
    queue = [("AA", Set(all_nodes), 0, 0)]

    while length(queue) > 0
        current_node, unvisited_nodes, pressure, time = popat!(queue, 1)

        # Keep track of best pressure for current set of node
        if !haskey(states, (current_node, unvisited_nodes))
            states[(current_node, unvisited_nodes)] = pressure
        elseif states[(current_node, unvisited_nodes)] < pressure
            states[(current_node, unvisited_nodes)] = pressure
        end

        for node in unvisited_nodes
            new_time = time + distance_to_nodes[(current_node, node)] + 1
            (new_time > 30) && continue
            new_pressure = pressure + flow_rate[node] * (30 - new_time)
            remaining_nodes = setdiff(unvisited_nodes, Set([node]))
            push!(queue, (node, remaining_nodes, new_pressure, new_time))
        end
    end
    states
end



maximum(values(states))

# Part 2
all_nodes = flow_rate |> keys |> collect
states = Dict{Tuple{String, Set{String}}, Int64}()
queue = [("AA", Set(all_nodes), 0, 0)]

while length(queue) > 0
    current_node, unvisited_nodes, pressure, time = popat!(queue, 1)

    # Keep track of best pressure for current set of node
    if !haskey(states, (current_node, unvisited_nodes))
        states[(current_node, unvisited_nodes)] = pressure
    elseif states[(current_node, unvisited_nodes)] < pressure
        states[(current_node, unvisited_nodes)] = pressure
    end

    for node in unvisited_nodes
        new_time = time + distance_to_nodes[(current_node, node)] + 1
        (new_time > 26) && continue
        new_pressure = pressure + flow_rate[node] * (26 - new_time)
        remaining_nodes = setdiff(unvisited_nodes, Set([node]))
        push!(queue, (node, remaining_nodes, new_pressure, new_time))
    end
end
states


# Work out best solution by nodes remaining
best_states = Dict{Set{String}, Int64}()
for (key, value) in states
    state = Set(setdiff(all_nodes, key[2]))
    if !haskey(best_states, state)
        best_states[state] = value
    elseif best_states[state] < value
        best_states[state] = value
    end
end
best_states

# Loop through all non-overlapping states
best_score = 0
for (s1, v1) in best_states, (s2, v2) in best_states
    length(intersect(s1, s2)) > 0 && continue
    if v1 + v2 > best_score
        best_score = v1 + v2
    end
end
best_score

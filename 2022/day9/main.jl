
input = readlines("day9/input.txt")

# Expand to individual steps
movements = begin

    # Steps for heads
    head_movement = Dict(
        'L' => (-1, 0),
        'R' => (1, 0),
        'D' => (0, -1),
        'U' => (0, 1)
    )

    out = Vector{Tuple{Int64, Int64}}()
    for i in input
        step_vec = head_movement[i[1]]
        n_times = parse(Int16, i[3:end])
        append!(out, repeat([step_vec], n_times))
    end
    out
end

# Part 1 --------------------------------
update_tail = function(head::Tuple{Int, Int}, tail::Tuple{Int, Int})
    diff = head .- tail
    if any(abs.(diff) .== 2)
        tail = tail .+ sign.(diff)
    end
    tail
end

head = tail = (0, 0)
tail_locations = Set([(0, 0)])
for move in movements
    head = head .+ move
    tail = update_tail(head, tail)
    push!(tail_locations, tail)
end

length(tail_locations)

# Part 2 -------------------------------
knots = repeat([(0,0)], 10)
tail_locations = Set([(0, 0)])
for move in movements
    knots[1] = knots[1] .+ move
    for i in 2:10
        knots[i] = update_tail(knots[i-1], knots[i])
    end
    push!(tail_locations, knots[10])
end

length(tail_locations)
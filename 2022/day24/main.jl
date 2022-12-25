struct Coordinate
    x::Int16
    y::Int16
end

struct Blizzard
    coordinates::Coordinate
    direction::Coordinate
end

struct Valley
    blizzards::Vector{Vector{Coordinate}}
    edges::Vector{Coordinate}
    from::Coordinate
    to::Coordinate
end

struct elves
    turn::Int64
    loc::Coordinate
end

parse_input = function(input)

    direction_map = Dict(
        '>' => Coordinate(0, 1),
        '<' => Coordinate(0, -1),
        '^' => Coordinate(-1, 0),
        'v' => Coordinate(1, 0)
    )

    edges = Vector{Coordinate}()
    blizzards = Vector{Blizzard}()
    for (x, row) in enumerate(input)
        for (y, value) in enumerate(row)
            coord = Coordinate(x, y)
            if value == '#'
                push!(edges, coord)
            elseif value in keys(direction_map)
                push!(blizzards, Blizzard(coord, direction_map[value]))
            end
        end
    end

    start_x = 1
    start_y = findfirst(x -> x == '.', input[start_x])
    from = Coordinate(start_x, start_y)

    end_x = length(input)
    end_y = findfirst(x -> x == '.', input[end_x])
    to = Coordinate(end_x, end_y)

    # Simulate blizzard cycle
    x_min, x_max = extrema(edge.x for edge in edges)
    y_min, y_max = extrema(edge.y for edge in edges)
    
    length_x_cycle = x_max - x_min - 1
    length_y_cycle = y_max - y_min - 1
    length_blizzard_cycle = lcm(length_x_cycle, length_y_cycle)

    # Simulate blizzard cycle
    move_blizzard = function(b::Blizzard, x_min, x_max, y_min, y_max)
        d = b.direction
        x = b.coordinates.x + d.x
        if x == x_max
            x = x_min + 1
        elseif x == x_min
            x = x_max - 1
        end
        y = b.coordinates.y + d.y
        if y == y_max
            y = y_min + 1
        elseif y == y_min
            y = y_max - 1
        end
        Blizzard(Coordinate(x, y), d)
    end

    blizzard_cycle = [[b.coordinates for b in blizzards]]
    for i ∈ 1:(length_blizzard_cycle - 1)
        blizzards = map(x -> move_blizzard(x, x_min, x_max, y_min, y_max), blizzards)
        push!(blizzard_cycle, [b.coordinates for b in blizzards])
    end

    # Stop elves moving off board
    push!(edges, Coordinate(start_x - 1, start_y))
    push!(edges, Coordinate(end_x + 1, end_y))

    Valley(blizzard_cycle, edges, from, to)
end

get_blizzard = function(valley, turn)
    cycle_length = length(valley.blizzards)
    index = mod(turn, cycle_length) + 1
    valley.blizzards[index]
end

bfs = function(valley, start_turn, start_pos, end_pos)

    seen = Set{elves}()
    queue = [elves(start_turn, start_pos)]
    while length(queue) > 0
        elf = popfirst!(queue)
        if elf in seen
            continue
        end
        push!(seen, elf)
        loc = elf.loc
        if loc == end_pos
            return elf.turn
        end

        turn = elf.turn + 1
        blizzards = get_blizzard(valley, turn)

        # Add possible moves to queue
        for (x, y) in ((0, 1), (0, -1), (1, 0), (-1, 0))
            next_loc = Coordinate(elf.loc.x + x, elf.loc.y + y)
            if next_loc in valley.edges
                continue
            elseif next_loc in blizzards
                continue
            end
            push!(queue, elves(turn, next_loc))
        end

        # Option to stay in same location if no blizzard moves here
        if !(loc in blizzards)
            push!(queue, elves(turn, loc))
        end
    end
end

input = readlines("day24/input.txt")
valley = parse_input(input)
n_turns = bfs(valley, 0, valley.from, valley.to)
turns_to_return = bfs(valley, n_turns, valley.to, valley.from)
n_turns_trip2 = bfs(valley, turns_to_return, valley.from, valley.to)

println("Part 1: $n_turns")
println("Part 2: $n_turns_trip2")

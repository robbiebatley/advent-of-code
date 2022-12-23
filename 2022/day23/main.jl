parse_input = function(input)
    out = Vector{Tuple{Int64, Int64}}()
    for i in eachindex(input)
        for j in eachindex(input[i])
            if input[i][j] == '#'
                push!(out, (j, i))
            end
        end
    end
    out
end

propose_move = function(loc, elves, directions)
    # No neighbouring elves
    if !any([loc .+ (x, y) in elves for x in -1:1, y in -1:1 if x != 0 || y != 0])
        return loc
    end
    for direction in directions
        if !any([(loc .+ δ) in elves for δ in direction])
            return loc .+ direction[1]
        end
    end
    loc
end

cycle_direction! = function(directions)
    x = popfirst!(directions)
    push!(directions, x)
end

resolve_proposals! = function(elves, proposed_moves)
    number_moves = 0
    for (elf, loc) in enumerate(elves)
        new_loc = proposed_moves[elf]
        n_elves = length(findall(x -> x == new_loc, proposed_moves))
        if n_elves == 1 && new_loc != loc
            elves[elf] = new_loc
            number_moves += 1
        end
    end
    number_moves
end

play_round! = function(elves, directions)
    proposed_moves = map(x -> propose_move(x, elves, directions), elves)
    number_moves = resolve_proposals!(elves, proposed_moves)
    cycle_direction!(directions)
    number_moves
end

# Part 1
input = readlines("day23/input.txt")
elves = parse_input(input)
directions = [
    ((0, -1), (-1, -1), (1, -1)), #N
    ((0, 1), (-1, 1), (1, 1)), #S
    ((-1, 0), (-1, 1), (-1, -1)), #W
    ((1, 0), (1, 1), (1, -1)), #E
]

for _ in 1:10
    moves = play_round!(elves, directions)
end

x_min, x_max = extrema([x for (x, y) in elves])
y_min, y_max = extrema([y for (x, y) in elves])
(x_max - x_min + 1) * (y_max - y_min + 1) - length(elves)

# Part 2
input = readlines("day23/input.txt")
elves = parse_input(input)
directions = [
    ((0, -1), (-1, -1), (1, -1)), #N
    ((0, 1), (-1, 1), (1, 1)), #S
    ((-1, 0), (-1, 1), (-1, -1)), #W
    ((1, 0), (1, 1), (1, -1)), #E
]
round = 0
moves = 99
while (moves > 0)
    round += 1
    moves = play_round!(elves, directions)
end
round
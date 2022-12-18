input = readline("day17/input.txt")

# Chamber
mutable struct Chamber
    columns::Vector{Set{Int64}}
    jet_idx::Int64
end

Chamber() = Chamber(
    [
        Set([0]),
        Set([0]),
        Set([0]),
        Set([0]),
        Set([0]),
        Set([0]),
        Set([0]),
    ],
    1
)

height = function(c::Chamber)
    maximum(maximum.(c.columns))
end

struct Shape
    x::Vector{Int64}
    y::Vector{Int64}
end

# Coordinates of shapes
const shapes = [
    Shape([3, 4, 5, 6], [1,1,1,1]), # _
    Shape([3, 4, 4, 4, 5], [2,3,2,1,2]), # +
    Shape([3, 4, 5, 5, 5], [1,1,1,2,3]), # _|
    Shape([3, 3, 3, 3], [1,2,3,4]), # |
    Shape([3, 3, 4, 4], [1,2,1,2]), # box
]

"""Get shape for round based on round number"""
get_shape = function(round)
    index = mod(round - 1, 5) + 1
    deepcopy(shapes[index])
end


"""Get starting coordinates for rock"""
start_rock = function(chamber, round)
    delta_height = height(chamber) + 3
    rock = get_shape(round)
    rock.y .+= delta_height
    rock
end

"""Can rock move down"""
can_go_down = function(chamber, rock)

    # bottom in each column
    bottom = Dict{Int64, Int64}()
    for (x, y) in zip(rock.x, rock.y)
        if !haskey(bottom, x) 
            bottom[x] = y
            continue
        end
        if bottom[x] > y
            bottom[x] = y
        end
    end

    for (x, y) in bottom
        y - 1 in chamber.columns[x] && return false
    end
    true
end

move_down! = function(rock)
    rock.y .-= 1
    rock
end

can_go_left = function(chamber, rock)
    # left in each row
    left = Dict{Int64, Int64}()
    for (x, y) in zip(rock.x, rock.y)
        if !haskey(left, y) 
            left[y] = x
            continue
        end
        if left[y] > x
            left[y] = x
        end
    end

    for (y, x) in left
        x - 1 <= 0 && return false
        y in chamber.columns[x-1] && return false
    end
    true
end

move_left! = function(rock)
    rock.x .-= 1
    rock
end

can_go_right = function(chamber, rock)
    # rightmost point in each row
    right = Dict{Int64, Int64}()
    for (x, y) in zip(rock.x, rock.y)
        if !haskey(right, y) 
            right[y] = x
            continue
        end
        if right[y] < x
            right[y] = x
        end
    end

    for (y, x) in right
        x + 1 >= 8 && return false
        y in chamber.columns[x+1] && return false
    end
    true
end

move_right! = function(rock)
    rock.x .+= 1
    rock
end

jet_direction! = function(chamber)
    index = mod(chamber.jet_idx - 1, length(input)) + 1
    chamber.jet_idx += 1
    input[index]
end

add_rock! = function(chamber, rock)
    for (x, y) in zip(rock.x, rock.y)
        push!(chamber.columns[x], y)
    end
end

"""Simulate round and return new index for jet location"""
simulate_round! = function(chamber, round)
    rock = start_rock(chamber, round)
    while true
        # Jets moving rocks
        jet = jet_direction!(chamber)
        if jet == '>'
            can_go_right(chamber, rock) && move_right!(rock)
        else
            can_go_left(chamber, rock) && move_left!(rock)
        end

        # rock falling
        if can_go_down(chamber, rock)
            move_down!(rock) 
        else
            add_rock!(chamber, rock)
            break
        end
    end
end

# Store height of each column
simulation = function(rounds)
    chamber = Chamber()
    for round in 1:rounds
        simulate_round!(chamber, round)
    end
    height(chamber)
end

# Part 1 ---------------------
simulation(2022)

# Part 2 ---------------------
# Eventually there probably is a cycle in the simulation
# where floor of the cave looks the same above the lowest column.
# If we can find where cycle repeats and heights for each point in cycle
# then we can do math to figure out height after arbitary high number of rounds
get_cycle = function(rounds)
    
    chamber = Chamber()
    heights = Vector{Int64}()
    floor_shape = Dict(deepcopy(chamber.columns) => 0)
    for round in 1:rounds
        simulate_round!(chamber, round)
        push!(heights, height(chamber))
        
        # Check if we've done a full cycle
        if mod(chamber.jet_idx - 1, length(input)) == 0 && mod(round - 1, 5) == 0
            # Make copy of chamber from perspective of lowest column
            _chamber = deepcopy(chamber.columns)
            lowest_column = minimum(maximum.(_chamber))
            for i in eachindex(_chamber)
                _chamber[i] = filter(x -> x >= lowest_column, _chamber[i])
                _chamber[i] = Set([x - lowest_column for x in _chamber[i]])
            end
            # If we've seen the shape before we have a cycle
            if _chamber in keys(floor_shape)
                return heights, floor_shape[_chamber], round
            else 
                floor_shape[_chamber] = round
            end
        end
    end
    heights
end

# Figure out how many repeats of cycle we need and
# where in cycle we'd be after required number of rounds
# Note that cycle doesn't necessarily start at round 1
n_rounds = 1000000000000
height, start_idx, end_idx = get_cycle(n_rounds)
cycle_length = end_idx - start_idx
cycle_height = height[end] - height[start_idx]
cycle_repeats = div(n_rounds - start_idx, cycle_length)
cycle_idx = mod(n_rounds - start_idx - 1, cycle_length) + 1
if cycle_idx == cycle_length
    cycle_repeats -= 1
end
cycle_end = height[start_idx + cycle_idx]

cycle_end + cycle_height * cycle_repeats

parse_input = function(input)
    # Construct board using matrix
    board = input[1:(end - 2)]
    number_cols = maximum(length.(board))
    board = rpad.(board, number_cols)
    board = [board[i][j] for i in eachindex(board), j in 1:number_cols]
    # Convert instructions to vector
    instructions = input[end]
    instructions = [instructions[i] for i in findall(r"(\d+|L|R)", instructions)]
    board, instructions
end

""" Find starting location """
start_loc = function(board)
    for i in 1:size(board)[2]
        if board[1, i] == '.'; return (1, i); end
    end
end

""" Take 1 step """
do_move = function(board, start_loc, move)
    
    new_loc = start_loc .+ move 
    while true
        
        x, y = new_loc
        # Wrap around edge of board
        if x == 0
            x = size(board)[1]
        elseif x > size(board)[1]
            x = 1
        end
        if y == 0
            y = size(board)[2]
        elseif y > size(board)[2]
            y = 1
        end
        new_loc = (x, y)

        if board[x, y] == '.'
            return new_loc
        elseif board[x, y] == '#'
            return start_loc
        end

        new_loc = new_loc .+ move
    end
end

const DIRECTIONS = (
    (0, 1),
    (1, 0),
    (0, -1),
    (-1, 0)
)

update_direction = function(current_direction, change)
    index = findfirst(x -> x == current_direction, DIRECTIONS)
    change == "R" ? index+=1 : index-=1
    index = mod(index - 1, 4) + 1
    DIRECTIONS[index]
end

get_password = function(board, instructions)
    location = start_loc(board)
    direction = (0, 1)
    for instruction in instructions
        if instruction in ("L", "R")
            direction = update_direction(direction, instruction)
            continue
        end
        n_moves = parse(Int64, instruction)
        for _ in 1:n_moves
            location = do_move(board, location, direction)
        end
    end
    # Work out direction score
    direction_score = findfirst(x -> x == direction, DIRECTIONS) - 1
    1000 * location[1] + 4 * location[2] + direction_score
end
    
input = readlines("day22/input.txt")
board, instructions = parse_input(input)
get_password(board, instructions)

# Part 2 ---------

# My puzzle has following shape
#   1 2
#   3
# 4 5
# 6
# Just going to shamelessly solve my shape rather than find a general solution

# Build dictionary to map all the edges to next side and new direction
# Need to add side coming from as key of dictionary to handle corners
side_mapping = Dict{Tuple{Int64, Tuple{Int64, Int64}}, Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}}()

# left 1 -> left 4
for (x1, x4) in zip(1:50, 150:-1:101)
    side_mapping[(1, (x1, 50))] = ((x4, 1), (0, 1))
end

# top 1 -> left 6
for (y1, x6) in zip(51:100, 151:200)
    side_mapping[(1, (0, y1))] = ((x6, 1), (0, 1))
end

# bottom 2 -> right 3
for (y2, x3) in zip(101:150, 51:100)
    side_mapping[(2, (51, y2))] = ((x3, 100), (0, -1))
end

# right 2 -> right 5
for (x2, x5) in zip(1:50, 150:-1:101)
    side_mapping[(2, (x2, 151))] = ((x5, 100), (0, -1))
end

# top 2 -> bottom 6
for (y2, y6) in zip(101:150, 1:50)
    side_mapping[(2, (0, y2))] = ((200, y6), (-1, 0))
end

# right 3 -> bottom 2
for (x3, y2) in zip(51:100, 101:150)
    side_mapping[(3, (x3, 101))] = ((50, y2), (-1, 0))
end

# left 3 -> top 4
for (x3, y4) in zip(51:100, 1:50)
    side_mapping[(3, (x3, 50))] = ((101, y4), (1, 0))
end

# top 4 -> left 3
for (y4, x3) in zip(1:50, 51:100)
    side_mapping[(4, (100, y4))] = ((x3, 51), (0, 1))
end

# left 4 -> left 1
for (x4, x1) in zip(150:-1:101, 1:50)
    side_mapping[(4, (x4, 0))] = ((x1, 51), (0, 1))
end

# right 5 -> right 2
for (x5, x2) in zip(150:-1:101, 1:50)
    side_mapping[(5, (x5, 101))] = ((x2, 150), (0, -1))
end

# bottom 5 -> right 6
for (y5, x6) in zip(51:100, 151:200)
    side_mapping[(5, (151, y5))] = ((x6, 50), (0, -1))
end

# right 6 -> bottom 5
for (x6, y5) in zip(151:200, 51:100)
    side_mapping[(6, (x6, 51))] = ((150, y5), (-1, 0))
end

# bottom 6 -> top 2
for (y6, y2) in zip(1:50, 101:150)
    side_mapping[(6, (201, y6))] = ((1, y2), (1, 0))
end

# left 6 -> top 1
for (x6, y1) in zip(151:200, 51:100)
    side_mapping[(6, (x6, 0))] = ((1, y1), (1, 0))
end

#   1 2
#   3
# 4 5
# 6
get_side = function(loc)
    x, y = loc
    if 1 <= x <= 50
        (51 <= y <= 100) && return 1
        (101 <= y <= 150) && return 2
    elseif 51 <= x <= 100
        (51 <= y <= 100) && return 3
    elseif 101 <= x <= 150
        (1 <= y <= 50) && return 4
        (51 <= y <= 100) && return 5
    elseif 151 <= x <= 200
        (1 <= y <= 50) && return 6
    end
    error("unable to get side for loc $loc")
end


do_move2 = function(board, side_mapping, start_loc, move)
    
    side = get_side(start_loc)
    direction = move
    new_loc = start_loc .+ move
    if (side, new_loc) in keys(side_mapping) 
        new_loc, direction = side_mapping[(side, new_loc)]
    end
    x, y = new_loc
    if board[x, y] == '.'
        return new_loc, direction
    elseif board[x, y] == '#'
        return start_loc, move
    end

end

get_password2 = function(board, instructions, side_mapping)
    location = start_loc(board)
    direction = (0, 1)
    for instruction in instructions
        if instruction in ("L", "R")
            direction = update_direction(direction, instruction)
            continue
        end
        n_moves = parse(Int64, instruction)
        for _ in 1:n_moves
            location, direction = do_move2(board, side_mapping, location, direction)
        end
    end
    # Work out direction score
    direction_score = findfirst(x -> x == direction, DIRECTIONS) - 1
    1000 * location[1] + 4 * location[2] + direction_score
end
    
input = readlines("day22/input.txt")
board, instructions = parse_input(input)
get_password2(board, instructions, side_mapping)

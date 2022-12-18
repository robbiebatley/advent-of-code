input = readlines("day14/input.txt")

parse_point = function(s)
    x, y = match(r"(?<x>\d+),(?<y>\d+)", s)
    x = parse(Int, x)
    y = parse(Int, y)
    x, y
end

unsafe_range = function(a, b)
    b < a ? (a:-1:b) : (a:1:b)
end

parse_row = function(r)
    r = split(r, " -> ") 
    r = parse_point.(r)
    out = Set{Tuple{Int64, Int64}}()
    for i in 1:(length(r)-1)
        ((x1, y1), (x2, y2)) = r[i:(i+1)]
        for x in unsafe_range(x1, x2), y in unsafe_range(y1, y2)
            push!(out, (x, y))
        end
    end
    out
end

# Add points
move_grain = function(rocks, x, y)
    if y + 1 > maximum_y 
        return x, y + 1
    elseif !((x, y+1) in rocks) 
        return move_grain(rocks, x, y + 1)
    elseif !((x-1, y+1) in rocks) 
        return move_grain(rocks, x-1, y + 1)
    elseif !((x+1, y+1) in rocks) 
        return move_grain(rocks, x+1, y + 1)
    end
    x, y
end

sim = function(rocks)
    i = 0
    while true
        x, y = move_grain(rocks, 500, 0)
        y > maximum_y && return i
        union!(rocks, [(x, y)])
        i += 1
    end
    return -1
end


# Part 1
rocks = Set{Tuple{Int64, Int64}}()
for row in input
    union!(rocks, parse_row(row))
end
maximum_y = maximum([y for (x, y) in rocks]) 
sim(rocks)

# Part 2
move_grain = function(rocks, x, y)
    if y + 1 == maximum_y + 2
        return x, y
    elseif !((x, y+1) in rocks) 
        return move_grain(rocks, x, y + 1)
    elseif !((x-1, y+1) in rocks) 
        return move_grain(rocks, x-1, y + 1)
    elseif !((x+1, y+1) in rocks) 
        return move_grain(rocks, x+1, y + 1)
    end
    x, y
end

sim = function(rocks)
    i = 0
    while true
        x, y = move_grain(rocks, 500, 0)
        y == 0 && return i + 1
        union!(rocks, [(x, y)])
        i += 1
    end
    return -1
end
rocks = Set{Tuple{Int64, Int64}}()
for row in input
    union!(rocks, parse_row(row))
end
maximum_y = maximum([y for (x, y) in rocks]) 
sim(rocks)

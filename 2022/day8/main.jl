
input = readlines("day8/input.txt")

parse_row = function(x) 
    [parse(Int16, i) for i in x]
end

data = reduce(hcat, [parse_row(i) for i in input])

# Part 1
is_visible = function(data, i, j)

    # Outside edge
    if i == 1 || j == 1 || i == size(data, 1) || j == size(data, 2)
        return 1
    end

    value = data[i, j]

    # From left
    if maximum(data[i, 1:(j-1)]) < value
        return 1
    elseif maximum(data[i, (j+1):end]) < value
        return 1
    elseif maximum(data[1:(i-1), j]) < value
        return 1
    elseif maximum(data[(i+1):end, j]) < value
        return 1
    end
    
    0
end


sum(is_visible(data, i, j) for i in 1:size(data, 1), j in 1:size(data, 2))

view_distance = function(tree_house, trees)
    distance = 0
    for tree in trees 
        distance += 1
        tree >= tree_house && break
    end
    distance
end

# Part 2
viewing_score = function(data, i, j)

    house_height = data[i, j]
    nrow = size(data, 1)
    ncol = size(data, 2)

    up = i > 1 ? view_distance(house_height, data[(i-1):-1:1,j]) : 0
    down = i < nrow ? view_distance(house_height, data[(i+1):nrow, j]) : 0
    left = j > 1 ? view_distance(house_height, data[i, (j-1):-1:1]) : 0
    right = j < ncol ? view_distance(house_height, data[i, (j+1):ncol]) : 0

    up * down * left * right
end

maximum(viewing_score(data, i, j) for i in 1:size(data, 1), j in 1:size(data, 2))

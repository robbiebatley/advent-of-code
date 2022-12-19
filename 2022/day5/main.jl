
input = readlines("input.txt")

crates_raw = input[8:-1:1]

# pad so we don't have to check bounds
for (index, value) in enumerate(crates_raw)
    crates_raw[index] = rpad(value, 35)
end

# Parse crate arrangement
starting_crates = function(crates_raw)

    crates = Dict{Int64, Vector{Char}}()

    for column in 1:9
        column_loc = 4 * column - 2
        values = [x[column_loc] for x in crates_raw if x[column_loc] != ' ']
        crates[column] = values
    end

    crates
end

# Parse instructions
instructions = input[11:end]

pattern = r"move (?<n>\d+) from (?<from>\d) to (?<to>\d)"

parse_instruction = function(instruction, pattern)
    instruction |>
        x -> match(pattern, x) |> 
        x -> parse.(Int, x)
end

move_box! = function(crates, from, to)
    box = pop!(crates[from])
    push!(crates[to], box)
    crates
end

# Part 1 ----------------------
crates = starting_crates(crates_raw)
for instruction in instructions
    n, from, to = parse_instruction(instruction, pattern) 
    for _ in 1:n
        move_box!(crates, from, to)
    end
end

reduce(*, [crates[i][end] for i in 1:9])

# Part 2 ----------------------

move_boxes! = function(crates, from, to, n)
    height = length(crates[from])
    boxes = splice!(crates[from], (height-n+1):height)
    append!(crates[to], boxes)
    crates
end

crates = starting_crates(crates_raw)
for instruction in instructions
    n, from, to = parse_instruction(instruction, pattern) 
    move_boxes!(crates, from, to, n)
end
reduce(*, [crates[i][end] for i in 1:9])


input = readlines("day20/input.txt")
input = [(parse.(Int64, v), i) for (i, v) in enumerate(input)]
const n_items = length(input)

update_index = function(start, change)
    # if move past ends still in same place so need to increment 1 more for each time it passes end
    index_mod = mod(start + change - 1, n_items - 1)  + 1
end

# Inputs are not unique
shift_item! = function(input, i)
    current_index = findfirst(x -> x[2] == i, input)
    x = popat!(input, current_index)
    new_index = update_index(current_index, x[1])
    insert!(input, new_index, x)
end

# Reorder
for i in eachindex(input)
    shift_item!(input, i)
end


get_offset = function(index, offset)
    pos = mod(index + offset - 1, n_items)  + 1
    x, i = input[pos]
    x
end

zero_pos = findfirst(x -> x[1] == 0, input)
map(x -> get_offset(zero_pos, x), [1000, 2000, 3000]) |>
    sum

# Part 2
decryption_key = 811589153
input = readlines("day20/input.txt")
input = [(parse.(Int64, v) * decryption_key, i) for (i, v) in enumerate(input)]

for _ in 1:10
    for i in eachindex(input)
        shift_item!(input, i)
    end
end

zero_pos = findfirst(x -> x[1] == 0, input)
map(x -> get_offset(zero_pos, x), [1000, 2000, 3000]) |>
    sum

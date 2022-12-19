using JSON3

input = readlines("day13/input.txt")
filter!(x -> x != "", input)
pairs = [(JSON3.read(input[i]), JSON3.read(input[i+1])) for i in 1:2:length(input)]

valid_packet = function(pair1, pair2)
    for (l, r) in zip(pair1, pair2)
        if isa(l, Int) && isa(r, Int)
            if l != r
                return l < r ? 1 : -1
            end 
        elseif isa(l, JSON3.Array) && isa(r, JSON3.Array)
            result = valid_packet(l, r)
            if result != 0
                return result
            elseif length(l) != length(r)
                return length(l) < length(r) ? 1 : -1
            end
        else
            if isa(l, Int)
                l = JSON3.read("[$l]")
            else
                r = JSON3.read("[$r]")
            end
            return valid_packet(l, r)
        end
    end
    if length(pair1) == length(pair2)
        return 0
    end
    length(pair1) < length(pair2) ? 1 : -1
end

# Part 1
sum_index = 0
for (index, pair) in enumerate(pairs)
    if valid_packet(pair...) == 1
        sum_index += index
    end
end
sum_index

# Part 2
pairs = [JSON3.read(l) for l in union(input, ["[[2]]", "[[6]]"])] 
pair_isless = function(a, b)
    valid_packet(a, b) == 1
end
sort!(pairs; lt = pair_isless)

index_2 = findfirst(x -> x ==  JSON3.read("[[2]]"), pairs)
index_6 = findfirst(x -> x ==  JSON3.read("[[6]]"), pairs)
index_2 * index_6

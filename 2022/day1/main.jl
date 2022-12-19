
function read_input()
    return [l for l in eachline("input.txt")]
end

function parse_input(data)
    calories = 0
    out = Vector{Int}()
    for x in data
        if strip(x) == "" 
            push!(out, calories)
            calories = 0
        else 
            calories += parse(Int64, x)
        end
    end
    if calories > 0 
        push!(out, calories)
    end
    out
end



data = read_input()
elves = parse_input(data)
maximum(elves)

elves_orderd = sort(elves; rev=true)
sum(elves_orderd[1:3])

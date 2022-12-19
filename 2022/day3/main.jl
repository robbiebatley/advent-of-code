
function read_input()
    return [l for l in eachline("input.txt")]
end

function split_packs(s)
    n = length(s)
    return Set(s[1:div(n, 2)]), Set(s[div(n, 2)+1:n])
end

function make_letters()
    letters = append!(collect('a':'z'), collect('A':'Z')) 
    letters = Dict(v => i for (i, v) in enumerate(letters))
    letters        
end

function get_priority(x)
    pack1, pack2 = split_packs(x)
    overlap = collect(intersect(pack1, pack2))
    letters = make_letters()
    letters[overlap[1]]
end

input = read_input()

sum([get_priority(l) for l in input])

# Part two
out = 0
for i in 0:99
    elf1 = union(split_packs(input[3i + 1])...)
    elf2 = union(split_packs(input[3i + 2])...)
    elf3 = union(split_packs(input[3i + 3])...)
    common_item = reduce(intersect, (elf1, elf2, elf3))
    letters = make_letters()
    out += letters[collect(common_item)[1]]
end
out

mutable struct Monkey
    id::String
    dep1::String
    dep2::String
    op::String
    val1::Union{Missing, Int64}
    val2::Union{Missing, Int64}    
end
Monkey(id, dep1, dep2, op) = Monkey(id, dep1, dep2, op, missing, missing)

fn_dict = Dict(
    "+" => +,
    "-" => -,
    "*" => *,
    "/" => /,
)

input = readlines("day21/input.txt")

parse_input = function(input)
    known_monkeys = Vector{Tuple{String, Int64}}()
    unknown_monkeys = Vector{Monkey}()
    unknown_pattern = r"(?<id>\w+): (?<dep1>\w+) (?<op>.) (?<dep2>\w+)"
    known_pattern = r"(?<id>\w+): (?<val>\d+)" 
    for row in input
        m = match(unknown_pattern, row)
        if !isnothing(m)
            id, dep1, op, dep2 = m
            monkey = Monkey(id, dep1, dep2, op)
            push!(unknown_monkeys, monkey)
        else
            id, val = match(known_pattern, row)
            push!(known_monkeys, (id, parse(Int64, val)))
        end
    end
    known_monkeys, unknown_monkeys
end 

known_monkeys, unknown_monkeys = parse_input(input)

solve_p1 = function(known_monkeys, unknown_monkeys)
    while length(known_monkeys) > 0
        delete_indicies = Vector{Int64}()
        id, val = popat!(known_monkeys, 1)
        for (index, m) in enumerate(unknown_monkeys)
            if id == m.dep1
                m.val1 = val
            elseif id == m.dep2
                m.val2 = val
            end
            if !ismissing(m.val1) && !ismissing(m.val2)
                push!(delete_indicies, index)
                m_val = fn_dict[m.op](m.val1, m.val2)
                if m.id == "root"
                    return m_val
                end
                push!(known_monkeys, (m.id, m_val))
            end
        end
        deleteat!(unknown_monkeys, delete_indicies)    
    end
    return missing
end

solve_p1(known_monkeys, unknown_monkeys)

# Part two -------

# Bugger part 1 approach isn't going to work
# Try build string expression for equation and eval parse
parse_row = function(row)
    id, call = split(row, ':'; limit = 2)
    call = split(strip(call), ' ')
    id, call
end

input = readlines("day21/input.txt")
monkeys = Dict([parse_row(r) for r in input])

build_str = function(id, monkeys)
    eq = monkeys[id]
    if length(eq) == 1
        return eq[1]
    end
    "($(build_str(eq[1], monkeys))) $(eq[2]) ($(build_str(eq[3], monkeys)))"
end

monkeys["root"][2] = "-"
monkeys["humn"][1] = "x"
func_str = "f(x) = $(build_str("root", monkeys))"  
eval(Meta.parse(func_str))

# Played around with function a bit and it looked linear for me
# Had to do a real massive step to get a slope that worked out
slope = (f(1e20) - f(0)) / 1e20
x = - f(0) / slope
x = floor(x)
f(x)
convert(Int64, x)

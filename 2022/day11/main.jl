struct Monkey
    items::Vector{Int64}
    operation::Function
    test::Function
end

initialise_system = function()
    monkies = Vector{Monkey}()

    # Monkey 0
    push!(monkies,
        Monkey(
            [98, 89, 52],
            x -> x * 2,
            x -> x % 5 == 0 ? 6 : 1
        )
    )

    # Monkey 1
    push!(monkies,
        Monkey(
            [57, 95, 80, 92, 57, 78],
            x -> x * 13,
            x -> x % 2 == 0 ? 2 : 6
        )
    )

    # Monkey 2
    push!(monkies,
        Monkey(
            [82, 74, 97, 75, 51, 92, 83],
            x -> x + 5,
            x -> x % 19 == 0 ? 7 : 5
        )
    )

    # Monkey 3
    push!(monkies,
        Monkey(
            [97, 88, 51, 68, 76],
            x -> x + 6,
            x -> x % 7 == 0 ? 0 : 4
        )
    )

    # Monkey 4
    push!(monkies,
        Monkey(
            [63],
            x -> x + 1,
            x -> x % 17 == 0 ? 0 : 1
        )
    )

    # Monkey 5
    push!(monkies,
        Monkey(
            [94, 91, 51, 63],
            x -> x + 4,
            x -> x % 13 == 0 ? 4 : 3
        )
    )

    # Monkey 6
    push!(monkies,
        Monkey(
            [61, 54, 94, 71, 74, 68, 98, 83],
            x -> x + 2,
            x -> x % 3 == 0 ? 2 : 7
        )
    )

    # Monkey 7
    push!(monkies,
        Monkey(
            [90, 56],
            x -> x * x,
            x -> x % 11 == 0 ? 3 : 5
        )
    )

    # Level for each monkey
    level = zeros(Int64, 8)

    monkies, level
end

play_round! = function(monkies, level)

    for (i, monkey) in enumerate(monkies)
        while !isempty(monkey.items)
            worry = pop!(monkey.items)
            worry = monkey.operation(worry)
            worry = floor(worry / 3)
            next_monkey = monkey.test(worry) + 1
            push!(monkies[next_monkey].items, worry)
            level[i] += 1
        end
    end
end

monkies, level = initialise_system()

for i = 1:20
    play_round!(monkies, level)
end

sort(level) |> 
    x -> last(x, 2) |>
    prod

# Part 2 ------
space_dim = 11 * 3 * 13 * 17 * 7 * 19 * 2 * 5

play_round! = function(monkies, level)

    for (i, monkey) in enumerate(monkies)
        while !isempty(monkey.items)
            worry = pop!(monkey.items)
            worry = monkey.operation(worry)
            worry = worry % space_dim
            next_monkey = monkey.test(worry) + 1
            push!(monkies[next_monkey].items, worry)
            level[i] += 1
        end
    end
end

monkies, level = initialise_system()

for i = 1:10000
    play_round!(monkies, level)
end

sort(level) |> 
    x -> last(x, 2) |>
    prod
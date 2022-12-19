
input = readlines("day10/input.txt")

# Part 1 -----------------------------------------------------------------------
x = 1
signal = Vector{Int64}()
for i in input
    if i == "noop"
        push!(signal, x)
    else
        push!(signal, x)
        push!(signal, x)
        increment = parse(Int64, i[6:end])
        x += increment
    end
end

poll = collect(20:40:220)
sum(poll .* signal[poll])

# Part 2 -----------------------------------------------------------------------
render_pixel = function(i, j, signal)
    cursor_location = signal[i + 40j + 1]
    if cursor_location - 1 <= i <= cursor_location + 1
        return '#'
    end
    '.'
end

crt = [render_pixel(i, j, signal) for j in 0:5, i in 0:39]
for row in reduce(*, crt; dims = 2)
    println(row)
end 

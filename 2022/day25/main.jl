
DIGITS = Dict(
    '2' => 2,
    '1' => 1,
    '0' => 0,
    '-' => -1,
    '=' => -2
)

INVERSE_DIGITS = Dict([(v,k) for (k,v) in DIGITS])

read_snafu = function(input)
    [DIGITS[i] for i in reverse(input)]
end

snafu_to_int = function(snafu)
    sum([v * 5^(i-1) for (i, v) in enumerate(snafu)])
end

"""Adjust from standard base 5 to snafu base 5"""
adjust_digit! = function(out, i)
    (-2 <= out[i] <= 2) && return out
    if i == length(out)
        push!(out, 1)
    else
        out[i+1] += 1
    end
    out[i] -= 5
    adjust_digit!(out, i)
end

int_to_snafu = function(x)
    out = Vector{Int8}()
    while(x > 0)
        push!(out, rem(x, 5))
        x = div(x, 5)
    end

    i = 1
    while (i <= length(out))
        adjust_digit!(out, i)
        i += 1
    end
    out
end

snafu_to_char = function(x)
    prod(INVERSE_DIGITS[i] for i in reverse(x))
end

readlines("day25/input.txt") |>
    x -> read_snafu.(x) |>
    x -> snafu_to_int.(x) |>
    sum |>
    int_to_snafu |>
    snafu_to_char

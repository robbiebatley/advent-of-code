
input = readlines("day18/input.txt") |>
    x -> split.(x, ',') |>
    x -> map(y -> parse.(Int64, y), x)

# Part 1
surface_area = function(points)
    total_sides = 0
    for (x, y, z) in points
        sides = 6
        for ∇x in (-1, 1)
            ([x + ∇x, y, z] in points) && (sides -= 1)
        end
        for ∇y in (-1, 1)
            ([x, y + ∇y, z] in points) && (sides -= 1)
        end
        for ∇z in (-1, 1)
            ([x, y, z + ∇z] in points) && (sides -= 1)
        end
        total_sides += sides
    end
    total_sides
end

lava_sa = surface_area(input)
lava_sa

# Part two 

# Find size of cube enclosing lava
x_min, x_max = extrema([x for (x, y, z) in input])
y_min, y_max = extrema([y for (x, y, z) in input])
z_min, z_max = extrema([z for (x, y, z) in input])

(x_max - x_min + 1) * (y_max - y_min + 1) * (z_max - z_min + 1)
# Not excessively large

air = setdiff(
    [[x, y, z] for x in (x_min-1):(x_max+1), y in (y_min-1):(y_max+1), z in (z_min-1):(z_max+1)], 
    input
)

# Remove all air from outside
# Sorted so start of queue is a corner
sort!(air)
queue = [air[1]] 
while length(queue) > 0
    point = popat!(queue, 1)
    !(point in air) && continue
    setdiff!(air, [point])
    x, y, z = point
    for ∇x in (-1, 1)
        push!(queue, [x + ∇x, y, z])
    end
    for ∇y in (-1, 1)
        push!(queue, [x, y + ∇y, z])
    end
    for ∇z in (-1, 1)
        push!(queue, [x, y, z + ∇z])
    end
end
air

lava_sa - surface_area(air)

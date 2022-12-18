
input = readlines("day15/input.txt")

parse_row = function(row)
    r = r"Sensor at x=(?<sx>-{0,1}\d+), y=(?<sy>-{0,1}\d+): closest beacon is at x=(?<bx>-{0,1}\d+), y=(?<by>-{0,1}\d+)"
    sx, sy, bx, by = match(r, row)
    parse.(Int, (sx, sy, bx, by))
end

input = [parse_row(i) for i in input]

# Calculate empties in row
unavaliable_locations = function(input, row)
    out = Set{Int64}()
    becons = Set{Int64}()
    for (sx, sy, bx, by) in input
        dist = abs(sx - bx) + abs(sy - by)
        dist_resid = dist - abs(sy - row)
        if dist_resid <= 0
            continue
        end
        union!(out, collect((sx-dist_resid):(sx+dist_resid)))
        # Add beacons in row
        if by == row
            push!(becons, bx)
        end
    end
    setdiff(out, becons)
end

length(unavaliable_locations(input, 2_000_000))


# Running loop over entire grid is not feasible
# We know there is only one point in grid
# So if we find all the intersections between points
# Just need to find 4 that are within distance 2 of each other
mh_dist = function(sx, sy, bx, by) 
    abs(sx - bx) + abs(sy - by)
end

intersections = Set{Tuple{Int64, Int64}}()
for i in eachindex(input), j in eachindex(input)
        
    (sx1, sy1, bx1, by1) = input[i]
    d1 = mh_dist(sx1, sy1, bx1, by1)

    (sx2, sy2, bx2, by2) = input[j]
    d2 = mh_dist(sx2, sy2, bx2, by2)

    # Checking if higher downward slopping edge of first diamond
    # intersects with higher upwards sloping edge of second diamond
    c1 = (sy1 - sx1 + d1)
    c2 = (sy2 + sx2 + d2)
    if iseven(c2 - c1)
        x = div(c2 - c1, 2)
        y = x + c1
        if 0 <= x <= 4_000_000 && 0 <= y <= 4_000_000
            push!(intersections, (x, y))
        end
    end

    # Checking if higher downward slopping edge of first diamond
    # intersects with lower upwards sloping edge of second diamond
    c2 = (sy2 + sx2 - d2)
    if iseven(c2 - c1)
        x = div(c2 - c1, 2)
        y = x + c1
        if 0 <= x <= 4_000_000 && 0 <= y <= 4_000_000
            push!(intersections, (x, y))
        end
    end

    # Checking if lower downward slopping edge of first diamond
    # intersects with higher upwards sloping edge of second diamond
    c1 = (sy1 - sx1 - d1)
    c2 = (sy2 + sx2 + d2)
    if iseven(c2 - c1)
        x = div(c2 - c1, 2)
        y = x + c1
        if 0 <= x <= 4_000_000 && 0 <= y <= 4_000_000
            push!(intersections, (x, y))
        end
    end

    # Checking if lower downward slopping edge of first diamond
    # intersects with lower upwards sloping edge of second diamond
    c2 = (sy2 + sx2 - d2)
    if iseven(c2 - c1)
        x = div(c2 - c1, 2)
        y = x + c1
        if 0 <= x <= 4_000_000 && 0 <= y <= 4_000_000
            push!(intersections, (x, y))
        end
    end
end

# Now just have to find 4 intersections that are 2 apart
for point in intersections
    out = Set{Tuple{Int64, Int64}}()
    x1, y1 = point
    for other_point in intersections
        x2, y2 = other_point
        if mh_dist(x1, y1,x2, y2) <= 2
            push!(out, other_point)
        end
    end
    if length(out) >= 3
        push!(out, point)
        break
    end
end

# value is average of the four intersections
x = div(sum([o[1] for o in out]), 4)
y = div(sum([o[2] for o in out]), 4)
x * 4000000 + y

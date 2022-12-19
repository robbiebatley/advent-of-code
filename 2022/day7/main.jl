
input = readlines("day7/input.txt")

update_directory = function(dir, cmd)
    if !startswith(cmd, "\$ cd") 
        return dir
    elseif cmd == "\$ cd .."
        return rsplit(dir, "/"; limit = 3)[1] * "/"
    elseif cmd == "\$ cd /"
        return "/"
    else
        return dir * cmd[6:end] * "/"
    end
end

get_file_size = function(cmd)
    if startswith(cmd, "\$")
        return 0
    elseif startswith(cmd, "dir")
        return 0
    else 
        return parse(Int64, match(r"^\d+", cmd).match)
    end
end

# Calculate size of files directly within each directory
directory_sizes = Dict{String, Int64}()
dir = "/"
for line in input
    dir = update_directory(dir, line)
    size = get_file_size(line)
    if haskey(directory_sizes, dir)
        directory_sizes[dir] += size
    else
        directory_sizes[dir] = size
    end
end

# Roll up sub directories
directory_sizes_r = Dict{String, Int64}()
for key in keys(directory_sizes)
    subdirs = filter(startswith(key), keys(directory_sizes))
    directory_sizes_r[key] = sum([directory_sizes[k] for k in subdirs])
end

# Filter directories under 100_000
sum(filter(x -> x <= 100_000, collect(values(directory_sizes_r))))

for d in sort(collect(keys(directory_sizes_r)))
    println("$d $(directory_sizes_r[d])")
end

# Part two

space_req = directory_sizes_r["/"] - 40_000_000
collect(values(directory_sizes_r)) |>
    x -> filter(y -> y >= space_req, x) |>
    x -> minimum(x)


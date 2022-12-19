
buffer = readline("day6/input.txt")

find_marker = function(buffer)
    for i = 4:length(buffer)
        seq = buffer[(i-3):i]
        if length(Set(seq)) == 4 
            return i
        end
    end
    return 0
end

find_marker(buffer)

find_message = function(buffer)
    for i = 14:length(buffer)
        seq = buffer[(i-13):i]
        if length(Set(seq)) == 14 
            return i
        end
    end
    return 0
end

find_message(buffer)
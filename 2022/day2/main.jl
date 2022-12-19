
player1_mapping = Dict(
    'A' => 1,
    'B' => 2,
    'C' => 3,
)

player2_mapping = Dict(
    'X' => 1,
    'Y' => 2,
    'Z' => 3,
)

win_score = Dict(
    (1, 1) => 3,
    (1, 2) => 6,
    (1, 3) => 0,
    (2, 1) => 0,
    (2, 2) => 3,
    (2, 3) => 6,
    (3, 1) => 6,
    (3, 2) => 0,
    (3, 3) => 3,
)

function read_input()
    return [(l[1], l[3]) for l in eachline("input.txt")]
end

input = read_input()


moves = [(player1_mapping[l[1]], player2_mapping[l[2]]) for l in input]

score = [win_score[m] + m[2] for m in moves]

sum(score)


game_outcome = Dict(
    'X' => 0,
    'Y' => 3,
    'Z' => 6,
)

move_map = Dict([(k[1], v) => k[2] for (k, v) in win_score])

move_outcome = [(player1_mapping[l[1]], game_outcome[l[2]]) for l in input]
score2 = [o + move_map[(m, o)] for (m, o) in move_outcome]

sum(score2)
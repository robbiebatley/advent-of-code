from itertools import groupby


def is_vert_sym(map: list[str], j: int, differences: int) -> int:
    n = min(j, len(map[0]) - j)
    return (
        sum(x[j - d - 1] != x[j + d] for x in map for d in range(0, n)) == differences
    )


def is_hor_sym(map: list[str], i: int, differences: int) -> int:
    n = min(i, len(map) - i)
    return (
        sum(
            map[i - d - 1][j] != map[i + d][j]
            for d in range(0, n)
            for j in range(0, len(map[0]))
        )
        == differences
    )


def score_map(map: list[str], differences: int) -> int:
    score = 0
    for i in range(0, len(map[0])):
        if is_vert_sym(map, i, differences):
            score += i
    for j in range(0, len(map)):
        if is_hor_sym(map, j, differences):
            score += 100 * j
    return score


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

maps = [list(x) for k, x in groupby(input, lambda x: x == "") if not k]

part1 = sum(score_map(x, differences=0) for x in maps)
print(f"Part 1: {part1}")

part2 = sum(score_map(x, differences=1) for x in maps)
print(f"Part 2: {part2}")

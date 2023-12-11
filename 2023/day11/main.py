from typing import List, Tuple, Dict, Set
from itertools import combinations

# Math vector not data structure vector
Vector = Tuple[int, int]


def coord_map(values: List[int], expansion_rate: int) -> Dict[int, int]:
    min_value = min(values)
    max_value = max(values)
    out = {}
    n = 0
    for i in range(min_value, max_value + 1):
        if i not in values:
            n += expansion_rate - 1
        else:
            out[i] = n
    return out


def expand_universe(galaxies: List[Vector], expansion_rate: int) -> List[Vector]:
    row_map = coord_map([i for i, _ in galaxies], expansion_rate)
    col_map = coord_map([j for _, j in galaxies], expansion_rate)
    return [(i + row_map[i], j + col_map[j]) for i, j in galaxies]


def shortest_path(start: Vector, end: Vector) -> int:
    si, sj = start
    ei, ej = end
    return abs(si - ei) + abs(sj - ej)


def solve_problem(galaxies: List[Vector], expansion_rate: int) -> int:
    expanded_galaxies = expand_universe(galaxies, expansion_rate)
    return sum(shortest_path(a, b) for a, b in combinations(expanded_galaxies, 2))


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

galaxies = [
    (i, j) for i, line in enumerate(input) for j, v in enumerate(line) if v == "#"
]

part1 = solve_problem(galaxies, 2)
print(f"Part 1: {part1}")

part2 = solve_problem(galaxies, 1_000_000)
print(f"Part 2: {part2}")

from typing import List, Tuple, Dict
from math import lcm
from functools import reduce

Map = Dict[str, Tuple[str, str]]


def parse_mapping(line: str) -> Tuple[str, str, str]:
    a, x = line.split(" = ")
    b, c = x.strip("(").strip(")").split(", ")
    return a, b, c


def parse_input(input: List[str]) -> Tuple[str, Map]:
    directions = input[0]
    maps = [parse_mapping(x) for x in input[2:]]
    return directions, {a: (b, c) for (a, b, c) in maps}


def n_steps(start: str, end: str, directions: str, maps: Map) -> int:
    location = start
    steps = 0
    n_directions = len(directions)
    while True:
        if location == end:
            break
        l, r = map[location]
        if directions[steps % n_directions] == "L":
            location = l
        else:
            location = r
        steps += 1
    return steps


def find_cycle(start: str, directions: str, maps: Map) -> Tuple[int, int]:
    visited = dict()
    location = start
    steps = 0
    n_directions = len(directions)
    while True:
        if location.endswith("Z"):
            state = (location, steps % n_directions)
            if state in visited:
                prev_state = visited[state]
                return (steps, steps - prev_state)
            else:
                visited[state] = steps
        l, r = map[location]
        if directions[steps % n_directions] == "L":
            location = l
        else:
            location = r
        steps += 1


def n_steps_all(starts: List[str], directions: str, maps: Map) -> int:
    cycles = [find_cycle(s, directions, maps) for s in starts]
    cycles.sort()
    steps, cycle_length = cycles.pop()
    while True:
        if all((steps - s) % l == 0 for s, l in cycles):
            return steps
        steps += cycle_length


with open("input.txt") as f:
    input = [x.strip("\n") for x in f.readlines()]

directions, map = parse_input(input)
part1 = n_steps("AAA", "ZZZ", directions, map)
print(f"Part 1: {part1}")


starts = [x for x in map.keys() if x.endswith("A")]
cycles = [find_cycle(s, directions, map) for s in starts]
part2 = reduce(lcm, (length for _, length in cycles))
print(f"Part 2: {part2}")

# This is too slow in python but is a more general solution that works for cycle
# appearing anywhere
# part2 = n_steps_all(starts, directions, map)

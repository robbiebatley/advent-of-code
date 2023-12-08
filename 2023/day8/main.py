from typing import List, Tuple, Dict, Callable
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


def n_steps(start: str, end: Callable[str, bool], directions: str, maps: Map) -> int:
    location = start
    steps = 0
    n_directions = len(directions)
    while True:
        if end(location):
            break
        l, r = map[location]
        if directions[steps % n_directions] == "L":
            location = l
        else:
            location = r
        steps += 1
    return steps


with open("input.txt") as f:
    input = [x.strip("\n") for x in f.readlines()]

directions, map = parse_input(input)
part1 = n_steps("AAA", lambda x: x == "ZZZ", directions, map)
print(part1)

starts = [x for x in map.keys() if x.endswith("A")]
paths = [n_steps(x, lambda x: x.endswith("Z"), directions, map) for x in starts]
part2 = reduce(lcm, paths)
print(part2)

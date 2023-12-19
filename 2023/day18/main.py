from typing import NamedTuple
from itertools import pairwise


class Instruction(NamedTuple):
    direction: tuple[int, int]
    steps: int
    colour: str


DIRECTIONS = {
    "D": (1, 0),
    "U": (-1, 0),
    "R": (0, 1),
    "L": (0, -1),
}


def parse_line(line: str) -> Instruction:
    direction, steps, colour = line.split(" ")
    colour = colour.strip("(").strip(")")
    direction = DIRECTIONS[direction]
    steps = int(steps)
    return Instruction(direction, steps, colour)


def find_verticies(instructions: list[Instruction]) -> list[tuple[int, int]]:
    # Find center of boxes first
    i = 0.5
    j = 0.5
    centers = [(i, j)]
    for instruction in instructions:
        di, dj = instruction.direction
        i += di * instruction.steps
        j += dj * instruction.steps
        centers.append((i, j))
    assert centers[-1] == (0.5, 0.5)

    # Make sure we always go around clockwise so that we can find outside corner
    d0 = instructions[0].direction
    d1 = instructions[1].direction
    if (d0 == (0, 1) and d1 == (-1, 0)) or (d0 == (0, -1) and d1 == (1, 0)):
        print("Traversing in reverse")
        centers.reverse()
        instructions.reverse()

    # Now go through and adjust centers to outside edge
    corner_adjustment = {
        ((0, 1), (1, 0)): (-0.5, 0.5),  #  7 *
        ((0, 1), (-1, 0)): (-0.5, -0.5),  #  * _|
        ((0, -1), (1, 0)): (0.5, 0.5),  #  F .
        ((0, -1), (-1, 0)): (0.5, -0.5),  #  . L
        ((1, 0), (0, 1)): (-0.5, 0.5),  #  L *
        ((1, 0), (0, -1)): (0.5, 0.5),  #  _| .
        ((-1, 0), (0, 1)): (-0.5, -0.5),  # * F
        ((-1, 0), (0, -1)): (0.5, -0.5),  # . 7
    }

    outside_edge = []
    for i in range(1, len(instructions)):
        dir_in = instructions[i - 1].direction
        dir_out = instructions[i].direction
        adj = corner_adjustment[(dir_in, dir_out)]
        center = centers[i]
        corner = (center[0] + adj[0], center[1] + adj[1])
        outside_edge.append(corner)

    # do last corner
    dir_in = instructions[-1].direction
    dir_out = instructions[0].direction
    adj = corner_adjustment[(dir_in, dir_out)]
    center = centers[0]
    last_corner = (center[0] + adj[0], center[1] + adj[1])

    outside_edge = [last_corner] + outside_edge

    return outside_edge


def calculate_area(verticies: list[tuple[int, int]]) -> int:
    area = 0
    min_i = min(i for i, _ in verticies)
    for v1, v2 in pairwise(verticies):
        if v2[0] == v1[0]:
            area += (v2[1] - v1[1]) * (v2[0] - min_i)
    return abs(int(area))


DIRECTIONS2 = {
    "1": (1, 0),
    "3": (-1, 0),
    "0": (0, 1),
    "2": (0, -1),
}


def parse_line2(line: str) -> Instruction:
    x = line.split("#")[1].strip(")")
    colour = ""
    direction = DIRECTIONS2[x[-1]]
    steps = int(x[:-1], 16)
    return Instruction(direction, steps, colour)


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

instructions = [parse_line(x) for x in input]
verticies = find_verticies(instructions)
part1 = calculate_area(verticies)
print(f"Part 1: {part1}")

instructions2 = [parse_line2(x) for x in input]
verticies2 = find_verticies(instructions2)
part2 = calculate_area(verticies2)
print(f"Part 2: {part2}")

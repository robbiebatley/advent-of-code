from typing import NamedTuple
from collections import defaultdict
from copy import deepcopy


class Brick(NamedTuple):
    x: tuple[int, int]
    y: tuple[int, int]
    z: tuple[int, int]


def parse_brick(line: str) -> Brick:
    a, b = line.split("~")
    coords = [(int(i), int(j)) for i, j in zip(a.split(","), b.split(","))]
    return Brick(*coords)


def drop(b: Brick) -> Brick:
    return Brick(b.x, b.y, (b.z[0] - 1, b.z[1] - 1))


def intersect(x: Brick, y: Brick) -> bool:
    return all(pair_overlaps(a, b) for a, b in zip(x, y))


def pair_overlaps(a: tuple[int, int], b: tuple[int, int]) -> bool:
    return a[0] <= b[1] and b[0] <= a[1]


def stack_bricks(
    bricks: list[Brick],
) -> tuple[list[Brick], defaultdict[int, list[int]]]:
    bricks.sort(key=lambda b: b.z[0])
    supported_by = defaultdict(list)
    for i in range(0, len(bricks)):
        brick = bricks[i]
        current_height = brick.z[0]
        if current_height == 1:
            continue
        # Drop current brick until it overlaps something or hits ground
        dist = 0
        while dist <= current_height:
            next_brick = drop(brick)
            if next_brick.z[0] < 1:
                break
            overlaps = []
            for j in range(0, i):
                if intersect(next_brick, bricks[j]):
                    overlaps.append(j)
            if len(overlaps) > 0:
                supported_by[i] = overlaps
                break
            dist += 1
            brick = next_brick
        bricks[i] = brick
    return bricks, supported_by


with open("input.txt", mode="r") as f:
    input = [parse_brick(x.strip()) for x in f.readlines()]

# This is pretty slow - must be a better way to do this
bricks, supported_by = stack_bricks(input)

# Reverse relationships
supports = defaultdict(list)
for k, v in supported_by.items():
    for x in v:
        supports[x].append(k)


n = 0
for i in range(0, len(bricks)):
    i_supports = supports[i]
    if len(i_supports) == 0:
        n += 1
    elif all(len(supported_by[j]) > 1 for j in i_supports):
        n += 1

print(f"Part 1: {n}")

n = 0
for i in range(0, len(bricks)):
    current_supported_by = deepcopy(supported_by)
    fallen = set()
    queue = [i]
    while len(queue) > 0:
        x = queue.pop()
        for b in supports[x]:
            if x in current_supported_by[b]:
                current_supported_by[b].remove(x)
            if len(current_supported_by[b]) == 0:
                fallen.add(b)
                queue.append(b)
    n += len(fallen)

print(f"Part 2: {n}")

from typing import List
from itertools import pairwise


Readings = List[int]


def parse_readings(file: str) -> List[Readings]:
    with open(file, mode="r") as f:
        out = [[int(x) for x in l.split(" ")] for l in f.readlines()]
    return out


def difference_readings(
    readings: Readings, index: int, acc: List[int] = []
) -> List[int]:
    difference = [b - a for a, b in pairwise(readings)]
    if all(x == 0 for x in difference):
        return acc
    return difference_readings(difference, index, acc=acc + [difference[index]])


def expected_value(readings: Readings) -> int:
    differences = difference_readings(readings, -1)
    return readings[-1] + sum(differences)


def neg_expected_value(readings: Readings) -> int:
    differences = difference_readings(readings, 0)
    cum_diff = 0
    for x in reversed(differences):
        cum_diff = x - cum_diff
    return readings[0] - cum_diff


input = parse_readings("input.txt")

part1 = sum(expected_value(x) for x in input)
print(f"Part1 : {part1}")

part2 = sum(neg_expected_value(x) for x in input)
print(f"Part2 : {part2}")

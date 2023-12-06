from typing import Tuple, List
from math import sqrt, ceil, floor, prod


def read_input(path: str) -> Tuple[List[float], List[float]]:
    with open(path, mode="r") as f:
        out = [x.split(":")[1].strip() for x in f.readlines()]
    times = [float(i) for i in out[0].split() if i != ""]
    distances = [float(i) for i in out[1].split() if i != ""]
    return times, distances


# Just finding roots of equation x * (time - x) = dist and taking next integer towards maximum
def n_positive_solutions(time: float, dist: float) -> int:
    disc = sqrt(time * time - 4 * dist)
    lower = (time - disc) / 2
    lower = ceil(lower) if not lower.is_integer() else ceil(lower) + 1
    upper = (time + disc) / 2
    upper = floor(upper) if not upper.is_integer() else floor(upper) - 1
    return upper - lower + 1


times, distances = read_input("input.txt")
part1 = prod(n_positive_solutions(t, d) for t, d in zip(times, distances))

print(f"{part1}")

time = float("".join(str(int(x)) for x in times))
distance = float("".join(str(int(x)) for x in distances))
part2 = n_positive_solutions(time, distance)

print(f"{part2}")

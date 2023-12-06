from typing import List, Tuple
from itertools import groupby, chain
from functools import reduce

Seeds = List[int]
SeedRange = Tuple[int, int]
RangeMap = Tuple[int, int, int]
Map = List[RangeMap]

def read_input(path: str) -> List[str]:
    with open(path, mode="r") as f:
        out = f.readlines()
    return [x.replace("\n", "") for x in out]


def parse_map(s: List[str]) -> Map:
    values = [x.split() for x in s[1:]]
    # Restructure so we have source start index, source end index + what we need to
    # increment by to get destination
    values = [(int(s), int(s) + int(n) - 1, int(d) - int(s)) for (d, s, n) in values]
    values.sort()
    return values


def parse_input(input: str) -> Tuple[Seeds, List[Map]]:
    seeds = input[0].split(": ")[1].split(" ")
    seeds = [int(s) for s in seeds]

    maps = input[2:]
    maps = [
        parse_map(list(group))
        for k, group in groupby(maps, lambda x: x == "")
        if not k
    ]
    return (seeds, maps)


def apply_map(x: int, map: Map) -> int:
    for start, end, increment in map:
        if x >= start and x <= end:
            return x + increment
    return x


# General stratery here is to recursively split ranges where they overlap
# with ranges in the mapping
def apply_map2(x: SeedRange, map: Map) -> List[SeedRange]:
    s, e = x
    for start, end, increment in map:
        # Has overlap
        if s <= end and e >= start:
            # subspell
            if s >= start and e <= end:
                return [(s + increment, e + increment)]
            elif e <= end:
                return apply_map2((s, start - 1), map) + [
                    (start + increment, e + increment)
                ]
            elif s >= start and e > end:
                return [(s + increment, end + increment)] + apply_map2(
                    (end + 1, e), map
                )
            # s < start and e > end:
            else:
                # as maps are sorted we know there is no overlap for the first part
                return [
                    (s, start - 1),
                    (start + increment, end + increment),
                ] + apply_map2((end + 1, e), map)
    return [x]


def map_all_seed_ranges(seed_ranges: List[SeedRange], map: Map) -> List[SeedRange]:
    out = []
    for x in seed_ranges:
        out += apply_map2(x, map)
    return out


def main() -> None:
    input = read_input("input.txt")
    seeds, maps = parse_input(input)
    locations = [reduce(apply_map, maps, s) for s in seeds]

    part1 = min(locations)
    print(f"Part 1: {part1}")

    n_ranges = len(seeds) // 2
    seed_ranges = [(seeds[2 * i], seeds[2 * i + 1]) for i in range(0, n_ranges)]
    seed_ranges = [(s, s + n - 1) for s, n in seed_ranges]

    locations_ranges = reduce(map_all_seed_ranges, maps, seed_ranges)
    part2 = min(l for l in chain(*locations_ranges))
    print(f"Part 2: {part2}")

if __name__ == "__main__":
    main()

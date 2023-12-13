from functools import cache


def parse_line(line: str) -> tuple[str, list[int]]:
    springs, lengths = line.split(" ")
    lengths = tuple(int(x) for x in lengths.split(","))
    return (springs, lengths)


@cache
def n_arrangements(springs: str, lengths: tuple) -> int:
    if not springs:
        return 1 if len(lengths) == 0 else 0

    if springs[0] == ".":
        return n_arrangements(springs[1:], lengths)

    if springs[0] == "#":
        if len(lengths) == 0:
            return 0
        n = lengths[0]
        if len(springs) < n:
            return 0
        if "." in springs[0:n]:
            return 0
        if len(springs) > n:
            if springs[n] == "#":
                return 0
        return n_arrangements(springs[(n + 1) :], lengths[1:])

    if springs[0] == "?":
        return n_arrangements("#" + springs[1:], lengths) + n_arrangements(
            "." + springs[1:], lengths
        )


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]


input = [parse_line(x) for x in input]

part1 = sum(n_arrangements(springs, lengths) for springs, lengths in input)
print(f"Part 1: {part1}")

input_expanded = [
    ("?".join([springs] * 5), tuple(lengths * 5)) for springs, lengths in input
]
part2 = sum(n_arrangements(springs, lengths) for springs, lengths in input_expanded)
print(f"Part 2: {part2}")

from typing import Iterable
from dataclasses import dataclass


@dataclass
class NumberLocation:
    value: int
    row: int
    start: int
    end: int


@dataclass
class SymbolLocation:
    row: int
    col: int


def read_input(file: str) -> Iterable[str]:
    with open(file, mode="r") as f:
        out = f.readlines()
        out = [line.replace("\n", "") for line in out]
    return out


def extract_numbers(input: Iterable[str]) -> Iterable[NumberLocation]:
    for i, line in enumerate(input):
        start = None
        for j, c in enumerate(line):
            if start is None and c.isdigit():
                start = j
            if start is not None:
                if not c.isdigit():
                    end = j
                    yield NumberLocation(int(line[start:end]), i, start, end)
                    start = None
                elif j == len(line) - 1:
                    end = j + 1
                    yield NumberLocation(int(line[start:end]), i, start, end)


def extract_symbols(input: Iterable[str]) -> Iterable[SymbolLocation]:
    for i, line in enumerate(input):
        for j, value in enumerate(line):
            if value != "." and not value.isdigit():
                yield SymbolLocation(i, j)


def adjacent(symbol: SymbolLocation, part: NumberLocation) -> bool:
    return (
        part.row >= symbol.row - 1
        and part.row <= symbol.row + 1
        and part.start <= symbol.col + 1
        and part.end >= symbol.col
    )


def is_part(part_loc: NumberLocation, symbols: Iterable[SymbolLocation]) -> bool:
    return any(adjacent(symbol, part_loc) for symbol in symbols)


def gear_ratio(
    symbols: Iterable[SymbolLocation], parts: Iterable[NumberLocation]
) -> Iterable[int]:
    for symbol in symbols:
        adjacent_values = [p.value for p in parts if adjacent(symbol, p)]
        if len(adjacent_values) == 2:
            yield adjacent_values[0] * adjacent_values[1]


def main() -> None:
    input = read_input("input.txt")
    symbols = [s for s in extract_symbols(input)]
    part_numbers = [x for x in extract_numbers(input) if is_part(x, symbols)]
    part1 = sum(x.value for x in part_numbers)
    print(f"Part 1: {part1}")

    part2 = sum(gear_ratio(symbols, part_numbers))
    print(f"Part 2: {part2}")


if __name__ == "__main__":
    main()

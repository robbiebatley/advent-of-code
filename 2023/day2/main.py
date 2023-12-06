from typing import List
from math import prod


class Game:
    def __init__(self, line: str):
        game, draws = line.split(":", 1)
        _, number = game.split(" ", 1)
        draws = draws.replace("\n", "").split(";")
        game_draws = {
            "blue": [],
            "red": [],
            "green": [],
        }
        for draw in draws:
            cubes = draw.split(",")
            for cube in cubes:
                n, colour = cube.strip().split(" ")
                game_draws[colour] = game_draws[colour] + [int(n)]
        self.id = int(number)
        self.draws = game_draws

    def __repr__(self) -> str:
        return f"Game {self.id}: {self.draws}"

    def is_possible(self, red, green, blue) -> bool:
        return (
            max(self.draws["red"]) <= red
            and max(self.draws["blue"]) <= blue
            and max(self.draws["green"]) <= green
        )

    def power(self) -> int:
        return prod(max(v) for v in self.draws.values())


def read_input(path: str) -> List[str]:
    with open(path, mode="r") as f:
        out = f.readlines()
    return out


def main() -> None:
    input = read_input("input.txt")
    games = [Game(line) for line in input]

    part1 = sum(g.id for g in games if g.is_possible(12, 13, 14))
    print(f"Part 1: {part1}")

    part2 = sum(g.power() for g in games)
    print(f"Part 2: {part2}")


if __name__ == "__main__":
    main()

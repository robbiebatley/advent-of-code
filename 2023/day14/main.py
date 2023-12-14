class Platform:
    def __init__(self, input: list[str]):
        self.rows = len(input)
        self.cols = len(input)
        self.values = [x for line in input for x in line]

    def __str__(self) -> str:
        return "\n".join(
            "".join(self.values[i : i + self.cols])
            for i in range(0, len(self.values), self.cols)
        )

    def get(self, i: int, j: int) -> str:
        return self.values[i * self.rows + j]

    def set(self, i: int, j: int, v: str) -> None:
        self.values[i * self.rows + j] = v

    def tilt_north(self) -> None:
        for j in range(0, self.cols):
            free_index = None
            for i in range(0, self.rows):
                value = self.get(i, j)
                if value == ".":
                    if free_index is None:
                        free_index = i
                    continue
                if value == "#":
                    free_index = None
                    continue
                if free_index is None:
                    continue
                self.set(free_index, j, "O")
                self.set(i, j, ".")
                free_index += 1

    def tilt_south(self) -> None:
        for j in range(0, self.cols):
            free_index = None
            for i in range(self.rows - 1, -1, -1):
                value = self.get(i, j)
                if value == ".":
                    if free_index is None:
                        free_index = i
                    continue
                if value == "#":
                    free_index = None
                    continue
                if free_index is None:
                    continue
                self.set(free_index, j, "O")
                self.set(i, j, ".")
                free_index -= 1

    def tilt_west(self) -> None:
        for i in range(0, self.rows):
            free_index = None
            for j in range(0, self.cols):
                value = self.get(i, j)
                if value == ".":
                    if free_index is None:
                        free_index = j
                    continue
                if value == "#":
                    free_index = None
                    continue
                if free_index is None:
                    continue
                self.set(i, free_index, "O")
                self.set(i, j, ".")
                free_index += 1

    def tilt_east(self) -> None:
        for i in range(0, self.rows):
            free_index = None
            for j in range(self.cols - 1, -1, -1):
                value = self.get(i, j)
                if value == ".":
                    if free_index is None:
                        free_index = j
                    continue
                if value == "#":
                    free_index = None
                    continue
                if free_index is None:
                    continue
                self.set(i, free_index, "O")
                self.set(i, j, ".")
                free_index -= 1

    def cycle(self) -> None:
        self.tilt_north()
        self.tilt_west()
        self.tilt_south()
        self.tilt_east()

    def round_rock_loc(self) -> tuple[int, ...]:
        return tuple(i for i, v in enumerate(self.values) if v == "O")

    def load_north(self) -> int:
        load = 0
        for j in range(0, self.cols):
            for i in range(0, self.rows):
                if self.get(i, j) == "O":
                    load += self.rows - i
        return load


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]


platform = Platform(input)
platform.tilt_north()
part1 = platform.load_north()
print(f"Part 1: {part1}")

platform = Platform(input)
prev_i = None
cycle_length = None
seen = {}
for i in range(1, 10_000):
    platform.cycle()
    state = platform.round_rock_loc()
    if state in seen:
        prev_i, _ = seen[state]
        cycle_length = i - prev_i
        break
    seen[state] = (i, platform.load_north())

step_required = prev_i + (1_000_000_000 - prev_i) % cycle_length
part2 = None
for i, v in seen.values():
    if i == step_required:
        part2 = v
        break

print(f"Part 2: {part2}")

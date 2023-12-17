MIRRORS = {
    ("|", 0, 1): [(-1, 0), (1, 0)],
    ("|", 0, -1): [(-1, 0), (1, 0)],
    ("|", 1, 0): [(1, 0)],
    ("|", -1, 0): [(-1, 0)],
    ("-", 0, 1): [(0, 1)],
    ("-", 0, -1): [(0, -1)],
    ("-", 1, 0): [(0, -1), (0, 1)],
    ("-", -1, 0): [(0, -1), (0, 1)],
    ("/", 0, 1): [(-1, 0)],
    ("/", 0, -1): [(1, 0)],
    ("/", 1, 0): [(0, -1)],
    ("/", -1, 0): [(0, 1)],
    ("\\", 0, 1): [(1, 0)],
    ("\\", 0, -1): [(-1, 0)],
    ("\\", 1, 0): [(0, 1)],
    ("\\", -1, 0): [(0, -1)],
}


class Contraption:
    def __init__(self, input: list[str]):
        self.values = [x for line in input for x in line]
        self.ncol = len(input[0])
        self.nrow = len(input)

    def get(self, i, j) -> str:
        return self.values[i * self.nrow + j]


def solve(contraption: Contraption, start: tuple[int, int, int, int]) -> int:
    visited = set()
    panels_visited = set()
    queue = [start]
    while len(queue) > 0:
        state = queue.pop()
        if state in visited:
            continue
        visited.add(state)
        i, j, di, dj = state
        if i < 0 or j < 0 or i >= contraption.nrow or j >= contraption.ncol:
            continue
        panels_visited.add((i, j))
        space = contraption.get(i, j)
        next_dirs = MIRRORS.get((space, di, dj))
        if next_dirs is None:
            i += di
            j += dj
        elif len(next_dirs) == 1:
            di = next_dirs[0][0]
            dj = next_dirs[0][1]
            i += di
            j += dj
        else:
            di = next_dirs[0][0]
            dj = next_dirs[0][1]
            i1 = i + di
            j1 = j + dj
            queue.append((i1, j1, di, dj))
            di = next_dirs[1][0]
            dj = next_dirs[1][1]
            i += di
            j += dj
        queue.append((i, j, di, dj))

    return len(panels_visited)


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

contraption = Contraption(input)
part1 = solve(contraption, (0, 0, 0, 1))
print(f"Part 1 :{part1}")

starts = []
for i in range(0, contraption.nrow):
    starts.append((i, 0, 0, 1))
    starts.append((i, contraption.ncol - 1, 0, -1))
for j in range(0, contraption.ncol):
    starts.append((0, j, 1, 0))
    starts.append((contraption.nrow - 1, j, -1, 0))

part2 = max(solve(contraption, x) for x in starts)
print(f"Part 2: {part2}")

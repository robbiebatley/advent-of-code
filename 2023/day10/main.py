from typing import NamedTuple, List


class Vec(NamedTuple):
    i: int
    j: int


def add(a: Vec, b: Vec) -> Vec:
    return Vec(a.i + b.i, a.j + b.j)


class MovementState(NamedTuple):
    position: Vec
    direction: Vec


class PipeMovement(NamedTuple):
    pipe: str
    direction: Vec


DIRECTIONS = {
    PipeMovement("|", Vec(1, 0)): Vec(1, 0),
    PipeMovement("|", Vec(-1, 0)): Vec(-1, 0),
    PipeMovement("-", Vec(0, 1)): Vec(0, 1),
    PipeMovement("-", Vec(0, -1)): Vec(0, -1),
    PipeMovement("L", Vec(1, 0)): Vec(0, 1),
    PipeMovement("L", Vec(0, -1)): Vec(-1, 0),
    PipeMovement("J", Vec(1, 0)): Vec(0, -1),
    PipeMovement("J", Vec(0, 1)): Vec(-1, 0),
    PipeMovement("7", Vec(0, 1)): Vec(1, 0),
    PipeMovement("7", Vec(-1, 0)): Vec(0, -1),
    PipeMovement("F", Vec(-1, 0)): Vec(0, 1),
    PipeMovement("F", Vec(0, -1)): Vec(1, 0),
}


class Map:
    def __init__(self, input: List[str]):
        self.map = [[x for x in line] for line in input]
        self.n_row = len(self.map)
        self.n_col = len(self.map[0])

        for i, line in enumerate(self.map):
            for j, x in enumerate(line):
                if x == "S":
                    self.start = Vec(i, j)

        # Replace S with actual pipe
        outward_directions = []
        for i, j in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            direction = Vec(i, j)
            pipe = self.get_pipe(add(self.start, Vec(i, j)))
            if PipeMovement(pipe, direction) in DIRECTIONS:
                outward_directions.append(direction)

        if Vec(1, 0) in outward_directions and Vec(-1, 0) in outward_directions:
            start_pipe = "|"
        elif Vec(0, 1) in outward_directions and Vec(0, -1) in outward_directions:
            start_pipe = "-"
        elif Vec(-1, 0) in outward_directions and Vec(0, 1) in outward_directions:
            start_pipe = "L"
        elif Vec(1, 0) in outward_directions and Vec(0, -1) in outward_directions:
            start_pipe = "7"
        elif Vec(-1, 0) in outward_directions and Vec(0, -1) in outward_directions:
            start_pipe = "J`"
        elif Vec(1, 0) in outward_directions and Vec(0, 1) in outward_directions:
            start_pipe = "F"

        self.map[self.start.i][self.start.j] = start_pipe
        self.outward_directions = outward_directions

    def get_pipe(self, position: Vec) -> str:
        if position.i < 0 or position.i >= self.n_row:
            return "."
        if position.j < 0 or position.j >= self.n_col:
            return "."
        return self.map[position.i][position.j]

    def find_first_step(self) -> MovementState:
        dir = self.outward_directions[0]
        coord = add(self.start, dir)
        return MovementState(coord, dir)


def move(current_state: MovementState, map: Map) -> MovementState:
    position, direction = current_state
    pipe = PipeMovement(map.get_pipe(position), direction)
    new_direction = DIRECTIONS[pipe]
    new_position = add(position, new_direction)
    return MovementState(new_position, new_direction)


def get_path(map: Map) -> List[Vec]:
    state = map.find_first_step()
    out = [state.position]
    n = 1
    while True:
        n += 1
        state = move(state, map)
        out.append(state.position)
        if state.position == map.start:
            return out


def solve_part1(map: Map) -> int:
    return len(get_path(map)) // 2


# Think these are all patterns for going for outside (.) to inside the path (*)
# with any number of - inbetween.
# . | *
# . L7 *
# . LJ .
# . FJ *
# . F7 .
def solve_part2(map: Map) -> int:
    path = {c: map.get_pipe(c) for c in get_path(map)}
    n = 0
    for i in range(0, map.n_row):
        is_inside = False
        start_pipe = None
        for j in range(0, map.n_col):
            c = Vec(i, j)
            if c in path:
                pipe = path[c]
                if (
                    pipe == "|"
                    or (start_pipe == "L" and pipe == "7")
                    or (start_pipe == "F" and pipe == "J")
                ):
                    is_inside = not is_inside
                    start_pipe = None
                elif pipe in ("L", "F"):
                    start_pipe = pipe
            elif is_inside:
                n += 1
    return n


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

map = Map(input)

part1 = solve_part1(map)
print(f"Part 1: {part1}")

part2 = solve_part2(map)
print(f"Part 2: {part2}")

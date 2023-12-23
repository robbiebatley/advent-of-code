from typing import NamedTuple, Callable
from collections import defaultdict
from functools import partial

Coord = tuple[int, int]
Map = dict[Coord, str]


class State(NamedTuple):
    path_len: int
    path: list[Coord]


CompressedMap = dict[Coord, list[State]]

NeighboursFn = Callable[State, list[State]]


def parse_input(input: list[str]) -> Map:
    return {
        (i, j): v
        for i, line in enumerate(input)
        for j, v in enumerate(line)
        if v != "#"
    }


def get_end_coord(map: Map) -> Coord:
    last_row = max(i for i, _ in map.keys())
    return [(i, j) for i, j in map.keys() if i == last_row][0]


SLOPES = {
    ">": (0, 1),
    "<": (0, -1),
    "v": (1, 0),
    "^": (-1, 0),
}


def get_neighbours1(state: State, map: Map) -> list[State]:
    out = []
    i, j = state.path[-1]
    for di, dj in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        new_coord = (i + di, j + dj)
        if new_coord in state.path:
            continue
        if new_coord not in map:
            continue
        terrain = map[new_coord]
        if terrain == ".":
            out.append(State(state.path_len + 1, state.path + [new_coord]))
            continue
        new_path = [new_coord]
        dir = SLOPES[terrain]
        # Theres alwas a path after a slope
        new_coord = (new_coord[0] + dir[0], new_coord[1] + dir[1])
        if new_coord in state.path:
            continue
        new_path.append(new_coord)
        out.append(State(state.path_len + 2, state.path + new_path))
    return out


def longest_path(get_neighbours: NeighboursFn, end: Coord) -> int:
    queue = [State(0, [(0, 1)])]
    max_len = 0
    while len(queue) > 0:
        state = queue.pop()
        if state.path[-1] == end:
            if state.path_len > max_len:
                max_len = state.path_len
                continue
        for n in get_neighbours(state):
            queue.append(n)
    return max_len


def explore_path(state: State, map: Map, end: Coord) -> list[State]:
    coord = state.path[-1]
    if coord == end:
        return [state]
    i, j = coord
    new_coords = []
    for di, dj in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        new_coord = (i + di, j + dj)
        if new_coord not in map:
            continue
        if new_coord in state.path:
            continue
        new_coords.append(new_coord)
    if len(new_coords) == 0:
        return []
    if len(new_coords) > 1:
        paths = [state]
        for c in new_coords:
            paths.append(State(1, [state.path[-1], c]))
        return paths
    return explore_path(
        State(state.path_len + 1, state.path + [new_coords[0]]), map, end
    )


def compress_map(map: Map, end: Coord) -> CompressedMap:
    queue = [State(1, [(0, 1), (1, 1)])]
    seen = set()
    paths = {}
    while len(queue) > 0:
        state = queue.pop()
        key = tuple(state.path)
        if key in seen:
            continue
        seen.add(key)
        neighbours = explore_path(state, map, end)
        if len(neighbours) == 0:
            continue
        current = neighbours[0]
        paths[key] = State(current.path_len, [current.path[0]] + [current.path[-1]])
        if len(neighbours) == 1:
            continue
        neighbours = neighbours[1:]
        for n in neighbours:
            queue.append(n)

    cmap = defaultdict(list)
    for state in paths.values():
        cmap[state.path[0]].append(state)

    return cmap


def get_neighbours2(state: State, map: CompressedMap) -> list[State]:
    coord = state.path[-1]
    out = []
    for node in map[coord]:
        next_coord = node.path[1]
        if next_coord in state.path:
            continue
        out.append(State(state.path_len + node.path_len, state.path + [next_coord]))
    return out


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

map = parse_input(input)
end_coord = get_end_coord(map)

neigbours1 = partial(get_neighbours1, map=map)
part1 = longest_path(neigbours1, end_coord)
print(f"Part 1: {part1}")

small_map = compress_map(map, end=end_coord)
neigbours2 = partial(get_neighbours2, map=small_map)
part2 = longest_path(neigbours2, end_coord)
print(f"Part 2: {part2}")

from queue import PriorityQueue
from collections import defaultdict
from typing import NamedTuple


class Map:
    def __init__(self, input: list[str]):
        self.values = [int(x) for line in input for x in line]
        self.nrow = len(input)
        self.ncol = len(input[0])
        assert self.nrow * self.ncol == len(self.values)

    def get(self, i: int, j: int) -> int:
        return self.values[i * self.ncol + j]

    def inbounds(self, i: int, j: int) -> bool:
        return i >= 0 and i < self.nrow and j >= 0 and j < self.ncol


def dist(i: int, j: int, map: Map) -> int:
    return map.ncol - j + map.nrow - i


LEFT_RIGHT = {
    (1, 0): [(0, -1), (0, 1)],
    (-1, 0): [(0, -1), (0, 1)],
    (0, 1): [(-1, 0), (1, 0)],
    (0, -1): [(-1, 0), (1, 0)],
}


class State(NamedTuple):
    i: int
    j: int
    di: int
    dj: int
    n: int


def solve_part1(map: Map) -> int:
    lowest_dist = defaultdict(lambda: 999999999)
    queue = PriorityQueue()

    estimated_dist = dist(0, 0, map)
    s = State(0, 0, 1, 0, 0)
    queue.put((estimated_dist, s))
    lowest_dist[s] = 0
    s = State(0, 0, 0, 1, 0)
    queue.put((estimated_dist, s))
    lowest_dist[s] = 0

    while not queue.empty():
        _, state = queue.get()
        if state.i == map.nrow - 1 and state.j == map.ncol - 1:
            return lowest_dist[state]

        # Continue straight
        if state.n < 2:
            i = state.i + state.di
            j = state.j + state.dj
            if map.inbounds(i, j):
                next_state = State(i, j, state.di, state.dj, state.n + 1)
                current_dist = lowest_dist[state] + map.get(i, j)
                if current_dist < lowest_dist[next_state]:
                    lowest_dist[next_state] = current_dist
                    estimated_dist = current_dist + dist(i, j, map)
                    queue.put((estimated_dist, next_state))

        # Change direction
        for di, dj in LEFT_RIGHT[(state.di, state.dj)]:
            i = state.i + di
            j = state.j + dj
            if map.inbounds(i, j):
                next_state = State(i, j, di, dj, 0)
                current_dist = lowest_dist[state] + map.get(i, j)
                if current_dist < lowest_dist[next_state]:
                    lowest_dist[next_state] = current_dist
                    estimated_dist = current_dist + dist(i, j, map)
                    queue.put((estimated_dist, next_state))


def solve_part2(map: Map) -> int:
    lowest_dist = defaultdict(lambda: 999999999)
    queue = PriorityQueue()

    estimated_dist = dist(0, 0, map)
    s = State(0, 0, 1, 0, 0)
    queue.put((estimated_dist, s))
    lowest_dist[s] = 0
    s = State(0, 0, 0, 1, 0)
    queue.put((estimated_dist, s))
    lowest_dist[s] = 0

    while not queue.empty():
        _, state = queue.get()
        if state.i == map.nrow - 1 and state.j == map.ncol - 1:
            return lowest_dist[state]

        # Continue straight
        if state.n < 9:
            i = state.i + state.di
            j = state.j + state.dj
            if map.inbounds(i, j):
                next_state = State(i, j, state.di, state.dj, state.n + 1)
                current_dist = lowest_dist[state] + map.get(i, j)
                if current_dist < lowest_dist[next_state]:
                    lowest_dist[next_state] = current_dist
                    estimated_dist = current_dist + dist(i, j, map)
                    queue.put((estimated_dist, next_state))

        # Change direction
        for di, dj in LEFT_RIGHT[(state.di, state.dj)]:
            current_dist = lowest_dist[state]
            for n in range(1, 5):
                i = state.i + n * di
                j = state.j + n * dj
                if map.inbounds(i, j):
                    current_dist += map.get(i, j)
            if map.inbounds(i, j):
                next_state = State(i, j, di, dj, 3)
                if current_dist < lowest_dist[next_state]:
                    lowest_dist[next_state] = current_dist
                    estimated_dist = current_dist + dist(i, j, map)
                    queue.put((estimated_dist, next_state))


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

map = Map(input)
part1 = solve_part1(map)
print(f"Part 1: {part1}")

part2 = solve_part2(map)
print(f"Part 2: {part2}")

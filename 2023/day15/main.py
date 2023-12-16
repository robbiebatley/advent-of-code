def hash(x: str) -> int:
    value = 0
    for code in x.encode("ascii"):
        value = (17 * (value + code)) % 256
    return value


class HashMap:
    def __init__(self):
        self.values = [[] for _ in range(0, 256)]

    def remove(self, id: str) -> None:
        loc = hash(id)
        self.values[loc] = [(i, v) for i, v in self.values[loc] if i != id]

    def insert(self, id: str, value: int) -> None:
        loc = hash(id)
        out = []
        found = False
        for i, v in self.values[loc]:
            if i == id:
                out.append((id, value))
                found = True
            else:
                out.append((i, v))
        if not found:
            out.append((id, value))
        self.values[loc] = out


def input_to_hashmap(input: str) -> HashMap:
    hashmap = HashMap()
    for x in input:
        if "-" in x:
            hashmap.remove(x.strip("-"))
        else:
            id, value = x.split("=")
            hashmap.insert(id, int(value))
    return hashmap


def score_box(box: list[tuple[str, int]]) -> int:
    return sum((i + 1) * v[1] for i, v in enumerate(box))


def focusing_power(hashmap: HashMap) -> int:
    return sum((i + 1) * score_box(v) for i, v in enumerate(hashmap.values))


with open("input.txt", mode="r") as f:
    input = f.read().strip("\n").split(",")

part1 = sum(hash(x) for x in input)
print(f"Part 1: {part1}")


part2 = focusing_power(input_to_hashmap(input))
print(f"Part 2: {part2}")

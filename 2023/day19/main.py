from typing import NamedTuple


class Part(NamedTuple):
    x: int
    m: int
    a: int
    s: int

    def rating(self) -> int:
        return self.x + self.m + self.a + self.s


def parse_part(line: str) -> Part:
    x, m, a, s = line.strip("{").strip("}").split(",")
    return Part(int(x[2:]), int(m[2:]), int(a[2:]), int(s[2:]))


# TODO: This would all be a lot easier if I just turned this into a tree
RuleSet = dict[str, list[tuple[str, str, int, str] | tuple[str]]]


def parse_input(input: list[str]) -> tuple[RuleSet, list[Part]]:
    boundary = input.index("")

    rules = input[0:boundary]
    rule_set = {}
    for rule in rules:
        node, rest = rule.split("{")
        rest = rest.strip("}")
        values = []
        for x in rest.split(","):
            if ":" in x:
                temp, to_node = x.split(":")
                if "<" in x:
                    op = "<"
                else:
                    op = ">"
                attr, value = temp.split(op)
                values.append((attr, op, int(value), to_node))
            else:
                values.append((x,))
        rule_set[node] = values

    parts = [parse_part(x) for x in input[(boundary + 1) :]]
    return rule_set, parts


def is_accepted(part: Part, rule_set: RuleSet) -> bool:
    node = "in"
    while True:
        if node == "A":
            return True
        elif node == "R":
            return False
        rules = rule_set[node]
        for rule in rules:
            if len(rule) == 1:
                node = rule[0]
                break
            a, op, val, to = rule
            if op == "<" and getattr(part, a) < val:
                node = to
                break
            if op == ">" and getattr(part, a) > val:
                node = to
                break


class PartRange(NamedTuple):
    x_min: int
    x_max: int
    m_min: int
    m_max: int
    a_min: int
    a_max: int
    s_min: int
    s_max: int

    def combinations(self) -> int:
        return (
            (self.x_max - self.x_min + 1)
            * (self.m_max - self.m_min + 1)
            * (self.a_max - self.a_min + 1)
            * (self.s_max - self.s_min + 1)
        )


def count_combinations(parts: PartRange, rule_set: RuleSet) -> int:
    queue = [("in", parts)]
    n = 0
    while len(queue) > 0:
        node, parts = queue.pop()
        if node == "A":
            n += parts.combinations()
            continue
        elif node == "R":
            continue
        rules = rule_set[node]
        for rule in rules:
            if len(rule) == 1:
                node = rule[0]
                queue.append((node, parts))
                continue

            a, op, val, to = rule
            
            # Really regretting not using a tree...
            if a == "x":
                if op == "<":
                    new_parts = parts._replace(x_max=min(parts.x_max, val - 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(x_min=max(parts.x_min, val))
                else:  # op == ">"
                    new_parts = parts._replace(x_min=max(parts.x_min, val + 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(x_max=min(parts.x_max, val))

            elif a == "m":
                if op == "<":
                    new_parts = parts._replace(m_max=min(parts.m_max, val - 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(m_min=max(parts.m_min, val))
                else:  # op == ">"
                    new_parts = parts._replace(m_min=max(parts.m_min, val + 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(m_max=min(parts.m_max, val))

            elif a == "a":
                if op == "<":
                    new_parts = parts._replace(a_max=min(parts.a_max, val - 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(a_min=max(parts.a_min, val))
                else:  # op == ">"
                    new_parts = parts._replace(a_min=max(parts.a_min, val + 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(a_max=min(parts.a_max, val))

            else:
                if op == "<":
                    new_parts = parts._replace(s_max=min(parts.s_max, val - 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(s_min=max(parts.s_min, val))
                else:  # op == ">"
                    new_parts = parts._replace(s_min=max(parts.s_min, val + 1))
                    queue.append((to, new_parts))
                    parts = parts._replace(s_max=min(parts.s_max, val))

    return n


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

rule_set, parts = parse_input(input)

part1 = sum(p.rating() for p in parts if is_accepted(p, rule_set))
print(part1)

part_range = PartRange(1, 4000, 1, 4000, 1, 4000, 1, 4000)
part2 = count_combinations(part_range, rule_set)
print(part2)

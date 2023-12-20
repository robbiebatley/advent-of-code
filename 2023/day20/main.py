from typing import NamedTuple, Protocol
from enum import Enum
from queue import Queue
from math import lcm


class Pulse(Enum):
    LOW = 1
    HIGH = 2


class Message(NamedTuple):
    sender: str
    receiver: str
    pulse: Pulse


class Module(Protocol):
    def response(self, message: Message) -> list[Message] | None:
        ...

    def state(self) -> int:
        ...


class FlipFlop:
    def __init__(self, id: str, destination_modules: list[str]):
        self.id = id
        self.destinations = destination_modules
        self.on = False

    def __repr__(self) -> str:
        return f"%{self.id} ({'on' if self.on else 'off'}) -> {self.destinations}"

    def response(self, message: Message) -> list[Message] | None:
        if message.pulse == Pulse.HIGH:
            return None
        pulse = Pulse.LOW if self.on else Pulse.HIGH
        self.on = not self.on
        return [Message(self.id, d, pulse) for d in self.destinations]

    def state(self) -> int:
        return 1 if self.on else 0


class Conjuntion:
    def __init__(
        self, id: str, destination_modules: list[str], input_modules: list[str]
    ):
        self.id = id
        self.destinations = destination_modules
        self.inputs = {x: Pulse.LOW for x in input_modules}

    def __repr__(self) -> str:
        return f"&{self.id} -> {self.destinations} ({self.inputs})"

    def response(self, message: Message) -> list[Message]:
        self.inputs[message.sender] = message.pulse
        pulse = Pulse.HIGH if Pulse.LOW in self.inputs.values() else Pulse.LOW
        return [Message(self.id, d, pulse) for d in self.destinations]

    def state(self) -> int:
        out = 0
        for v in self.inputs.values():
            out <<= 1
            if v == Pulse.HIGH:
                out |= 1
        return out


class Broadcast:
    def __init__(self, id: str, destination_modules: list[str]):
        self.id = id
        self.destinations = destination_modules

    def __repr__(self) -> str:
        return f"{self.id} -> {self.destinations}"

    def response(self, message: Message) -> list[Message]:
        pulse = message.pulse
        return [Message(self.id, d, pulse) for d in self.destinations]

    def state(self) -> int:
        return 0


class Button:
    def __init__(self):
        self.id = "button"

    def push(self) -> Message:
        return Message(self.id, "broadcaster", Pulse.LOW)


def parse_input(input: list[str]) -> dict[Module]:
    data = {}
    for line in input:
        id, recievers = line.split(" -> ")
        if id == "broadcaster":
            module_type = "Broadcast"
        elif id[0] == "%":
            module_type = "FlipFlop"
            id = id[1:]
        else:
            module_type = "Conjunction"
            id = id[1:]
        recievers = recievers.split(", ")
        data[id] = (module_type, recievers)

    modules = {}
    for id, mr in data.items():
        module_type, recievers = mr
        if module_type == "Broadcast":
            modules[id] = Broadcast(id, recievers)
        elif module_type == "FlipFlop":
            modules[id] = FlipFlop(id, recievers)
        else:
            inputs = [k for k, v in data.items() if id in v[1]]
            modules[id] = Conjuntion(id, recievers, inputs)

    return modules


def press_button(modules: dict[Module]) -> tuple[tuple[int, ...], int, int]:
    button = Button()
    queue = Queue()
    queue.put(button.push())
    n_low = 0
    n_high = 0
    while not queue.empty():
        message = queue.get()
        if message.pulse == Pulse.HIGH:
            n_high += 1
        else:
            n_low += 1
        if message.receiver not in modules:
            continue
        receiver_module = modules[message.receiver]
        next_messages = receiver_module.response(message)
        if next_messages is None:
            continue
        for message in next_messages:
            queue.put(message)

    state = tuple([x.state() for x in modules.values()])
    return state, n_low, n_high


with open("input.txt", mode="r") as f:
    input = [x.strip() for x in f.readlines()]

modules = parse_input(input)

rounds = {}
i = 0
while i < 1000:
    state, low, high = press_button(modules)
    if state in rounds:
        break
    rounds[state] = (low, high)
    i += 1
# Did not terminate before 1000 rounds

low = sum(low for low, _ in rounds.values())
high = sum(high for _, high in rounds.values())
part1 = low * high
print(f"Part 1: {part1}")


def press_button2(modules: dict[Module], target: str, pulse_type: Pulse) -> bool:
    button = Button()
    queue = Queue()
    queue.put(button.push())
    while not queue.empty():
        message = queue.get()
        if message.receiver not in modules:
            continue
        receiver_module = modules[message.receiver]
        next_messages = receiver_module.response(message)
        if next_messages is None:
            continue
        for message in next_messages:
            if message.sender == target and message.pulse == pulse_type:
                return True
            queue.put(message)

    return False


# My input looked like this
# &hn -> xn
# &mp -> xn
# &xf -> xn
# &xn -> rx
# &fz -> xn
# So rx depends on the state of hn, mp, xf, fx
# I manually checked how long it takes for each of these nodes to change state.
# I figured that this problem wasn't going to be able to be brute forced and
# was going to be something similar to day 8, so I randomly tried the lowest common
# multiple which worked. I have zero idea why this works - nothing in the problem
# seems to guarantee that there would be cycles

# modules = parse_input(input)
# i = 1
# while not press_button2(modules, "hn", Pulse.HIGH):
#     i += 1
# print(i)

# hn -> 3847
# mp -> 3877
# xf -> 3769
# fx -> 4057

print(lcm(3847, 3877, 3769, 4057))

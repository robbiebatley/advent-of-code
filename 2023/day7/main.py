from typing import List, NamedTuple, Dict, Callable, Tuple
from collections import Counter
from functools import partial


class Hand(NamedTuple):
    cards: List[str]
    bid: int


CARD_VALUES = {str(i): i for i in range(2, 10)}
CARD_VALUES.update(
    {
        "T": 10,
        "J": 11,
        "Q": 12,
        "K": 13,
        "A": 14,
    }
)

CARD_VALUES2 = CARD_VALUES
CARD_VALUES2["J"] = 1


def read_input(file: str) -> List[str]:
    with open(file, mode="r") as f:
        out = [x.strip() for x in f.readlines()]
    return out


def parse_line(line: str) -> Hand:
    cards, bid = line.split(" ")
    cards = [c for c in cards]
    bid = int(bid)
    return Hand(cards, bid)


def hand_type(hand: Hand) -> int:
    counts = Counter(hand.cards).most_common(2)
    first = counts[0][1]
    if first == 5:
        second = 0
    else:
        second = counts[1][1]
    if first == 5:
        return 6
    elif first == 4:
        return 5
    elif first == 3 and second == 2:
        return 4
    elif first == 3:
        return 3
    elif first == 2 and second == 2:
        return 2
    elif first == 2:
        return 1
    else:
        return 0


def hand_type2(hand: Hand) -> int:
    n_jokers = len([c for c in hand.cards if c == "J"])
    if n_jokers == 5:
        return 6
    counts = Counter(c for c in hand.cards if c != "J").most_common(2)
    first = counts[0][1]
    if len(counts) == 1:
        second = 0
    else:
        second = counts[1][1]
    if first + n_jokers == 5:
        return 6
    elif first + n_jokers == 4:
        return 5
    elif first + second + n_jokers == 5:
        return 4
    elif first + n_jokers == 3:
        return 3
    elif (
        n_jokers >= 2 or (n_jokers == 1 and first == 2) or (first == 2 and second == 2)
    ):
        return 2
    elif n_jokers == 1 or first == 2:
        return 1
    else:
        return 0


def hand_order(
    hand: Hand, hand_type: Callable[Hand, int], card_values: Dict[str, int]
) -> Tuple[int, List[int]]:
    return (hand_type(hand), [card_values[c] for c in hand.cards])


input = read_input("input.txt")
hands = [parse_line(x) for x in input]

sort1 = partial(hand_order, hand_type=hand_type, card_values=CARD_VALUES)
hands.sort(key=sort1)
part1 = sum((i + 1) * h.bid for (i, h) in enumerate(hands))
print(f"Part 1: {part1}")

sort2 = partial(hand_order, hand_type=hand_type2, card_values=CARD_VALUES2)
hands.sort(key=sort2)
part2 = sum((i + 1) * h.bid for (i, h) in enumerate(hands))
print(f"Part 2: {part2}")

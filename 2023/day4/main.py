from typing import List


def read_input(file: str) -> List[str]:
    with open(file, mode="r") as f:
        out = f.readlines()
    return [l.replace("\n", "") for l in out]


def card_matches(card: str) -> int:
    _, numbers = card.split(":")
    win, drawn = numbers.split("|")
    win = win.strip().split(" ")
    drawn = drawn.strip().split(" ")
    win = {int(x) for x in win if x != ""}
    drawn = {int(x) for x in drawn if x != ""}
    return len(win.intersection(drawn))


def main() -> None:
    input = read_input("input.txt")
    matches = [card_matches(c) for c in input]

    part1 = sum(2 ** (n - 1) for n in matches if n > 0)
    print(f"Part 1: {part1}")

    n_cards = len(input)
    cards = [1 for _ in range(0, n_cards)]
    for i, m in enumerate(matches):
        n = cards[i]
        if m == 0:
            continue
        for j in range(i + 1, min(i + m + 1, n_cards)):
            cards[j] = cards[j] + n

    part2 = sum(cards)
    print(f"Part 2: {part2}")


if __name__ == "__main__":
    main()

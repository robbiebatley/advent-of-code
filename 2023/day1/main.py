from typing import Optional, Iterable, Callable

Parser = Callable[[str], int]


def solution(input: Iterable[str], parser: Parser) -> int:
    numbers = (parser(line) for line in input)
    return sum(numbers)


# Part 1
def parse_number(x: str) -> int:
    numbers = [int(c) for c in x if c.isnumeric()]
    return 10 * numbers[0] + numbers[-1]


# Part 2
WORDS = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]


def check_word(s: str, word: str, index: int) -> bool:
    end = index + len(word)
    return end <= len(s) and s[index:end] == word


def check_words(s: str, index) -> Optional[int]:
    for i, word in enumerate(WORDS):
        if check_word(s, word, index):
            return i + 1
    return None


def parse_number2(x: str) -> int:
    numbers = []
    for index, v in enumerate(x):
        if v.isnumeric():
            numbers.append(int(v))
            continue
        value = check_words(x, index)
        if value:
            numbers.append(value)
    return 10 * numbers[0] + numbers[-1]


def main() -> None:
    with open("input.txt", "r") as f:
        input = f.readlines()

    part1 = solution(input, parse_number)
    print(f"Part 1: {part1}")

    part2 = solution(input, parse_number2)
    print(f"Part 2: {part2}")


if __name__ == "__main__":
    main()

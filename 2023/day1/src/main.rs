use std::fs::read_to_string;

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

fn solution<F>(input: &[String], parser: F) -> u32
where
    F: Fn(&str) -> u32,
{
    input.iter().map(|x| parser(x)).sum()
}

fn main() {
    let input = read_input("input.txt");

    let part1: u32 = solution(&input, parser_1);
    println!("{}", part1);

    let part2: u32 = solution(&input, parser_2);
    println!("{}", part2);
}

// Part 1
fn parser_1(line: &str) -> u32 {
    let mut digits = line.chars().flat_map(|x| x.to_digit(10));
    let first_digit = digits.next();
    let last_digit = digits.last();
    match (first_digit, last_digit) {
        (Some(f), Some(l)) => 10 * f + l,
        (Some(f), None) => 10 * f + f,
        _ => panic!("Unable to parse line: {}", line),
    }
}

// Part 2
const DIGITS: [&str; 9] = [
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
];

fn check_word(line: &str, index: usize) -> Option<usize> {
    for (i, v) in DIGITS.into_iter().enumerate() {
        let end = index + v.len();
        if end <= line.len() && &line[index..end] == v {
            return Some(i + 1);
        }
    }
    None
}

fn check_digit(line: &str, index: usize) -> Option<usize> {
    (line[index..(index + 1)]).parse::<usize>().ok()
}

fn parse_at_index(line: &str, index: usize) -> Option<usize> {
    if let Some(x) = check_digit(line, index) {
        return Some(x);
    }
    check_word(line, index)
}

fn parser_2(line: &str) -> u32 {
    let n = line.len();
    let mut digits = (0..n).flat_map(|i| parse_at_index(line, i));
    let first_digit = digits.next();
    let last_digit = digits.last();
    let out = match (first_digit, last_digit) {
        (Some(f), Some(l)) => 10 * f + l,
        (Some(f), None) => 10 * f + f,
        _ => panic!("Unable to parse line: {}", line),
    };
    out.try_into().unwrap()
}

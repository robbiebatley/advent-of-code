use std::fs::read_to_string;

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

#[derive(Debug)]
struct Number {
    value: u32,
    row: usize,
    start: usize,
    end: usize,
}

#[derive(Debug)]
struct Symbol {
    row: usize,
    col: usize,
}

fn extract_numbers(input: &[String]) -> Vec<Number> {
    let mut out: Vec<Number> = Vec::new();
    let n_col = input[0].len();
    let mut _start: Option<usize> = None;
    for (row, line) in input.iter().enumerate() {
        _start = None;
        for (j, c) in line.chars().enumerate() {
            if _start.is_none() && c.is_ascii_digit() {
                _start = Some(j);
            }
            if _start.is_some() && (!c.is_ascii_digit() || j + 1 == n_col) {
                let start = _start.unwrap();
                let end = if !c.is_ascii_digit() { j } else { j + 1 };
                let value: u32 = line[start..end].parse().unwrap();
                let number = Number {
                    value,
                    row,
                    start,
                    end,
                };
                out.push(number);
                _start = None;
            }
        }
    }
    out
}

// TODO: can probably do this with iterator traits
fn extract_symbols(input: &[String]) -> Vec<Symbol> {
    let mut out: Vec<Symbol> = Vec::new();
    for (row, line) in input.iter().enumerate() {
        for (col, value) in line.chars().enumerate() {
            if value != '.' && !value.is_ascii_digit() {
                out.push(Symbol { row, col });
            }
        }
    }
    out
}
fn adjacent(number: &Number, symbol: &Symbol) -> bool {
    (number.row >= symbol.row - 1)
        && (number.row <= symbol.row + 1)
        && (number.start <= symbol.col + 1)
        && (number.end >= symbol.col)
}

fn gear_ratio(symbol: &Symbol, numbers: &[Number]) -> Option<u32> {
    let adjacent_numbers: Vec<&Number> = numbers.iter().filter(|n| adjacent(n, symbol)).collect();
    if adjacent_numbers.len() == 2 {
        return Some(adjacent_numbers[0].value * adjacent_numbers[1].value);
    };
    None
}

fn main() {
    let input = read_input("input.txt");
    let numbers = extract_numbers(&input);
    let symbols = extract_symbols(&input);
    let part1: u32 = numbers
        .iter()
        .filter(|n| symbols.iter().any(|s| adjacent(n, s)))
        .map(|n| n.value)
        .sum();

    println!("Part 1: {}", part1);

    let part2: u32 = symbols.iter().flat_map(|s| gear_ratio(s, &numbers)).sum();

    println!("Part 2: {}", part2);
}

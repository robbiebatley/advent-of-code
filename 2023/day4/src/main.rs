use std::fs::read_to_string;
use::std::cmp::min;

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

fn number_matches(card: &str) -> usize {
    let mut values = card.split(':').nth(1).unwrap().split('|');

    let winning: Vec<usize> = values
        .next()
        .expect("Should be winning values")
        .split(' ')
        .flat_map(|x| x.parse::<usize>())
        .collect();

    values
        .next()
        .expect("Should be drawn values")
        .split(' ')
        .flat_map(|x| x.parse::<usize>())
        .filter(|v| winning.contains(v))
        .count()
}

fn main() {
    let input = read_input("input.txt");
    let matches: Vec<usize> = input
        .iter()
        .map(|s| number_matches(s))
        .collect();
    
    let part1: usize = matches
        .iter()
        .filter(|&n| *n != 0)
        .map(|n| 1 << (n - 1))
        .sum();

    println!("Part 1: {}", part1);

    let n_cards = matches.len();
    let mut cards = vec![1; n_cards];
    for (i, m) in matches.iter().enumerate().filter(|(_, &m)| m > 0) {
        let end = min(i + m + 1, n_cards);
        for j in (i + 1)..end {
            let n = cards[i]; 
            cards[j] += n;
        }
    }

    let part2: usize = cards.iter().sum();

    println!("Part 2: {}", part2);
}

use std::fs::read_to_string;
use std::str::FromStr;

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

#[derive(Debug, PartialEq, Clone, Copy)]
struct Game {
    id: u32,
    red: u32,
    blue: u32,
    green: u32,
}

#[derive(Debug, PartialEq, Eq)]
struct ParseGameError;

impl FromStr for Game {
    type Err = ParseGameError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split(':');
        let game = parts.next().unwrap();
        let id: u32 = game.split(' ').nth(1).unwrap().parse().unwrap();

        let draws = parts
            .next()
            .unwrap()
            .split(';')
            .flat_map(|x| x.split(','))
            .map(|x| x.trim());

        // Problem only needs max draw, otherwise store vector of draws for each
        // colour
        let mut red: u32 = 0;
        let mut blue: u32 = 0;
        let mut green: u32 = 0;
        for draw in draws {
            match draw.split_once(' ') {
                Some((i, "red")) => {
                    let n: u32 = i.parse().unwrap();
                    if n > red {
                        red = n;
                    };
                }
                Some((i, "blue")) => {
                    let n: u32 = i.parse().unwrap();
                    if n > blue {
                        blue = n;
                    };
                }
                Some((i, "green")) => {
                    let n: u32 = i.parse().unwrap();
                    if n > green {
                        green = n;
                    };
                }
                _ => return Err(ParseGameError),
            }
        }
        Ok(Game {
            id,
            red,
            blue,
            green,
        })
    }
}

fn main() {
    let input = read_input("input.txt");
    let games: Vec<Game> = input
        .into_iter()
        .map(|x| Game::from_str(&x).unwrap())
        .collect();

    let part1: u32 = games
        .iter()
        .filter(|g| g.red <= 12 && g.blue <= 14 && g.green <= 13)
        .map(|g| g.id)
        .sum();

    println!("Part 1: {}", part1);

    let part2: u32 = games.iter().map(|g| g.red * g.blue * g.green).sum();

    println!("Part 2: {}", part2);
}

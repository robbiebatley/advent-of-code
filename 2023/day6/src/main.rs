use std::fs::read_to_string;


fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

fn parse_numbers(line: &str) -> Vec<u64> {
    line
        .split(':')
        .nth(1)
        .unwrap()
        .split(' ')
        .flat_map(|x| x.parse::<u64>())
        .collect()
}

fn number_solutions(time: u64, dist: u64) -> u64 {
    let dist = dist as f64;
    let time = time as f64;
    let disc = (time * time - 4.0 * dist).sqrt();
    let lower = (time - disc) / 2.0;
    let upper = (time + disc) / 2.0;
    let lower = lower.trunc() + 1.0;
    let upper = if upper.fract() == 0.0 {upper.trunc() - 1.0} else {upper.trunc()};
    (upper - lower + 1.0) as u64
}

fn main() {

    let input = read_input("input.txt");

    let times: Vec<u64> = parse_numbers(input.get(0).unwrap());
    let distances: Vec<u64> = parse_numbers(input.get(1).unwrap());

    let part1: u64 = times
        .iter()
        .zip(distances.iter())
        .map(|(t, d)| number_solutions(*t, *d))
        .product();

    println!("Part 1: {:?}", part1);

    let time = times.iter().map(|x| x.to_string()).collect::<Vec<String>>().join("").parse::<u64>().unwrap();
    let distance = distances.iter().map(|x| x.to_string()).collect::<Vec<String>>().join("").parse::<u64>().unwrap();
    let part2 = number_solutions(time, distance);

    println!("Part 2: {:?}", part2);

}

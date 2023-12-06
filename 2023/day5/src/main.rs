use std::fs::read_to_string;

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

#[derive(Debug, Clone, Copy)]
struct RangeMap {
    start: i64,
    end: i64,
    increment: i64,
}

#[derive(Debug, Clone, Copy)]
struct Range {
    start: i64,
    end: i64,
}

type Map = Vec<RangeMap>;
type Seeds = Vec<i64>;

fn parse_seeds(input: &[String]) -> Seeds {
    input
        .get(0)
        .unwrap()
        .split(": ")
        .nth(1)
        .unwrap()
        .split(' ')
        .map(|x| x.parse::<i64>().unwrap())
        .collect()
}

fn parse_maps(input: &[String]) -> Vec<Map>{
    let mut maps_input = input
        .iter()
        .skip(3);

    // TODO: figure out how group_by works
    let mut map: Vec<RangeMap> = Vec::new();
    let mut maps: Vec<Vec<RangeMap>> = Vec::new();
    while let Some(x) = maps_input.next() {
        if x.is_empty() {
            maps.push(map);
            map = Vec::new();
            // Skip label
            maps_input.next();
            continue;
        }
        let mut numbers = x.split(' ');
        let dest = numbers.next().unwrap().parse::<i64>().unwrap();
        let source = numbers.next().unwrap().parse::<i64>().unwrap();
        let len = numbers.next().unwrap().parse::<i64>().unwrap();
        let range_map = RangeMap{start: source, end: source + len, increment: dest - source,};
        map.push(range_map);
    }
    maps.push(map);
    maps
}

fn apply_map(x: i64, map: &Map) -> i64 {
    
    for range_map in map {
        if x >= range_map.start && x <= range_map.end {
            return x + range_map.increment;
        }
    }
    x
}

fn apply_map2(seed: &Range, map: &Map) -> Vec<Range> {
    let mut queue: Vec<Range> = vec![seed.clone()];
    let mut out: Vec<Range> = Vec::new();
    while let Some(s) = queue.pop() {
        let mut found = false;
        for m in map.iter() {
            // Overlap
            if s.start <= m.end && s.end >= m.start {
                found = true;
                if s.start >= m.start && s.end <= m.end {
                    out.push(Range{start: s.start + m.increment, end: s.end + m.increment});
                } else if s.end <= m.end {
                    out.push(Range{start: m.start + m.increment, end: s.end + m.increment});
                    queue.push(Range{start: s.start, end: m.start - 1});
                } else if s.start >= m.start && s.end > m.end {
                    out.push(Range{start: s.start + m.increment, end: m.end + m.increment});
                    queue.push(Range{start: m.end + 1, end: s.end})
                } else {
                    out.push(Range{start: m.start + m.increment, end: m.end + m.increment});
                    queue.push(Range{start: s.start, end: m.start - 1});
                    queue.push(Range{start: m.end + 1, end: s.end});
                }
            }
        }
        if !found {
            out.push(s);
        }
    }
    out
}

fn map_all_ranges(seed_ranges: Vec<Range>, map: &Map) -> Vec<Range> {
    seed_ranges
        .iter()
        .flat_map(|s| apply_map2(s, map))
        .collect()
}

fn main() {
    
    let input = read_input("input.txt");
    let seeds = parse_seeds(&input);
    let maps = parse_maps(&input);

    let part1 = seeds
        .iter()
        .map(|&x| maps.iter().fold(x, apply_map)) 
        .min()
        .unwrap();
    
    println!("Part 1: {}", part1);

    let starts = seeds.iter().step_by(2);
    let ends = seeds.iter().skip(1).step_by(2);
    let seed_ranges: Vec<Range> = starts
        .zip(ends)
        .map(|(start, end)| Range{start: *start, end: *start + *end - 1})
        .collect();

    let part2 = maps
        .iter()
        .fold(seed_ranges, map_all_ranges)
        .iter()
        .map(|r| r.start)
        .min()
        .unwrap();

    println!("Part 2: {:?}", part2);

}

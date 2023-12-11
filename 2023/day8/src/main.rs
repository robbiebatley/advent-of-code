use regex::Regex;
use std::collections::HashMap;
use std::fs::read_to_string;

#[derive(Debug)]
enum Direction {
    Left,
    Right,
}

#[derive(Debug, Hash, PartialEq, Eq, Clone, Copy)]
struct Node {
    id: [u8; 3],
}

#[derive(Debug)]
struct Network {
    directions: Vec<Direction>,
    edges: HashMap<Node, (Node, Node)>,
}

#[derive(Debug, Eq, Hash, PartialEq)]
struct PathState {
    terminal_node: Node,
    direction_position: usize,
}

#[derive(Debug)]
struct Cycle {
    length: u64,
    end: u64,
}

impl TryFrom<&str> for Node {
    type Error = &'static str;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let id = TryInto::<[u8; 3]>::try_into(value.as_bytes());
        match id {
            Ok(id) => Ok(Node { id }),
            Err(_) => Err("Unable to parse Node"),
        }
    }
}

impl Network {
    fn traverse_network(&self, start_node: &Node, end_node: &Node) -> Option<u64> {
        let n_dirs = self.directions.len() as u64;
        let mut n: u64 = 0;
        let mut node = start_node;
        while let Some((left, right)) = self.edges.get(node) {
            node = match self.directions.get((n % n_dirs) as usize) {
                Some(Direction::Left) => left,
                Some(Direction::Right) => right,
                _ => panic!("Unable to determine direction when traversing network"),
            };
            n += 1;
            if node == end_node {
                return Some(n);
            }
        }
        None
    }

    fn find_cycle(&self, start_node: &Node) -> Option<Cycle> {
        let n_dirs = self.directions.len() as u64;
        let mut n: u64 = 0;
        let mut node = start_node;
        let mut states_seen = HashMap::<PathState, u64>::new();
        while let Some((left, right)) = self.edges.get(node) {
            let direction_position = (n % n_dirs) as usize;
            node = match self.directions.get(direction_position) {
                Some(Direction::Left) => left,
                Some(Direction::Right) => right,
                _ => panic!("Unable to determine direction when traversing network"),
            };
            n += 1;
            if node.id[2] == b'Z' {
                let path_state = PathState {
                    terminal_node: node.to_owned(),
                    direction_position,
                };
                if states_seen.contains_key(&path_state) {
                    let prev_state = states_seen.get(&path_state).unwrap();
                    let length = n - prev_state;
                    return Some(Cycle { length, end: n });
                }
                states_seen.insert(path_state, n);
            }
        }
        None
    }
}

impl Cycle {
    fn next_step(&mut self) {
        self.end += self.length;
    }
}

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

// Theres probably a smarter way to avoid allocating new strings to heap such as using u8 array
fn parse_edge_mapping(s: &String) -> (Node, (Node, Node)) {
    let re = Regex::new(r"^(?<from>\w+) = \((?<left>\w+), (?<right>\w+)\)$").unwrap();
    let caps = re.captures(s).unwrap();
    let from = Node::try_from(caps.name("from").unwrap().as_str()).unwrap();
    let left = Node::try_from(caps.name("left").unwrap().as_str()).unwrap();
    let right = Node::try_from(caps.name("right").unwrap().as_str()).unwrap();
    (from, (left, right))
}

fn parse_input(input: &[String]) -> Network {
    let directions = input
        .get(0)
        .unwrap()
        .chars()
        .map(|c| match c {
            'L' => Direction::Left,
            'R' => Direction::Right,
            _ => panic!(),
        })
        .collect();

    let edges = HashMap::from_iter(input.iter().skip(2).map(parse_edge_mapping));
    Network { directions, edges }
}

// Pretty slow due probably due to all the string allocations but works
fn main() {
    let input = read_input("input.txt");
    let network = parse_input(&input);
    let part1 = network
        .traverse_network(
            &Node::try_from("AAA").unwrap(),
            &Node::try_from("ZZZ").unwrap(),
        )
        .unwrap();

    println!("{:?}", part1);

    let start_nodes: Vec<&Node> = network.edges.keys().filter(|&x| x.id[2] == b'A').collect();

    let mut cycles: Vec<Cycle> = start_nodes
        .iter()
        .map(|x| network.find_cycle(x).unwrap())
        .collect();

    cycles.sort_by_key(|k| k.end);
    let mut max_cycle = cycles.pop().unwrap();
    loop {
        let found = cycles
            .iter()
            .filter(|c| max_cycle.end.checked_sub(c.end).unwrap() % c.length != 0)
            .count();
        if found == 0 {
            break;
        }
        max_cycle.next_step();
    }
    let part2 = max_cycle.end;
    println!("{:?}", part2);
}

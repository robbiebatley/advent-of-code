use std::fs::read_to_string;

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
enum Card {
    N2,
    N3,
    N4,
    N5,
    N6,
    N7,
    N8,
    N9,
    T,
    J,
    Q,
    K,
    A,
}

impl TryFrom<char> for Card {
    type Error = &'static str;

    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '2' => Ok(Card::N2),
            '3' => Ok(Card::N3),
            '4' => Ok(Card::N4),
            '5' => Ok(Card::N5),
            '6' => Ok(Card::N6),
            '7' => Ok(Card::N7),
            '8' => Ok(Card::N8),
            '9' => Ok(Card::N9),
            'T' => Ok(Card::T),
            'J' => Ok(Card::J),
            'Q' => Ok(Card::Q),
            'K' => Ok(Card::K),
            'A' => Ok(Card::A),
            _ => Err("Unable to parse card"),
        }
    }
}

#[derive(Debug, PartialEq)]
struct Hand {
    cards: [Card; 5],
    bid: i32,
}

impl TryFrom<&String> for Hand {
    type Error = &'static str;

    fn try_from(value: &String) -> Result<Self, Self::Error> {
        let cards = TryInto::<[Card; 5]>::try_into(
            value
                .split(' ')
                .nth(0)
                .unwrap()
                .chars()
                .map(|x| Card::try_from(x).unwrap())
                .collect::<Vec<Card>>(),
        );

        let bid = value.split(' ').nth(1).unwrap().parse::<i32>();

        match (cards, bid) {
            (Ok(cards), Ok(bid)) => Ok(Hand { cards, bid }),
            _ => Err("Unable to parse hand"),
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
enum HandType {
    HighCard,
    OnePair,
    TwoPair,
    ThreeOfAKind,
    FullHouse,
    FourOfAKind,
    FiveOfAKind,
}


fn hand_type_jack(hand: &Hand) -> HandType {
    let mut counts = [0; 13];
    for card in hand.cards.iter(){
        counts[*card as usize] += 1;
    }
    counts.sort();
    counts.reverse();
    let most_common = counts.first();
    let second_most_common = counts.get(1);

    match (most_common, second_most_common) {
        (Some(5), _) => HandType::FiveOfAKind,
        (Some(4), _) => HandType::FourOfAKind,
        (Some(3), Some(2)) => HandType::FullHouse,
        (Some(3), _) => HandType::ThreeOfAKind,
        (Some(2), Some(2)) => HandType::TwoPair,
        (Some(2), _) => HandType::OnePair,
        _ => HandType::HighCard,
    }
}

fn hand_value_jack(hand: &Hand) -> u64 {
    // all enums < 16 so can store with 4 bits
    let mut value = hand_type_jack(hand) as u64;
    for card in hand.cards {
        value = (value << 4) | (card as u64);
    }
    value
}

fn hand_type_joker(hand: &Hand) -> HandType {
    let mut counts = [0; 13];
    for card in hand.cards.iter(){
        counts[*card as usize] += 1;
    }
    let n_jokers = counts[Card::J as usize];
    counts[Card::J as usize] = 0;
    counts.sort();
    counts.reverse();
    let most_common = counts[0];
    let second_most_common = counts[1];
    if n_jokers + most_common == 5 {
        HandType::FiveOfAKind
    } else if n_jokers + most_common == 4 {
         HandType::FourOfAKind
    } else if n_jokers + most_common + second_most_common == 5 {
         HandType::FullHouse
    } else if n_jokers + most_common == 3 {
        HandType::ThreeOfAKind
    } else if n_jokers + most_common + second_most_common == 4 {
        HandType::TwoPair
    } else if n_jokers == 1 || most_common == 2 {
        HandType::OnePair
    } else {
        HandType::HighCard
    }
}

fn hand_value_joker(hand: &Hand) -> u64 {
    // all enums < 16 so can store with 4 bits
    let mut value = hand_type_joker(hand) as u64;
    for card in hand.cards {
        let card_value = if card == Card::J {1} else {(card as u64) + 2};
        value = (value << 4) | card_value;
    }
    value
}

fn read_input(filename: &str) -> Vec<String> {
    read_to_string(filename)
        .unwrap()
        .lines()
        .map(String::from)
        .collect()
}

fn main() {
    let input = read_input("input.txt");

    let mut hands: Vec<Hand> = input
        .iter()
        .map(|x| Hand::try_from(x).expect("Should be able to parse all hands"))
        .collect();

    hands.sort_by_cached_key(hand_value_jack);
    let part1: i32 = hands
        .iter()
        .enumerate()
        .map(|(i, h)| h.bid * (i as i32 + 1))
        .sum();

    println!("Part 1: {:?}", part1);

    hands.sort_by_cached_key(hand_value_joker);
    let part2: i32 = hands
        .iter()
        .enumerate()
        .map(|(i, h)| h.bid * (i as i32 + 1))
        .sum();


    println!("Part 2: {:?}", part2);

}

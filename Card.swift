//
//  Card.swift
//  pusoy2
//
//  Created by Alexander Gunning on 7/31/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import Foundation

/**
 LOWER_CARD is the lowest value of cards
 */
let LOWER_CARD : Int = 0
/**
 HIGHEST_CARD is the highest value of cards
 */
let HIGHEST_CARD : Int = 51
/**
 CARDS_PER_SUIT is the number of cards per suit
 */
let CARDS_PER_SUIT : Int = 13
/**
 NUM_SUITS is the number of total suits
 */
let NUM_SUITS : Int = 4

struct Card: Equatable
{
    /**
     
     */
    //member values
    
    // rank52 of card
    //♥️♦️♠️♣️
    /**
            rank52 is integer ranking on 0 to 51 scale that sorts cards by 3-2S♣️...3-2♦️
    */
    let m_Rank52 : Int

 /**   private(set) lazy var m_Suit: Suit =
    {
        
        let suitRawValue = self.m_Rank52%13
        //Force unrwap because we know that suitRawValue is between 0-51
        let cardSuit = Suit(rawValue: suitRawValue)!
        return cardSuit
    }()*/
    /**
    rank13 value of card 3->0,4->1,...,2->12
     */
    let m_Rank13 : Int
    let m_RankStr : String
    
    let m_Rank52Alt : Int
    let unicodeStr : String
    /**
     suit is the Suit of the card
     ranked in order ♣️♠️♥️♦️
     */
    let m_Suit: Suit
    /**
        rank13 value of card 3->0,4->1,...,2->12
    */
 /*   private(set) lazy var m_Rank13: Int =
    {
        return  self.m_Rank52%13
    }()*/
    /**
        Rank52Alt rank based on a 0 - 51 scale
        0♣️0♠️0♥️0♦️-2♣️2♠️2♥️2♦️
     
     */
   private(set) lazy var m_Rank52AltLazy: Int =
    {
        //(Suit 0-3 value * 13) + rank13
        return  (self.m_Suit.rawValue*13) + self.m_Rank13
    }()
    /**
     Player who owns card
    */
    var owner : Player?
    /**
     
     //TODO: Figure out how to make the suit enum of type struct
     
     Inititalizer
     
     init?(cardRank : Int)
     
     -parameter rank52: Integer
     
     -returns: Optional Suit
     */
    init(rank52 : Int, player : Player? = nil)
    {
        //Can't use self values until initializer is finished
        //TODO: Investigate above
        assert(rank52 >= 0 && rank52 <= 51,"Card Class Based upon assumption that card values are between 0-51")
        self.m_Rank52 = rank52
        self.m_Rank13 = rank52%CARDS_PER_SUIT
        self.m_Suit = Suit(rawValue: rank52/CARDS_PER_SUIT)!
        self.m_Rank52Alt = (m_Rank13*4)+m_Suit.rawValue
        self.owner = player
        // we know that the rankstr will be a valid value
        switch self.m_Rank13
        {
        case 0...7:
            self.m_RankStr = "\(self.m_Rank13+3)"
        case 8:
            self.m_RankStr = "J"
        case 9:
            self.m_RankStr = "Q"
        case 10:
            self.m_RankStr = "K"
        case 11:
            self.m_RankStr = "A"
        case 12:
            self.m_RankStr = "2"
        default:
            assert(false)
            self.m_RankStr = "FAILED RANK STR"
        }
        
        switch self.m_Suit{
        case .Clubs:
            unicodeStr = "♣️"
        case .Spades:
            unicodeStr = "♠️"
        case .Hearts:
            unicodeStr = "♥️"
        case .Diamonds:
            unicodeStr = "♦️"
        }
    }
    //TODO MAKE SURE
    init( rank13 : Int,  suit : Suit)
    {
       self.init(rank52 : CARDS_PER_SUIT * suit.rawValue + rank13)
    }
    /**
     Add copy constructor/ assignment operator to set player to nil
    */
    /*    func sorterForRank13(this:Card, that:Card) -> Bool {
        return this.m_Rank13 > that.m_Rank13
    }*/
    
    //Helper Constants

}
/**
 TODO: are these a good idea? 
 Could lead to ambiguity in the future.
 */
func ==(lhs: Card, rhs: Card) -> Bool
{
    
    return true
}

func <(lhs: Card, rhs: Card) -> Bool
{
    return true
}

func >(lhs: Card, rhs: Card) -> Bool
{
    return (lhs > rhs)
}

/**
 Deck is the entire array of cards in order of their rank52 value
 */
struct Deck
{
    /**
     cards is the entire array of cards in order of their rank52 value
     */
    static var cards : [Card] =
    {
        var cardArray = [Card]()
        for cardVal in 0..<52
        {
            cardArray.append(Card(rank52: cardVal))
        }
        return cardArray
    }()
    /** 
        Set the hands for each of the players 
     
    */
    static func shuffledCards(numCards : Int, numPlayers: Int, players : inout [Player]) -> Int
    {
        //ALEX FIX NOT SURE IF USE ANYWAYS
        var firstPlayer = Int?(-1)
        var lowCard = HIGHEST_CARD + 1
        var newNumber = [Int]()
        for i in 0..<52
        {
            newNumber.append(i)
        }
        let totalNumCards = numCards*numPlayers
        var cardsDealt = 0
        //Continues until we have dealt correct number of cards
        //
        while cardsDealt != totalNumCards
        {
            let cardNum = Int(arc4random_uniform(UInt32(newNumber.count)))
            if newNumber[cardNum] < lowCard
            {
                lowCard =  newNumber[cardNum]
                firstPlayer = cardsDealt/numCards
            }
            players[cardsDealt/numCards].m_Hand.append(Card(rank52: newNumber[cardNum], player: players[cardsDealt/numCards]))
            cardsDealt += 1
            newNumber.remove(at: cardNum)
        }
        
        guard let first = firstPlayer else
        {
            return -1
        }
        return first
    }
}
//TODO: Figure out this enum stuff
//Raw values can't be a strucute?

    
enum Suit : Int
{
    case Clubs,
    Spades,
    Hearts,
    Diamonds

}
enum RankStr : Int
{
    case Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace,
    Two
}

enum cardPair : Int
{
    case single,
    pair,
    threeOfaKind,
    fourOfAKind
}
enum handMembers : Int
{
    case notMember,
    notEssentialMember,
    essentialMember
}
enum handTypeEnum : Int
{
    case single,
    pair,
    straight,
    pokerHand,
    flush,
    fullHouse,
    fourOfaKind,
    straightFlush
    
    enum PokerHandType : Int
    {
        case straight,
        flush,
        fullHouse,
        fourOfaKind,
        straightFlush
    }
}


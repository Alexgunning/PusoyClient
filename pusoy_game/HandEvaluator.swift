//
//  HandEvaluator.swift
//  pusoy2
//
//  Created by Alexander Gunning on 8/4/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import Foundation

typealias evalHand = (highCard : Card, handType : handTypeEnum, hand : [Card])?

class HandEvaluator
{
   
    
    static func isBetterHand(orig : [Card], new : [Card]) -> Bool
    {
        return true
    }
    
    static func compareRank13 (card1 : Card, card2: Card) -> Bool
    {
        return card1.m_Rank13 > card2.m_Rank13
    }
    static func compareRank13Low (card1 : Card, card2: Card) -> Bool
    {
        return card1.m_Rank13 < card2.m_Rank13
    }
    static func compareRank52 (card1 : Card, card2 : Card) -> Bool
    {
        return card1.m_Rank52 > card2.m_Rank52
    }
    static func compareRank52Low (card1 : Card, card2 : Card) -> Bool
    {
        return card1.m_Rank52 < card2.m_Rank52
    }
    static func compareRank52Alt (card1 : Card, card2 : Card) -> Bool
    {
        return card1.m_Rank52Alt > card2.m_Rank52Alt
    }
    static func compareRank52AltLow (card1 : Card, card2 : Card) -> Bool
    {
        return card1.m_Rank52Alt < card2.m_Rank52Alt
    }

    static func getCardFromHand(rank52 : Int, cardArray : [Card]) -> Card?
    {
        for card in cardArray
        {
            if rank52 == card.m_Rank52
            {
                return card
            }
        }
        return nil
    }
    static func getMaxCardOfRank(rank13 : Int, cardArray : [Card]) -> Card?
    {
        var rank13MatchArray = [Card]()
        var rank52High = 0
        for card in cardArray
        {
            if card.m_Rank13 == rank13
            {
                if card.m_Rank52 > rank52High
                {
                    rank52High = card.m_Rank52
                }
            }
        }
        return Card(rank52: rank52High)
    }
    /**
    return nil
    */
    static func threeOfAKindTest (hand : [Card]) -> evalHand
    {
        return nil
    }
    
/*    func isValidPokerHand (hand : [Card])
    {
        let evaluatedHand = hand.sort(HandEvaluator.compareRank52)
        
        
    }*/
    static func fullHouseFourOFaKindTest( hand: [Card]) -> evalHand
    {
        /**
        card counts is a map that stores the value of rank13 in the key 
        and the card count as the value
         */
        var cardCounts = [Int : Int]()
        //iterate through all of the cards for each card check if card rank13
        //is a key if in the map increment value count by one else add rank13
        // to map and set value to one
        for card in hand
        {
            //ALEX FIX MAKE SURE FOUR OF A KIND WORKS
            if let cardRank13 = cardCounts[card.m_Rank13]
            {
                cardCounts[card.m_Rank13]! += 1
                if cardCounts[card.m_Rank13]! == 4
                {
                    // if we know that there are four cards of the same type 
                    //the getCardFromHand will return the cards
                    return (HandEvaluator.getCardFromHand(rank52: Card(rank13: card.m_Rank13, suit: .Diamonds).m_Rank52, cardArray: hand)!, handTypeEnum.fourOfaKind, hand)
                }
            }
            else
            {
                cardCounts[card.m_Rank13] = 1
            }
        }
        //Check to see if the number of different cards is two
        if cardCounts.count == 2
        {
            for cardRank13 in cardCounts
            {
                //If this is the cardRank13 with three of the same values
                //return the highest card with the highest suit
                if cardRank13.1 == 3
                {
                    return (HandEvaluator.getMaxCardOfRank(rank13: cardRank13.0, cardArray: hand)!, handTypeEnum.fullHouse, hand)
                }
            }
        }
        return nil
    }
    
    static func flushTest(hand : [Card]) -> evalHand
    {
        let firstCardSuit = hand[0].m_Suit
        for i in 1..<4
        {
            if hand[i].m_Suit != firstCardSuit
            {
                return nil
            }
        }
        return (hand.min(by: compareRank13)!, handTypeEnum.flush, hand)
    }
    
    static func straightTest(hand : [Card]) -> evalHand
    {
        let evalHand = hand.sorted(by: compareRank13Low)
        var prevCardRank13 = evalHand[0].m_Rank13
        
        for i in 1..<5
        {
            //For the last four cards in the deck check to make sure 
            //that the rank 13 is one higher than the previous
            if hand[i].m_Rank13 - 1 != prevCardRank13
            {
                return nil
            }
            else
            {
                prevCardRank13 += 1
            }
        }
        return (evalHand.min(by: compareRank13)!, handTypeEnum.straight, hand)
    }
    
    static func straightFlushTest(hand : [Card]) -> evalHand
    {
        let straight = HandEvaluator.straightTest(hand: hand)
        let flush    = HandEvaluator.flushTest(hand: hand)
        if flush != nil && straight != nil
        {
            //We know that the hand array is not empty and will return an element
            return (hand.min(by: compareRank13)!, handTypeEnum.straightFlush, hand)
        }
        else if flush != nil
        {
            return flush
        }
        else if straight != nil
        {
            return straight
        }
        return nil
    }
    
    static func isValidHand(hand : [Card]) -> evalHand
    {
        switch hand.count
        {
            case 1:
                return (hand[0], handTypeEnum.single, hand)
            case 2:
                if hand[0].m_Rank13 == hand[1].m_Rank13
                {
                    //We know that we will get a max element because the size of the array
                    //Returns the max card of the three
                    return (hand.max(by: compareRank52)!, handTypeEnum.pair, hand)
                }
                else
                {
                    return nil
                }
       /*     case 3:
                if hand[0].m_Rank13 == hand[1].m_Rank13 && hand[0].m_Rank13 == hand[2].m_Rank13
                {
                    //We know that we will get a max element because the size of the array
                    //Returns the max card of the three
                    return (hand.maxElement(compareRank13)!, handTypeEnum.threeOfaKind)
                }
                else
                {
                    return nil
                }*/
            case 5:
                if let pokerHand = HandEvaluator.fullHouseFourOFaKindTest(hand: hand)
                {
                    return pokerHand
                }
                if let pokerHand = HandEvaluator.straightFlushTest(hand: hand)
                {
                    return pokerHand
                }
            default:
                return nil
        }
        return nil
    }/**
    Takes two hands
     
     -parameter hand1: [Card] New hand being played
     -parameter hand2: [Card] Orig hand being played
     
     -returns: Bool if hand1 is greater than hand2 return true if hand1 and hand2 are different size return false
     */
    static func compareHands( hand1Eval: evalHand, hand2Eval: evalHand) -> evalHand
    {
        // if hand2Eval is valid then compare hand 1 against it 
        // else check if the first hand is valid and return that
        if let hand1 = hand1Eval, let hand2 = hand2Eval
        {
                //ALEX FIX!!!!!
                //NOT SURE HOW NEXT LINE SHOULD BE
                 //       if hand1.handType != hand2.handType && hand2.handType.rawValue >= handTypeEnum.pokerhand.straight.rawValue
                if hand1.handType != hand2.handType && hand2.handType.rawValue < handTypeEnum.straight.rawValue
                {
                    return nil
                }
                if let hand1Comp = hand1Eval, let hand2Comp = hand2Eval
                {
                    if hand1Comp.handType.rawValue == hand2Comp.handType.rawValue
                    {
                        if compareRank52Alt(card1: hand1Comp.highCard, card2: hand2Comp.highCard)
                        {
                            return hand1Comp
                        }
                        else
                        {
                            return nil
                        }
                    }
                    else
                    {
                        if hand1Comp.handType.rawValue > hand2Comp.handType.rawValue
                        {
                            return hand1Comp
                        }
                        else
                        {
                            return nil
                        }
                    }
                }
        }
        else
        {
            //TODO check if works
            //logic should be that if
            //assertionFailure("Original hand should be valid")
            return hand1Eval
        }
        return nil
    }
    
    static func compareHands(hand1: [Card], hand2: [Card]) -> evalHand
    {
        let hand1Eval = HandEvaluator.isValidHand(hand: hand1)
        if let hand2Eval = HandEvaluator.isValidHand(hand: hand2)
        {
            return HandEvaluator.compareHands(hand1Eval: hand1Eval, hand2Eval: hand2Eval)
        }
        else
        {
            return HandEvaluator.compareHands(hand1Eval: hand1Eval, hand2Eval: nil)
        }
    }
}

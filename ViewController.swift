 //
//  ViewController.swift
//  pusoy_dos
//
//  Created by Alexander Gunning on 8/7/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


let TIMER_DURATION:Double = 5

let ON_COLOR = UIColor.green
let OFF_COLOR = UIColor.white
 

class ViewController: UIViewController {
    
    
   // let alert = UIAlertView(title: "Game Won", message: "Player x won game", delegate: nil, cancelButtonTitle: "Ok")
    var alert = UIAlertController()
  //  alert.delegate = self
    //alert.show()
    
    let ipAddress = "192.168.0.100:5000"
    var buttonArray = [cardUI]()
    //is it the users turn
    var curTurn = false
    //what number the
    var playerNumber :  Int?
    //number of current player
    var currentPlayer = -1
    {
        willSet
        {
            if newValue == playerNumber
            {
                curTurn = true
            }
            else
            {
                curTurn = false
            }
        }
            
    }
    var gameID : String?
    let playerID = arc4random_uniform(1000)
    
    //TODO: combine into one timer?
    var timerCheckGameStatus = Timer()
    var timeGetNetworkCards = Timer()
    var lastPlayedHand = [Card]()
    {
        willSet
        {
            if newValue.isEmpty
            {
                lastPlayedHandEval = nil
            }
            else
            {
                lastPlayedHandEval = HandEvaluator.isValidHand(hand: newValue)
            }
        }
    }
    //TODO: Set up property observer to set lastPlayedHandEval
    var lastPlayedHandEval : evalHand
    //Number of passes in a row
    var passCount = 0
    var passEligible = false
    var handToPlay = [Card]()
    var hand = [Card]()
    //var validHandToPlay = false
    var cardsFromNetworkReceived = false
    
    var firstHand = true
    
    let screenSize: CGRect  = UIScreen.main.bounds
    //print(screenSize.maxX)
    //print(screenSize.maxY)
    
    var handPassed : Bool = true
    
    
    var curPlayerLabel = UILabel()
    var playerNumLabel = UILabel()
    //var playerHand = String
    var lastPlayedHandLabel = UILabel()
    var passedLabel = UILabel()
    var playHandButton = UIButton()
    var passHandButton = UIButton()
    var gameWonLabel = UILabel()
    var gameIDLabel = UILabel()
    
    var gameStarted = false
    var gameFinished = false
    //

    override func viewDidLoad() {
        timeGetNetworkCards = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(ViewController.getNetworkCards), userInfo: nil, repeats: true)
        timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(ViewController.checkGameStatus), userInfo: nil, repeats: true)
      //  Interval(TIMER_DURATION, target: self, selector: #selector(ViewController.getNetworkCards), userInfo: nil, repeats: true)

       // timeGetNetworkCards = Timer.scheduledTimerWithTimeInterval(TIMER_DURATION, target: self, selector: #selector(ViewController.getNetworkCards), userInfo: nil, repeats: true)

       /* let screenSize: CGRect  = UIScreen.main.bounds
        print(screenSize.maxX)
        print(screenSize.maxY)*/
        
        let screenSize: CGRect  = UIScreen.main.bounds
        //print(screenSize.maxX)
        //print(screenSize.maxY)
        
        let xMult = screenSize.maxX/414
        let yMult = screenSize.maxY/736
        
        curPlayerLabel.frame = CGRect(x: 10*xMult, y: 70*yMult, width: 218*xMult, height: 30*yMult)
        playerNumLabel.frame = CGRect(x: 200*xMult, y: 70*yMult, width: 218*xMult, height: 30*yMult)
        lastPlayedHandLabel.frame = CGRect(x: 30*xMult, y: 35*yMult, width: 218*xMult, height: 30*yMult)
        passedLabel.frame = CGRect(x: 300*xMult, y: 35*yMult, width: 218*xMult, height: 30*yMult)
        playHandButton.frame = CGRect(x: 120*xMult, y: 400*yMult, width: 218*xMult, height: 30*yMult)
        passHandButton.frame = CGRect(x: 120*xMult, y: 450*yMult, width: 218*xMult, height: 30*yMult)
        gameWonLabel.frame = CGRect(x: 120*xMult, y: 50*yMult, width: 218*xMult, height: 30*yMult)
        gameIDLabel.frame = CGRect(x: 120*xMult, y: 500*yMult, width: 218*xMult, height: 30*yMult)
        
            //= UILabel(frame: var curPlayerLabel = UILabel(frame: CGRect(x: 30, y: 70, width: 218, height: 30)))
        
        
        lastPlayedHandLabel.text = "no hand yet"
        
        curPlayerLabel.textAlignment = .center
        playerNumLabel.textAlignment = .center
        lastPlayedHandLabel.textAlignment = .center
        gameWonLabel.textAlignment = .center
        gameIDLabel.textAlignment = .center
       
        playerNumLabel.text = "player not set"
        
        for i in 0..<13
        {
            let col = i/4
            let row = i%4
            let  button = UIButton(frame: CGRect(x: CGFloat((100*row+20))*xMult, y: CGFloat((60*col+100))*yMult, width: 70*xMult, height: 50*yMult))
            button.setTitle("\(i)",for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            //button.backgroundColor = UIColor.blackColor()
            buttonArray.append(cardUI(button: button))
            
        }
        for (i,buttonClass) in buttonArray.enumerated()
        {
            self.view.addSubview(buttonClass.button)
            buttonClass.button.tag = i
            buttonClass.button.addTarget(self, action: #selector(ViewController.buttonClicked),
                                         for: UIControlEvents.touchUpInside)
            buttonClass.button.isHidden = true
            
        }
        playHandButton.addTarget(self, action: #selector(ViewController.handButtonPressed), for: UIControlEvents.touchUpInside)
        passHandButton.addTarget(self, action: #selector(ViewController.passButtonPressed), for: UIControlEvents.touchUpInside)
        curPlayerLabel.text = "Game has not started yet"
        playHandButton.setTitle("Play Hand", for: .normal)
        passHandButton.setTitle("Pass Hand", for: .normal)
        playHandButton.backgroundColor = OFF_COLOR
        passHandButton.backgroundColor = OFF_COLOR
        //playHandButton.titleColor(for: .normal) = UIColor.black
        playHandButton.setTitleColor(UIColor.black, for: .normal)
        passHandButton.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(curPlayerLabel)
        self.view.addSubview(playerNumLabel)
        self.view.addSubview(lastPlayedHandLabel)
        self.view.addSubview(passedLabel)
        self.view.addSubview(playHandButton)
        self.view.addSubview(passHandButton)
        self.view.addSubview(gameWonLabel)
        self.view.addSubview(gameIDLabel)
        
        /*
        for i in 0..<13
        {
            hand.append(Card(rank52: i))
        }
        cardsFromNetworkReceived = true
         */
        /* //FOUR OF A KIND TEST
        hand.append(Card(rank13: 4, suit: .Clubs))
        hand.append(Card(rank13: 4, suit: .Diamonds))
        hand.append(Card(rank13: 4, suit: .Hearts))
        hand.append(Card(rank13: 4, suit: .Spades))
        hand.append(Card(rank13: 9, suit: .Clubs))
        HandEvaluator.isValidHand(hand: hand)
         */
        
         /*//FOUR OF A KIND TEST
         hand.append(Card(rank13: 4, suit: .Clubs))
         hand.append(Card(rank13: 4, suit: .Diamonds))
         hand.append(Card(rank13: 4, suit: .Hearts))
         hand.append(Card(rank13: 9, suit: .Spades))
         hand.append(Card(rank13: 9, suit: .Clubs))
         let x = HandEvaluator.isValidHand(hand: hand)
         var y = 1
         y = y+99
        print(y) 
         */
        updateGUI()
        timeGetNetworkCards.fire()
        
        /*
        for i in 0..<52
        {
            let myCard = Card(rank52: i)
            
            let rank52 = "\(myCard.m_Rank52)"
            let paddedRank52 = rank52.padding(toLength: 3, withPad: " ", startingAt: 0)
            
            let rank13 = "\(myCard.m_Rank13)"
            let paddedRank13 = rank13.padding(toLength: 3, withPad: " ", startingAt: 0)
            
            let rank52Alt = "\(myCard.m_Rank52Alt)"
            let paddedRank52Alt = rank52Alt.padding(toLength: 3, withPad: " ", startingAt: 0)
            
            let rankStr = "\(myCard.m_RankStr)"
            let paddedRankStr = rankStr.padding(toLength: 3, withPad: " ", startingAt: 0)
            
           // print("\(paddedRank52) \(paddedRank13) \(paddedRank52Alt) \(paddedRankStr) \(myCard.m_Suit)")
            
            print("rank52: \(paddedRank52) rank13: \(paddedRank13) rank52alt: \(paddedRank52Alt) rank13Str: \(paddedRankStr) suit: \(myCard.m_Suit)")
        }
        */
        //TestClass.handCompareTests()
    }
    
    func getNextPlayer() -> Int
    {
        var playNum = currentPlayer
        playNum += 1
        if playNum == 3
        {
            playNum = 0
        }
        return playNum
    }
    
    func getPrevPlayer() -> Int
    {
        var playNum = currentPlayer
        playNum -= 1
        if playNum == -1
        {
            playNum = 2
        }
        return playNum
    }
    
    func handButtonPressed()
    {
        if HandEvaluator.isValidHand(hand: handToPlay) != nil && curTurn
         {
            playHand()
        }
    }
    
    func passButtonPressed()
    {
        if passEligible && curTurn
        {
            passHand()
        }
    }
    /*
    func alertGameOver()
    {
        alert.title = "Game Won"
        alert.message = "Player \(currentPlayer) has won"
        self.present(alert, animated: true, completion: {})
    }
    */
    func buttonClicked(sender:UIButton)
    {
        //TODO remove outer if statement
        if cardsFromNetworkReceived && curTurn
        {
            let butNum = sender.tag
            buttonArray[butNum].state.toggle()
        
            //print("tag \(butNum)")
            //print("hand to play \(handToPlay)")
            //print("Full Hand \(hand)")
            switch buttonArray[butNum].state
            {
            case .On:
                handToPlay.append(hand[butNum])
                buttonArray[butNum].button.backgroundColor = ON_COLOR
                
            case .Off:
                var cardRemoved = false
                var i = 0
                while  i < handToPlay.count && !cardRemoved
                {
                   // AlEX FIX hack??
                    print("hand to play count\(handToPlay.count)")
                    print("i \(i)")
                    print("hand count \(hand.count)")
                    print("butNum \(butNum)")
                    if handToPlay[i].m_Rank52 == hand[butNum].m_Rank52
                    {
                        handToPlay.remove(at: i)
                        cardRemoved = true
                    }
                    i += 1
                }
                if !cardRemoved
                {
                    print("card not removed on button click!")
                    assert(true)
                }
                buttonArray[butNum].button.backgroundColor = OFF_COLOR
            }
            handToPlay = handToPlay.sorted(by: HandEvaluator.compareRank13Low)
            if HandEvaluator.isValidHand(hand: handToPlay) != nil
            {
                var validIfFirstHand = false
                if firstHand
                {
                    let sortedArray = hand.sorted(by: HandEvaluator.compareRank52AltLow)
                    let rank52AltLow = sortedArray[0]
                    for card in handToPlay
                    {
                        if card.m_Rank52 == rank52AltLow.m_Rank52
                        {
                            validIfFirstHand = true
                        }
                    }
                }
                else
                {
                    validIfFirstHand = true
                }
                if HandEvaluator.compareHands(hand1: handToPlay, hand2: lastPlayedHand) != nil && validIfFirstHand
                {
                    playHandButton.backgroundColor = ON_COLOR
                }
                else
                {
                    playHandButton.backgroundColor = OFF_COLOR
                }
            }
            else
            {
                playHandButton.backgroundColor = OFF_COLOR
            }
        }
    }
    
    func playHand()
    {
        //array of ints to pass to
        //let handRank52Vals = handToPlay.map({$0.m_Rank52})
        let handRank52Vals = handToPlay.map({String($0.m_Rank52)})
        var stringRep  = handRank52Vals.joined(separator: ",")
        stringRep.insert("[", at: stringRep.startIndex)
        stringRep.insert("]", at: stringRep.endIndex)
        let urlStr = "http://\(ipAddress)/playHand"
        //let parameters:[String: AnyObject] = ["cards":handRank52Vals,"gameID":gameID!,"playerID":Int(playerID)]
        //ALEX FIX?? Changed to as AnyObject in migration
        let parameters:[String: AnyObject] = ["cards":stringRep as AnyObject,"gameID":gameID! as AnyObject,"playerID":Int(playerID) as AnyObject]
        print(parameters)
        Alamofire.request(urlStr, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                let responseRequest = response.request
                let responseResponse = response.response
                let responseResult = response.result
                //print("Response Request: \(responseRequest)")  // original URL request
                //print("Response Response: \(responseResponse)") // URL response
                print("Response Result: \(responseResult)")     // server data
                if let jsonObject = responseResult.value{
                    
                    let json = JSON(jsonObject)
                    if let cardCount = json["cardCount"].int, let cardArray = json["cards"].array
                    {
                        //self.gameID = gameIDNum
                        print(cardCount)
                        var intArray = [Int]()
                        //TODO clean up grabbing of values
                        intArray = cardArray.map({$0.intValue})
                        intArray = intArray.sorted()
                        self.lastPlayedHand = self.handToPlay
                        self.hand.removeAll()
                        self.handToPlay.removeAll()
                        self.currentPlayer = self.getNextPlayer()
                        for i in 0..<intArray.count
                        {
                            self.hand.append(Card(rank52: intArray[i]))
                        }
                        self.handPassed = false
                        
                    }
                    if let gameWon = json["gameWon"].int
                    {
                        if gameWon == 1
                        {
                           self.gameFinished = true
                        }
                    }
                    self.timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(ViewController.checkGameStatus), userInfo: nil, repeats: true)
                    self.timerCheckGameStatus.fire()
                    self.updateGUI()
                }
        }
    }
    
    func passHand()
    {
        //array of ints to pass to
        //let handRank52Vals = handToPlay.map({$0.m_Rank52})
        let handRank52Vals = handToPlay.map({String($0.m_Rank52)})
        var stringRep  = handRank52Vals.joined(separator: ",")
        stringRep.insert("[", at: stringRep.startIndex)
        stringRep.insert("]", at: stringRep.endIndex)
        let urlStr = "http://\(ipAddress)/passHand"
       //var UrlEncoded = URLConvertible(
        //let parameters:[String: AnyObject] = ["cards":handRank52Vals,"gameID":gameID!,"playerID":Int(playerID)]
        let parameters:[String: AnyObject] = ["gameID":gameID! as AnyObject,"playerID":Int(playerID) as AnyObject]
        print(parameters)
        Alamofire.request(urlStr, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                let responseRequest = response.request
                let responseResponse = response.response
                let responseResult = response.result
                print("Response Request: \(responseRequest)")  // original URL request
                print("Response Response: \(responseResponse)") // URL response
                print("Response Result: \(responseResult)")     // server data
                // result of response serialization

                if let jsonObject = responseResult.value{
                    
                    let json = JSON(jsonObject)
                    print(json)
                    //ALEX FIX CLEAN UP
                    self.handPassed = true
                    self.passCount += 1
                    self.currentPlayer = self.getNextPlayer()
                    if self.passCount == 2
                    {
                        self.lastPlayedHand.removeAll()
                        self.passEligible = false
                        self.passCount = 0
                    }
                    self.timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(ViewController.checkGameStatus), userInfo: nil, repeats: true)
                    self.timerCheckGameStatus.fire()
                    self.updateGUI()
                }
        }
    }

    
    
    func getNetworkCards()
    {
        //Alamofire.request(.GET, "http://97.92.246.23/joinRandomGame/12")
        
        Alamofire.request("http://\(ipAddress)/joinRandomGame/\(playerID)")
            .responseJSON {  response in
                let responseRequest = response.request
                let responseResponse = response.response
                let responseResult = response.result
                //print("Response Request: \(responseRequest)")  // original URL request
                //print("Response Response: \(responseResponse)") // URL response
                print("Response Result: \(responseResult)")     // server data
                // result of response serialization
                
                if let jsonObject = responseResult.value{
                    
                    let json = JSON(jsonObject)
                    print(json)
                    
                    if let gameIDNum = json["game"].string
                    {
                        self.gameID = gameIDNum
                    }
                    if let cardArray = json["hand"].array //.array.map { $0.string! }
                    {
                        var intArray = cardArray.map({$0.intValue})
                        intArray = intArray.sorted()
                
                        self.hand = intArray.map({Card(rank52: $0)})
                
                    }
                    if let playerNum = json["playerNum"].int
                    {
                        self.playerNumber = playerNum
                        self.playerNumLabel.text = "player number: \(playerNum)"
                    }
                    //Stop timer that reapeats the Get Network Cards
                    self.timeGetNetworkCards.invalidate()
                    //Start check game status fire
                    self.timerCheckGameStatus.fire()
                    self.cardsFromNetworkReceived = true
                    self.handPassed = false
                    self.updateGUI()
                }
        }
    }
    
    func checkGameStatus()
    {
        if let gameIDNumber = gameID
        {
        Alamofire.request("http://\(ipAddress)/checkGameStatus/\(gameIDNumber)")
            .responseJSON { response in
                let responseRequest = response.request
                let responseResponse = response.response
                let responseResult = response.result
               // print("Response Request: \(responseRequest)")  // original URL request
               // print("Response Response: \(responseResponse)") // URL response
                print("Response Result: \(responseResult)")     // server data
                // result of response serialization
                
                if let jsonObject = responseResult.value{
                    
                    let json = JSON(jsonObject)
                    print(json)
                    
                    if let curPlayer = json["curPlayer"].int, let gameFull = json["gameFull"].int, let lastPlayed = json["lastPlayedHand"].array,
                        let gameWon = json["gameWon"].int
                    {
                        if gameWon == 1
                        {
                            self.gameFinished = true
                        }
                        //check if the current player is different than before and make sure game is full
                        else if self.currentPlayer != curPlayer && gameFull == 1
                        {
                            self.currentPlayer = curPlayer
                            
                            if lastPlayed.isEmpty
                            {
                                
                                if self.gameStarted
                                {
                                    self.passCount += 1
                                    self.passEligible = true
                                    self.handPassed = true
                                    self.firstHand = false

                                }
                                else
                                {
                                    self.passCount = 0
                                }
                                if self.passCount == 2
                                {
                                    //self.passHandButton.backgroundColor = UIColor.orange
                                    self.lastPlayedHand.removeAll()
                                    self.passEligible = false
                                    self.passCount = 0
                                }
                                else if !self.gameStarted
                                {
                                    self.passEligible = false
                                    self.gameStarted = true
                                    if self.currentPlayer != self.playerNumber
                                    {
                                        self.firstHand = false
                                    }
                                }
                            }
                            else
                            {
                            
                                self.firstHand = false
                                self.handPassed = false
                                self.passEligible = true
                                self.lastPlayedHand.removeAll()
                                for card in lastPlayed
                                {
                                    self.lastPlayedHand.append(Card(rank52: card.intValue))
                                }
                                
                                self.passCount = 0
                            }
                            self.curTurn = self.currentPlayer == self.playerNumber
                            if self.curTurn
                            {
                                self.timerCheckGameStatus.invalidate()
                            }
                           // self.lastPlayedHand = lastPlayed
                            //self.updateGUI()
                        }
                    self.updateGUI()
                    }
                }
            }
        }
    }
    
    func updateGUI()
    {
        if gameFinished
        {
            gameWonLabel.text = "Player \(currentPlayer) has won!"
            curPlayerLabel.text = ""
            playerNumLabel.text = ""
            lastPlayedHandLabel.text = ""
            passedLabel.text = ""
        }
        if let gameIDStr = gameID
        {
            gameIDLabel.text = gameIDStr
        }
        curPlayerLabel.text = "Player \(self.currentPlayer)'s turn"
        if let num = self.playerNumber
        {
            playerNumLabel.text = "Player Num: \(num)"
        }
        else
        {
            playerNumLabel.text = "# not assigned"
        }
        if lastPlayedHand.isEmpty
        {
            lastPlayedHandLabel.text = "play any hand"
        }
        else
        {
            var lastHandStr = ""
            for card in self.lastPlayedHand
            {
                lastHandStr.append("\(card.m_RankStr)\(card.unicodeStr)")
            }
            self.lastPlayedHandLabel.text = lastHandStr
        }
        if passEligible && curTurn
        {
            passHandButton.backgroundColor = ON_COLOR
        }
        else
        {
            passHandButton.backgroundColor = OFF_COLOR
        }
        if handPassed
        {
           passedLabel.text = "P:\(getPrevPlayer()) passed"
        }
        else
        {
            passedLabel.text  = ""
        }
        playHandButton.backgroundColor = OFF_COLOR
        for (i,buttons) in buttonArray.enumerated()
        {
            if i < hand.count
            {
                let thisCard = hand[i]
                let myString = "\(thisCard.m_RankStr) \(thisCard.unicodeStr)"
                buttons.button.setTitle(myString, for: .normal)
                buttons.state = .Off
                buttons.button.isHidden = false
            }
            else
            {
               buttons.button.isHidden = true
               //buttons.button.setTitle("\(i)", for: .normal)
            }
        }
        if curTurn
        {
            curPlayerLabel.backgroundColor = ON_COLOR
        }
        else
        {
            curPlayerLabel.backgroundColor = OFF_COLOR
        }
    }

}


class cardUI
{
    var button : UIButton
    var state : cardState
    {
        willSet
        {
            switch newValue
            {
            case .On:
                button.backgroundColor = ON_COLOR
            case .Off:
                button.backgroundColor = OFF_COLOR
            }
        }
    }
    var text : String?
    
    init(button: UIButton)
    {
        self.state = .Off
        self.button = button
    }
}
 
enum cardState{
    case On
    case Off
    
    mutating func toggle()
    {
        switch self {
        case .On:
            self = .Off
        case .Off:
            self = .On
        }
    }
    
}

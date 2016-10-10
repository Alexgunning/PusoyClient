//
//  GameScene.swift
//  pusoy_game
//
//  Created by Alexander Gunning on 10/1/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import SpriteKit
import Alamofire
import SwiftyJSON


let startingWidth:CGFloat = 0.16
let handPlayedWidth:CGFloat = 0.4
let widthDiff:CGFloat = 0.055
let startingHeight:CGFloat = 0.1
let pressedHeight:CGFloat =  0.15

let PLAYED_HAND_RESIZE:CGFloat = 0.6

let TIMER_DURATION:Double = 5

let ipAddress = "192.168.0.109:5000"

let tableGreen = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.5)
let buttonWhite = UIColor.white
let buttonYellow = UIColor(red: 1, green: 1, blue: 0.2, alpha: 1)

class GameScene: SKScene {
    
    //var uiHand = [cardSprite]()
    var uiHandsPlayed = [SKSpriteNode]()

    
    var playButton = SKShapeNode()
    var passButton = SKShapeNode()
    
    var playButtonLabel = SKLabelNode()
    var passButtonLabel = SKLabelNode()
    
    var playerLeftLabel = SKLabelNode()
    var playerRightLabel = SKLabelNode()
    var playerLabel = SKLabelNode()
   
    var playerPassLabel = SKLabelNode()
    var playerLeftPassLabel = SKLabelNode()
    var playerRightPassLabel = SKLabelNode()
    
    let playerID = arc4random_uniform(1000)
    var gameID : String?
    var playerNumber :  Int?
    
    var timerCheckGameStatus = Timer()
    var timeGetNetworkCards = Timer()
    
    var hand = [Card]()
    var gameFinished = false
    var gameStarted = false
    var passCount = 0
    var passEligible = false
    var handPassed = true
    var firstHand = true
    var curTurn = false

    var handValid = false
    
    var handToPlayDirty = false
    
    var lastPlayedID = 0
    
    var playerLastPlayedHand = [Card]()
    var handToBeat = [Card]()
    
    var networkPlayerLeft : Player?
    var networkPlayerRight : Player?
    
    var humanPlayer : HumanPlayer?
    
    var playerDict =  [Int:Player]()
    var currentPlayer = -1
    {
        willSet {
            curTurn = newValue == playerNumber
        }
    }
    
    var playerPassed = false
/*
    struct handTransaction
    {
        playerID : Int
        ini
    }
 */
    
    override func didMove(to view: SKView)
    {
        timeGetNetworkCards = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(GameScene.getNetworkCards), userInfo: nil, repeats: true)
        //ALEX Fix change back
        timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(GameScene.getGameStatus), userInfo: nil, repeats: true)
        
        playButton.path = UIBezierPath(roundedRect: CGRect(x: -size.width * 0.45, y: -size.height * 0.22, width: size.width * 0.37, height: size.height * 0.1), cornerRadius: 10).cgPath
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        playButton.fillColor = buttonWhite
        playButton.strokeColor = UIColor.black
        playButton.lineWidth = 1
        playButton.name  = "playButton"
        addChild(playButton)

        passButton.path = UIBezierPath(roundedRect: CGRect(x: size.width * 0.090, y: -size.height * 0.22, width: size.width * 0.37, height: size.height * 0.1), cornerRadius: 10).cgPath
        passButton.position = CGPoint(x: frame.midX, y: frame.midY)
        passButton.fillColor = buttonWhite
        passButton.strokeColor = UIColor.black
        passButton.lineWidth = 1
        passButton.name = "passButton"
        addChild(passButton)
    
        passButtonLabel.text = "Pass Hand";
        passButtonLabel.name = "passButton"
        passButtonLabel.fontName = "AlNile-Bold"
        passButtonLabel.fontSize = 26;
        passButtonLabel.fontColor = SKColor.black
        passButtonLabel.position = CGPoint(x: size.width * 0.28, y: -size.height * 0.19)
        
        playButtonLabel.text = "Play Hand"
        playButtonLabel.name = "playButton"
        playButtonLabel.fontName = "AlNile-Bold"
        playButtonLabel.fontSize = 26;
        playButtonLabel.fontColor = SKColor.black
        playButtonLabel.position = CGPoint(x: -size.width * 0.272, y: -size.height * 0.19)
        
        
        playerLeftLabel.text = "Player Left"
        playerLeftLabel.name = "playButton"
        playerLeftLabel.fontName = "AlNile-Bold"
        playerLeftLabel.fontSize = 26;
        playerLeftLabel.fontColor = SKColor.black
        playerLeftLabel.position = CGPoint(x: size.width * 0.25, y: size.height * 0.90)
        
        playerRightLabel.text = "Player Right"
        playerRightLabel.name = "playButton"
        playerRightLabel.fontName = "AlNile-Bold"
        playerRightLabel.fontSize = 26;
        playerRightLabel.fontColor = SKColor.black
        playerRightLabel.position = CGPoint(x: size.width * 0.75, y: size.height * 0.90)
        
        playerLabel.text = "Alex"
        playerLabel.name = "playButton"
        playerLabel.fontName = "AlNile-Bold"
        playerLabel.fontSize = 26;
        playerLabel.fontColor = SKColor.black
        playerLabel.position = CGPoint(x: size.width * 0.50, y: size.height * 0.55)
        
        
        playerPassLabel.text = ""
        playerPassLabel.name = "playerPassLabel"
        playerPassLabel.fontName = "AlNile-Bold"
        playerPassLabel.fontSize = 26;
        playerPassLabel.fontColor = SKColor.black
        playerPassLabel.position = CGPoint(x: size.width * 0.50, y: size.height * 0.48)
        
    
        playerLeftPassLabel.text = ""
        playerLeftPassLabel.name = "playerLeftPassLabel"
        playerLeftPassLabel.fontName = "AlNile-Bold"
        playerLeftPassLabel.fontSize = 26;
        playerLeftPassLabel.fontColor = SKColor.black
        playerLeftPassLabel.position = CGPoint(x: size.width * 0.30, y: size.height * 0.78)
        
        playerRightPassLabel.text = ""
        playerRightPassLabel.name = "playerRightPassLabel"
        playerRightPassLabel.fontName = "AlNile-Bold"
        playerRightPassLabel.fontSize = 26;
        playerRightPassLabel.fontColor = SKColor.black
        playerRightPassLabel.position = CGPoint(x: size.width * 0.70, y: size.height * 0.78)
        
        
        addChild(playerPassLabel)
        addChild(playerLeftPassLabel)
        addChild(playerRightPassLabel)
        addChild(playerLeftLabel)
        addChild(playerRightLabel)
        addChild(playerLabel)
        
        passButton.addChild(passButtonLabel)
        playButton.addChild(playButtonLabel)
        
        
        backgroundColor = tableGreen
        
        //TEST STUFF START
        /*
        for i in 0..<13
        {
            var myCard = Card(rank52: Int(arc4random_uniform(52)))
            hand.append(myCard)
            myCard.sprite.zPosition = CGFloat(i)
            addChild(myCard.sprite)
        }
        
        playerNumber = 0
        self.networkPlayerLeft = networkPlayer(playerNum: 2, playerLabel: "Left Player")
        self.playerDict[2] = self.networkPlayerLeft
        self.networkPlayerRight = networkPlayer(playerNum: 1, playerLabel: "Right Player")
        self.playerDict[1] = self.networkPlayerRight
        
        currentPlayer = 2
        curTurn = false
        */
        //TEST STUFF STOP
        
        updateUI()
        getNetworkCards()
        
    }
    
    func getNetworkCards()
    {
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
                    
                    if let gameIDNum = json["game"].string, let cardArray = json["hand"].array, let playerNum = json["playerNum"].int
                    {
                        self.gameID = gameIDNum
                        

                        var intArray = cardArray.map({$0.intValue})
                        intArray = intArray.sorted()
                        
                        
                        var hand = intArray.map({Card(rank52: $0)})
                        hand = hand.sorted(by: HandEvaluator.compareRank52AltLow)
                        for (i,card) in hand.enumerated()
                        {
                            card.sprite.zPosition = CGFloat(i)
                            self.addChild(card.sprite)
                        }
                        
                        self.playerNumber = playerNum
                        
                        self.humanPlayer = HumanPlayer(playerNum: playerNum, playerLabel: "Human Player", hand: hand)
                        self.playerDict[playerNum] = self.humanPlayer
                        self.humanPlayer?.m_Hand = hand
                        switch playerNum
                        {
                        case 0:
                            self.networkPlayerLeft = Player(playerNum: 2, playerLabel: "Left Player")
                            self.playerDict[2] = self.networkPlayerLeft
                            self.networkPlayerRight = Player(playerNum: 1, playerLabel: "Right Player")
                            self.playerDict[1] = self.networkPlayerRight
                        case 1:
                            self.networkPlayerLeft = Player(playerNum: 0, playerLabel: "Left Player")
                            self.playerDict[0] = self.networkPlayerLeft
                            self.networkPlayerRight = Player(playerNum: 2, playerLabel: "Right Player")
                            self.playerDict[2] = self.networkPlayerRight
                        case 2:
                            self.networkPlayerLeft = Player(playerNum: 1, playerLabel: "Left Player")
                            self.playerDict[1] = self.networkPlayerLeft
                            self.networkPlayerRight = Player(playerNum: 0, playerLabel: "Right Player")
                            self.playerDict[0] = self.networkPlayerRight
                        default:
                            assert(true)
                        }

                        
                        }
                    
                    //Stop timer that reapeats the Get Network Cards
                    self.timeGetNetworkCards.invalidate()
                    //Start check game status fire
                    self.timerCheckGameStatus.fire()
                    //self.cardsFromNetworkReceived = true
                    self.handPassed = false
                    self.updateUI()
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
                                if !self.gameStarted
                                {
                                    self.currentPlayer = curPlayer
                                }
                                //alex fix should be previous player??
                               // getPrevPlayer()
                                if var cPlayer = self.playerDict[self.getPrevPlayer(curPlayer: curPlayer)]
                                {
                                    var spritesToRemove = [SKSpriteNode]()
                                    for card in cPlayer.handPlayed
                                    {
                                        spritesToRemove.append(card.sprite)
                                    }
                                    self.removeChildren(in: spritesToRemove)
                                    cPlayer.handPlayed.removeAll()
                                    
                                    self.currentPlayer = curPlayer
                                    
                                    cPlayer.m_DirtyHand = true
                                    
                                    if lastPlayed.isEmpty
                                    {
                                        
                                        if self.gameStarted
                                        {
                                            self.passCount += 1
                                            self.passEligible = true
                                            self.handPassed = true
                                            self.firstHand = false
                                            cPlayer.showPassesdLabel = true
                                            
                                        }
                                        else
                                        {
                                            self.passCount = 0
                                        }
                                        if self.passCount == 2
                                        {
                                            self.handToBeat.removeAll()
                                            self.passEligible = false
                                            self.passCount = 0
                                            self.networkPlayerLeft?.showPassesdLabel = false
                                            self.networkPlayerRight?.showPassesdLabel = false
                                            self.networkPlayerLeft?.m_DirtyHand = true
                                            self.networkPlayerRight?.m_DirtyHand = true
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
                                       // cPlayer.showPassesdLabel =
                                        self.firstHand = false
                                        self.handPassed = false
                                        self.passEligible = true
                                        self.handToBeat.removeAll()
                                        for card in lastPlayed
                                        {
                                            cPlayer.handPlayed.append(Card(rank52: card.intValue))
                                        }
                                        self.handToBeat = cPlayer.handPlayed
                                        self.passCount = 0
                                    }
                                    self.curTurn = self.currentPlayer == self.playerNumber
                                    if self.curTurn
                                    {
                                        self.playerPassed = false
                                        //self.handPassed = false
                                        self.removeChildren(in: self.uiHandsPlayed)
                                        self.uiHandsPlayed.removeAll()
                                        self.timerCheckGameStatus.invalidate()
                                    }
                                    // self.lastPlayedHand = lastPlayed
                                    //self.updateGUI()
                                }
                                self.updateUI()
                            }
                        }
                    }
            }
        }
    }
    
    func getGameStatus()
    {
        if let gameIDNumber = gameID
        {
            Alamofire.request("http://\(ipAddress)/getGameStatus/\(gameIDNumber)/\(lastPlayedID)")
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
                        
                        if let playerIDs = json["playerIDs"].array, let cardCounts = json["cardCounts"].array, let turnIDs = json["turnIDs"].array,
                            let returnHands = json["returnHands"].array
                        {
                            //Alex fix make sure size is same for all
                            for i in 0..<playerIDs.count
                            {
                                let playerID = playerIDs[i].intValue
                                let cardCount = cardCounts[i].intValue
                                let turnID = turnIDs[i].intValue
                                let playedHand = returnHands[i].arrayValue
                                let handToPlay = playedHand.map({Card(rank52: $0.intValue )})
                                self.processTurn(playerID: playerID, turnID: turnID, cardCount: cardCount, hand: handToPlay)
                            }
                        }
                        
                        if let curPlayer = json["curPlayer"].int
                        {
                            self.currentPlayer = curPlayer
                            //Alex Fix call everytime
                            self.updateUI()
                        }
                         
               }
            }
        }
    }
    
    func processTurn(playerID: Int, turnID: Int, cardCount: Int, hand: [Card])
    {
        if let player = playerDict[playerID]
        {
            lastPlayedID = turnID
            currentPlayer = getNextPlayer(curPlayer: playerID)
            player.handPlayed.removeAll()
            player.m_DirtyHand = true
            if hand.isEmpty
            {
                passCount += 1
                if passCount == 2
                {
                    passEligible = false
                    handToBeat.removeAll()
                }
                else
                {
                    passEligible = true
                }
                
            }
            else
            {
                player.handPlayed = hand
                passEligible = true
                passCount = 0
            }
        }
        updateUI()
    }
    
    
    func playHand(handToPlay:[Card])
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
                    
                    self.processTurn(playerID: (self.humanPlayer?.m_PlayerNum)!, turnID: self.lastPlayedID+1, cardCount: handToPlay.count, hand: handToPlay)
                    
                   /* if let cardCount = json["cardCount"].int, let cardArray = json["cards"].array
                    {
                        //self.gameID = gameIDNum
                        print(cardCount)
                        var intArray = [Int]()
                        //TODO clean up grabbing of values
                        intArray = cardArray.map({$0.intValue})
                        intArray = intArray.sorted()
                        //self.lastPlayedHand = self.handToPlay
                        self.hand.removeAll()
                        //self.handToPlay.removeAll()
                        self.currentPlayer = self.getNextPlayer()
                        self.curTurn = false
                        for i in 0..<intArray.count
                        {
                            self.hand.append(Card(rank52: intArray[i]))
                        }
                        self.handPassed = false
                        self.playerPassed = false
                        
                    }
                    if let gameWon = json["gameWon"].int
                    {
                        if gameWon == 1
                        {
                            self.gameFinished = true
                        }
                    }
                    self.timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(GameScene.checkGameStatus), userInfo: nil, repeats: true)
                    self.timerCheckGameStatus.fire()
                    self.updateUI()
 */
                }
        }
    }
    
    func passHand()
    {
        //array of ints to pass to
        //let handRank52Vals = handToPlay.map({$0.m_Rank52})
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
                    var emptyHand = [Card]()
                    let json = JSON(jsonObject)
                    
                    self.processTurn(playerID: (self.humanPlayer?.m_PlayerNum)!, turnID: self.lastPlayedID+1, cardCount: 0, hand: emptyHand)
                 /*   print(json)
                    //ALEX FIX CLEAN UP
                    self.handPassed = true
                    self.curTurn = false
                    self.passCount += 1
                    self.currentPlayer = self.getNextPlayer()
                    self.playerPassed = true
                    if self.passCount == 2
                    {
                        //ALEX FIX last played hand stuff?
                        //self.lastPlayedHand.removeAll()
                        var spritesToRemove = [SKSpriteNode]()
                        for card in self.networkPlayerLeft!.handPlayed
                        {
                            spritesToRemove.append(card.sprite)
                        }
                        for card in self.networkPlayerRight!.handPlayed
                        {
                            spritesToRemove.append(card.sprite)
                        }
                        self.removeChildren(in: spritesToRemove)

                        self.passEligible = false
                        self.passCount = 0
                        self.handToBeat.removeAll()
                        self.networkPlayerLeft?.handPlayed.removeAll()
                        self.networkPlayerRight?.handPlayed.removeAll()
                        self.networkPlayerLeft?.showPassesdLabel = false
                        self.networkPlayerRight?.showPassesdLabel = false
                        self.networkPlayerLeft?.m_DirtyHand = true
                        self.networkPlayerRight?.m_DirtyHand = true
                    }
                    self.timerCheckGameStatus = Timer.scheduledTimer(timeInterval: TIMER_DURATION, target: self, selector: #selector(GameScene.checkGameStatus), userInfo: nil, repeats: true)
                    self.timerCheckGameStatus.fire()
                    self.updateUI()
                */
                }
        }
    }
    
    func convertToString(_ i:Int)->String
    {
        print(i)
        var returnVal = "ERROR"
        switch i
        {
    
        case 0...8:
            returnVal = "\(i+2)"
        case 9:
            returnVal = "J"
        case 10:
            returnVal = "Q"
        case 11:
            returnVal = "K"
        case 12:
            returnVal = "A"
        default:
            returnVal = "ERROR"
        }
        print(returnVal)
        return returnVal
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
       
        if let touch:UITouch = touches.first
        {
            //touches.anyObject()! as! UITouch
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
           
            if let name = touchedNode.name
            {
                if let cardNum = Int(name), let human = humanPlayer
                    {
                        if curTurn
                        {
                            print(name)
                            let widthPos = startingWidth+(widthDiff*CGFloat(cardNum))
                            //touchedNode.userData?.setValue(Int(1), forKey: "state")
                            human.m_Hand = human.m_Hand.sorted(by: HandEvaluator.compareRank52AltLow)
                            human.m_Hand[cardNum].state.toggle()
                            var posY:CGFloat = 0.1
                            if human.m_Hand[cardNum].state == .On
                            {
                                posY = pressedHeight
                            }
                            
                            touchedNode.position = CGPoint(x: size.width * widthPos, y: size.height * CGFloat(posY))
                            var handToPlay = [Card]()
                            for playCards in human.m_Hand
                            {
                                if playCards.state == .On
                                {
                                    handToPlay.append(playCards)
                                }
                            }
                            print("Hand to play")
                            printHand(hand: handToPlay)
                            print("Hand to beat")
                            printHand(hand: handToBeat)
                            if HandEvaluator.compareHands(hand1: handToPlay, hand2: handToBeat) != nil
                            {
                                handValid = true
                                playButton.fillColor = buttonYellow
                            }
                            else
                            {
                                handValid = false
                                playButton.fillColor = buttonWhite
                            }
                        }
                }
                else if name == "playButton"
                {
                    if handValid  && curTurn
                    {
                        handValid = false
                        removeChildren(in: uiHandsPlayed)
                        uiHandsPlayed.removeAll()
                        var handToPlay = [Card]()
                        var indexesToRemove = [Int]()
                        var spritesToRemove = [SKSpriteNode]()
                        print("play button")
                        for (i,card) in humanPlayer!.m_Hand.enumerated()
                        {
                            if card.state == .On
                            {
                                uiHandsPlayed.append(card.sprite)
                                handToPlay.append(card)
                                //addChild(card.sprite!)
                                indexesToRemove.append(i)
                                spritesToRemove.append(card.sprite)
                            }
                            
                        }
                        removeChildren(in: spritesToRemove)
                        for i in spritesToRemove
                        {
                            addChild(i)
                        }
                        indexesToRemove = indexesToRemove.sorted(by: { $0 > $1 })
                        
                        for i in indexesToRemove
                        {
                            humanPlayer!.m_Hand.remove(at: i)
                        }
                        
                        //!!!!!!!!
                        //ALEX FIX COMMENTED OUT FOR DEBUG!!!!!!!!!
                        //!!!!!!!!
                        playHand(handToPlay: handToPlay)
                        
                        updateUI()
                    }
                }
                else if name == "passButton"
                {
                    if passEligible && curTurn
                    {
                        removeChildren(in: uiHandsPlayed)
                        uiHandsPlayed.removeAll()
                        for var card in hand
                        {
                            card.state = .Off
                        }
                        //removeChildren(in: uiHandsPlayed)
                        //uiHandsPlayed.removeAll()
                        passHand()
                        
                        print("pass button")
                    }
                }
                
            }
            
        }
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
    
    func getNextPlayer(curPlayer:Int) -> Int
    {
        var playNum = curPlayer
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
    
    func getPrevPlayer(curPlayer:Int) -> Int
    {
        var playNum = curPlayer
        playNum -= 1
        if playNum == -1
        {
            playNum = 2
        }
        return playNum
    }

    func updateNetworkPlayerUI(netPlayer : Player, xPos : CGFloat)
    {
        for (i,cards) in netPlayer.handPlayed.enumerated()
        {
            cards.sprite.name = nil
            let widthPos = handPlayedWidth+(widthDiff*CGFloat(i))
            cards.sprite.position = CGPoint(x: size.width * (xPos + ( CGFloat(i) * 0.03)), y: size.height * 0.78)
            cards.sprite.scale(to: CGSize(width: 100*PLAYED_HAND_RESIZE, height: 145*PLAYED_HAND_RESIZE))
            addChild(cards.sprite)
        }
    }

    func updateUI()
    {
        if let human = humanPlayer
        {
            for (i,cards) in human.m_Hand.enumerated()
            {
                let widthPos = startingWidth+(widthDiff*CGFloat(i))
                var heightPos = startingHeight
                if cards.state == .On
                {
                    heightPos = pressedHeight
                }
                cards.sprite.position = CGPoint(x: size.width * widthPos, y: size.height * heightPos)
                cards.sprite.name = "\(i)"
            }
        }
        if playerPassed
        {
            playerPassLabel.text = "Passed"
        }
        else
        {
            for (i,cards) in uiHandsPlayed.enumerated()
            {
                cards.name = nil
                let widthPos = handPlayedWidth+(widthDiff*CGFloat(i))
                cards.position = CGPoint(x: size.width * widthPos, y: size.height * 0.48)
                cards.scale(to: CGSize(width: 100*PLAYED_HAND_RESIZE, height: 145*PLAYED_HAND_RESIZE))
            }
            playerPassLabel.text = ""
        }
        if let playerL = networkPlayerLeft, let playerR = networkPlayerRight
        {
            if playerL.m_DirtyHand
            {
                if playerL.showPassesdLabel
                {
                    playerLeftPassLabel.text = "Passed"
                }
                else
                {
                    updateNetworkPlayerUI(netPlayer: playerL, xPos: 0.3)
                    playerLeftPassLabel.text = ""
                }
                playerL.m_DirtyHand = false
            }
            if playerR.m_DirtyHand
            {
                if playerR.showPassesdLabel
                {
                    playerRightPassLabel.text = "Passed"
                }
                else
                {
                    updateNetworkPlayerUI(netPlayer: playerR, xPos: 0.7)
                    playerRightPassLabel.text = ""
                }
                playerR.m_DirtyHand = false
            }
        }
        
        passButton.fillColor = buttonWhite
        playButton.fillColor = buttonWhite
        if curTurn
        {
            playerLabel.fontColor = UIColor.yellow
            if passEligible
            {
                passButton.fillColor = buttonYellow
            }
        }
        else
        {
            playerLabel.fontColor = UIColor.black
            
        }
        if networkPlayerRight?.m_PlayerNum == currentPlayer
        {
            playerRightLabel.fontColor = UIColor.yellow
        }
        else
        {
            playerRightLabel.fontColor = UIColor.black
        }
        if networkPlayerLeft?.m_PlayerNum == currentPlayer
        {
            playerLeftLabel.fontColor = UIColor.yellow
        }
        else
        {
            playerLeftLabel.fontColor = UIColor.black
        }

    }
    
    func printHand(hand : [Card])
    {
        for card in hand
        {
            print("\(card.m_RankStr)\(card.unicodeStr)")
        }
    }
    
}

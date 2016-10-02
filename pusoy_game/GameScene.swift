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

class cardSprite
{
    var sprite: SKSpriteNode?
    var cardState: State
    init(sprite:SKSpriteNode)
    {
        self.sprite = sprite
        self.cardState = .off
    }
}

enum State{
    case on
    case off
    
    mutating func toggle()
    {
        switch self {
        case .on:
            self = .off
        case .off:
            self = .on
        }
    }
    
}

let startingWidth:CGFloat = 0.16
let handPlayedWidth:CGFloat = 0.4
let widthDiff:CGFloat = 0.055
let startingHeight:CGFloat = 0.1
let pressedHeight:CGFloat =  0.2


let ipAddress = "192.168.0.109:5000"



class GameScene: SKScene {
    
    var uiHand = [cardSprite]()
    var uiHandsPlayed = [SKSpriteNode]()
    
    let tableGreen = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 0.5)
    let buttonWhite = UIColor.white
    let buttonYellow = UIColor(red: 1, green: 1, blue: 0.2, alpha: 1)
    
    var playButton = SKShapeNode()
    var passButton = SKShapeNode()
    
    var playButtonLabel = SKLabelNode()
    var passButtonLabel = SKLabelNode()
    
    let playerID = arc4random_uniform(1000)
    var gameID : String?
    
    var hand = [Card]()
    
    override func didMove(to view: SKView)
    {
        
        playButton.path = UIBezierPath(roundedRect: CGRect(x: -size.width * 0.45, y: -size.height * 0.16, width: size.width * 0.37, height: size.height * 0.1), cornerRadius: 10).cgPath
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        playButton.fillColor = buttonYellow
        playButton.strokeColor = UIColor.black
        playButton.lineWidth = 1
        playButton.name  = "playButton"
        addChild(playButton)
        
        passButton.path = UIBezierPath(roundedRect: CGRect(x: size.width * 0.090, y: -size.height * 0.16, width: size.width * 0.37, height: size.height * 0.1), cornerRadius: 10).cgPath
        passButton.position = CGPoint(x: frame.midX, y: frame.midY)
        passButton.fillColor = buttonYellow
        passButton.strokeColor = UIColor.black
        passButton.lineWidth = 1
        passButton.name = "passButton"
        addChild(passButton)
    
        passButtonLabel.text = "Pass Hand";
        passButtonLabel.name = "passButton"
        passButtonLabel.fontName = "AlNile-Bold"
        passButtonLabel.fontSize = 26;
        passButtonLabel.fontColor = SKColor.black
        passButtonLabel.position = CGPoint(x: size.width * 0.28, y: -size.height * 0.13)
        
        playButtonLabel.text = "Play Hand"
        playButtonLabel.name = "playButton"
        playButtonLabel.fontName = "AlNile-Bold"
        playButtonLabel.fontSize = 26;
        playButtonLabel.fontColor = SKColor.black
        playButtonLabel.position = CGPoint(x: -size.width * 0.272, y: -size.height * 0.13)
        
        passButton.addChild(passButtonLabel)
        playButton.addChild(playButtonLabel)
        
        
        backgroundColor = tableGreen

        for i in 0..<13
        {
            let numStr = convertToString(i)
            let card = cardSprite(sprite: SKSpriteNode(imageNamed: "cards100px/\(numStr)S.png"))
            card.sprite?.zPosition = CGFloat(i)
            card.sprite?.name = "\(i)"
            uiHand.append(card)
            addChild(card.sprite!)
        }
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
                    
                    if let gameIDNum = json["game"].string
                    {
                        self.gameID = gameIDNum
                    }
                    if let cardArray = json["hand"].array //.array.map { $0.string! }
                    {
                        var intArray = cardArray.map({$0.intValue})
                        intArray = intArray.sorted()
                        
                        //self.hand = intArray.map({Card(rank52: $0)})
                        
                    }
                    if let playerNum = json["playerNum"].int
                    {
                        //self.playerNumber = playerNum
                        //self.playerNumLabel.text = "player number: \(playerNum)"
                    }
                    //Stop timer that reapeats the Get Network Cards
                    //self.timeGetNetworkCards.invalidate()
                    //Start check game status fire
                    //self.timerCheckGameStatus.fire()
                    //self.cardsFromNetworkReceived = true
                    //self.handPassed = false
                    //self.updateGUI()
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch:UITouch = touches.first
        {
            //touches.anyObject()! as! UITouch
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)
           
            if let name = touchedNode.name
            {
                if let cardNum = Int(name)
                    {let widthPos = startingWidth+(widthDiff*CGFloat(cardNum))
                    //touchedNode.userData?.setValue(Int(1), forKey: "state")
                    
                    uiHand[cardNum].cardState.toggle()
                    var posY:CGFloat = 0.1
                    if uiHand[cardNum].cardState == .on
                    {
                        posY = 0.2
                    }
                    
                    touchedNode.position = CGPoint(x: size.width * widthPos, y: size.height * CGFloat(posY))
                }
                else if name == "playButton"
                {
                    removeChildren(in: uiHandsPlayed)
                    uiHandsPlayed.removeAll()
                    
                    var indexesToRemove = [Int]()
                    var spritesToRemove = [SKSpriteNode]()
                    print("play button")
                    for (i,card) in uiHand.enumerated()
                    {
                        if card.cardState == .on
                        {
                            uiHandsPlayed.append(card.sprite!)
                            //addChild(card.sprite!)
                            indexesToRemove.append(i)
                            spritesToRemove.append(card.sprite!)
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
                        uiHand.remove(at: i)
                    }
                    
                    print(indexesToRemove)

                    
                    
                    updateUI()
                }
                else if name == "passButton"
                {
                    removeChildren(in: uiHandsPlayed)
                    uiHandsPlayed.removeAll()
                    
                    
                    print("pass button")
                }
                
            }
            //touchedNode.
            
        }
    }
    

    func updateUI()
    {
        for (i,cards) in uiHand.enumerated()
        {
            let widthPos = startingWidth+(widthDiff*CGFloat(i))
            var heightPos = startingHeight
            if cards.cardState == .on
            {
                heightPos = pressedHeight
            }
            cards.sprite?.position = CGPoint(x: size.width * widthPos, y: size.height * heightPos)
            cards.sprite?.name = "\(i)"
        }
        for (i,cards) in uiHandsPlayed.enumerated()
        {
            let widthPos = handPlayedWidth+(widthDiff*CGFloat(i))
            cards.position = CGPoint(x: size.width * widthPos, y: size.height * 0.55)
            cards.scale(to: CGSize(width: 100*0.8, height: 145*0.8))
        }

    }
}

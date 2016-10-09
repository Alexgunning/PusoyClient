//
//  ComputerePlayer.swift
//  pusoy_game
//
//  Created by Alexander Gunning on 10/2/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import Foundation
import SpriteKit

class Player
{
    let m_PlayerNum : Int
    let m_PlayerLabel : String
    var m_HandCount : Int
    var m_handPlayed : Bool
    var handPlayed = [Card]()
    
    var m_DirtyHand : Bool
    
    var handNode : SKSpriteNode
  
    var showPassesdLabel = false
    
    init(playerNum: Int, playerLabel: String)
    {
        self.m_PlayerNum = playerNum
        self.m_PlayerLabel = playerLabel
        self.m_HandCount = 13
        self.m_handPlayed = false
        self.m_DirtyHand = false
        self.handNode = SKSpriteNode()
        self.handNode.position = CGPoint(x: 0, y: 0)
    }
}

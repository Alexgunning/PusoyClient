//
//  HumanPlayer.swift
//  pusoy_game
//
//  Created by Alexander Gunning on 10/9/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import Foundation

class HumanPlayer : Player
{
    
    var m_Hand:[Card]
    
    init(playerNum: Int, playerLabel: String, hand:[Card])
    {
        self.m_Hand = hand
        super.init(playerNum: playerNum, playerLabel: playerLabel)
    }
}

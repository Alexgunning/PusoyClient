//
//  GameViewController.swift
//  pusoy_game
//
//  Created by Alexander Gunning on 10/1/16.
//  Copyright © 2016 Alexander Gunning. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}

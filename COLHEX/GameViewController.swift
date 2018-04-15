//
//  GameViewController.swift
//  COLHEX
//
//  Created by Alessandro Profenna on 2017-04-01.
//  Copyright © 2017 Alessandro Profenna. All rights reserved.
//

import UIKit
import SpriteKit

/**
 Used to present and switch between each SKScene in the game
 */
class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView
        let scene = MainMenuScene(size: skView.bounds.size)
        
        //skView.showsFPS = true
        //skView.showsPhysics = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = false
        skView.isMultipleTouchEnabled = true
        scene.scaleMode = .resizeFill
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        skView.presentScene(scene)
 
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}

//
//  GameViewController.swift
//  ZombieConga
//  Class: CS 430
//  Created by Jeffrey Trotz on 1/14/19.
//  Copyright © 2019 Jeffrey Trotz. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Set size of the scene
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        
        // Show frames per second and node count
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // Add child nodes to the scene in any order
        skView.ignoresSiblingOrder = true
        
        // Scale scene to required size and make it visible
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
    }
    
    // Hides the status bar
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}

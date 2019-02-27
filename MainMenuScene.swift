//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Jeffery Trotz on 2/4/19.
//  Class: CS 430
//
//  **********************************
//  Created for chapter 4 challenge #1
//  **********************************
//
//  Copyright © 2019 Jeffrey Trotz. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene
{
    override func didMove(to view: SKView)
    {
        // Variable to store the background
        var background: SKSpriteNode
        
        // Set background position and add it to the scene
        background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: (size.width / 2), y: (size.height / 2))
        self.addChild(background)
    }
    
    // Calls sceneTapped() function when the screen is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        sceneTapped()
    }
    
    // Transitions the user to the game when they touch the screen
    func sceneTapped()
    {
        // Create scene
        let scene = GameScene(size: self.size)
        scene.scaleMode = self.scaleMode
        
        // Set transition type/duration and present the scene
        let transition = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(scene, transition: transition)
    }
}

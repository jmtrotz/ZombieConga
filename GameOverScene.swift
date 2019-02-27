//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Jeffery Trotz on 2/4/19.
//  Class: CS 430
//  Copyright © 2019 Jeffrey Trotz. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    // Stores if the player won (true) or lost (false)
    let won: Bool
    
    // Initialize the scene
    init(size: CGSize, won: Bool)
    {
        self.won = won
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView)
    {
        // Variable to store the background
        var background: SKSpriteNode
        
        // Sets the "you win" background if the player wins
        if (won)
        {
            background = SKSpriteNode(imageNamed: "YouWin")
            run(SKAction.playSoundFileNamed("win.wav", waitForCompletion: false))
        }
        
        // Sets the "you lose" background if the player loses
        else
        {
            background = SKSpriteNode(imageNamed: "YouLose")
            run(SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false))
        }
        
        // Set background position and add it to the scene
        background.position = CGPoint(x: (size.width / 2), y: (size.height / 2))
        self.addChild(background)
        
        // Create action to transition back to the main screen after 3 seconds
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run
        {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(myScene, transition: reveal)
        }
        
        // Run transition
        self.run(SKAction.sequence([wait, block]))
    }
}

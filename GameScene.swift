//
//  GameScene.swift
//  ZombieConga
//  Created by Jeffrey Trotz on 1/14/19.
//  Class: CS 430
//  Copyright © 2019 Jeffrey Trotz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    // Set zombie image
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    // Properties to hold time intervals
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    // Stores the size of the playable area
    let playableRect: CGRect
    
    // Optional property for chapter 2 challenge #2
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    // Property to animate the zombie walking
    let zombieAnimation: SKAction
    
    // Property for chapter 3 challenge #2 to track if the zombie is invincible or not
    var invincible = false
    
    // Tracks cat move points per second (chapter 3 challenge #3)
    let catMovePointsPerSec: CGFloat = 480.0
    
    // Variables to store number of lives and if the game is over or not
    var lives = 5
    var gameOver = false
    
    // Sound effects
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    // SK camera so the background will scroll
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    // Label to show how many lives the user has left
    let livesLabel = SKLabelNode(fontNamed: "Glimstick")
    
    // Label to show how many cats are in the conga line
    let catsLabel = SKLabelNode(fontNamed: "Glimstick")
    
    // Calculates the current visible playable area
    var cameraRect : CGRect
    {
        let x = cameraNode.position.x - size.width/2 + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2 + (size.height - playableRect.height)/2
        return CGRect(x: x, y: y, width: playableRect.width, height: playableRect.height)
    }
    
    // Initialize the playable area
    override init(size: CGSize)
    {
        // Calculate the playable area
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y:playableMargin, width: size.width, height: playableHeight)
        
        // Array to anmation frames
        var textures:[SKTexture] = []
        
        // Load the array
        for i in 1...4
        {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        
        // Add frames 3 & 2 to the list
        textures.append(textures[2])
        textures.append(textures[1])
        
        // Assign the animation property to the array
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the scene
    override func didMove(to view: SKView)
    {
        // Creates an endlessly scrolling background
        for i in 0...1
        {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        // Set zombie position and scale
        zombie.position = CGPoint(x: 400, y: 400)
        
        // Set z position to 100 to make it appear on top of other sprites (chapter 3 challenge #3)
        zombie.zPosition = 100
        
        // Add zombie to the scene
        addChild(zombie)
        
        // Spawn a never ending stream of enemys
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in self?.spawnEnemy() }, SKAction.wait(forDuration: 2.0)])))
        
        // Spawns cats
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run() { [weak self] in self?.spawnCat() }, SKAction.wait(forDuration: 1.0)])))
        
        // Start background music
        playBackgroundMusic(filename: "backgroundMusic.mp3")
        
        // Add camera and set its position
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Set propeties for the lives label shown in the bottom left and add it to the scene
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .bottom
        livesLabel.position = CGPoint(x: -playableRect.size.width / 2 + CGFloat(20), y: -playableRect.size.height / 2 + CGFloat(20))
        cameraNode.addChild(livesLabel)
        
        // Set propeties for the cats count label shown in the bottom right and add it to the scene
        catsLabel.text = "Cats: X"
        catsLabel.fontColor = SKColor.black
        catsLabel.fontSize = 100
        catsLabel.zPosition = 150
        catsLabel.horizontalAlignmentMode = .right
        catsLabel.verticalAlignmentMode = .bottom
        catsLabel.position = CGPoint(x: playableRect.size.width / 2 - CGFloat(20), y: -playableRect.size.height / 2 + CGFloat(20))
        cameraNode.addChild(catsLabel)
    }
    
    // Updates the scene
    override func update(_ currentTime: TimeInterval)
    {
        // Calculate change in time
        if lastUpdateTime > 0
        {
            deltaTime = currentTime - lastUpdateTime
        }
            
        else
        {
            deltaTime = 0
        }
        
        lastUpdateTime = currentTime
        
        move(sprite: zombie, velocity: velocity)
        rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        
        // Make sure the zombie is still within the playable area
        boundsCheckZombie()
        
        // Move the conga line and the camera
        moveTrain()
        moveCamera()
        
        // Update the user's remaining lives
        livesLabel.text = "Lives: \(lives)"
        
        // Set gameOver to true and stop music
        if lives <= 0 && !gameOver
        {
            gameOver = true
            print ("You lose! Loooooooser!!!!")
            backgroundMusicPlayer.stop()
            
            // Create new scene
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            
            // Create transition object
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            // Call method to show the new scene
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    // Calls functions to check if there's been any collisions
    // between the zombie and the enemy or cats
    override func didEvaluateActions()
    {
        checkCollisions()
    }
    
    // Get location where the touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    // Get location where touches are moving
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch = touches.first else
        {
            return
        }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    // Calls function to calculate velocity when the scene is touched
    func sceneTouched(touchLocation:CGPoint)
    {
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
    // Moves the zombie
    func move(sprite: SKSpriteNode, velocity: CGPoint)
    {
        let amountToMove = velocity * CGFloat(deltaTime)
        sprite.position += amountToMove
    }
    
    // Calculates velocity for the zombie's movement
    func moveZombieToward(location: CGPoint)
    {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    // Rotates the zombie
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat)
    {
        // Find distance between current angleand target angle
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        
        // Calculate amount to rotate the frame
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(deltaTime), abs(shortest))
        
        // Rotate the zombie
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    // Makes sure the zombie stays within the scene
    func boundsCheckZombie()
    {
        let bottomLeft = CGPoint(x: cameraRect.minX, y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
        
        // All if statements below flip the zombie around and send it back in
        // the opposite direction if it reaches the limit of the playable area
        if zombie.position.x <= bottomLeft.x
        {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
        }
        
        if zombie.position.x >= topRight.x
        {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y
        {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y
        {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    // Creates an enemey in the vertical center of
    // the screen just out of view to the right
    func spawnEnemy()
    {
        // Create enemy
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        
        // Updated for chapter 5 challenge to fix ememies that stop spawning
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width / 2, y: CGFloat.random(
            min: cameraRect.minY + enemy.size.height / 2,
            max: cameraRect.maxY - enemy.size.height / 2))
        enemy.zPosition = 50
        addChild(enemy)
        
        // Create actions to move the enemy across the screen and remove it when it's done
        // Updated for chapter 5 challenge to fix enemies that stop spawning
        let actionMove = SKAction.moveTo(x: -enemy.size.width / 2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        
        // Add actions to the sequence and run it
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    // Spawns cats
    func spawnCat()
    {
        // Create cat
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX),
                               y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY))
        cat.zPosition = 50
        cat.setScale(0)
        addChild(cat)
        
        // Action to make the cat appear
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        // Actions to make the cat wiggle
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π / 8, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        
        // Actions to make the cat scale up/down
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        
        // Add wiggle/scale together into one action
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        
        // Actions to remove the cat
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        
        // Add actions to array
        let actions = [appear, groupWait, disappear, removeFromParent]
        
        // Run the sequence
        cat.run(SKAction.sequence(actions))
        
    }
    
    // Animates the zombie walking
    func startZombieAnimation()
    {
        // When the animation starts it tags the it with the key "animation"
        if zombie.action(forKey: "animation") == nil
        {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    // Stops zombie walking animation
    func stopZombieAnimation()
    {
        // When the animation stops it removes the tag "animation"
        zombie.removeAction(forKey: "animation")
    }
    
    // Removes a cat and plays a sound when it gets hit by the zombie
    func zombieHit(cat: SKSpriteNode)
    {
        // Rename the cat and stop all current actions (chapter 3 challenge #3)
        cat.name = "train"
        cat.removeAllActions()
        
        // Change the scale and set rotation to 0 (chapter 3 challenge #3)
        cat.setScale(1.0)
        cat.zRotation = 0
        //cat.removeFromParent()
        
        // Turn the cat green for .2 seconds (chapter 3 challenge #3)
        let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        cat.run(turnGreen)
        run(catCollisionSound)
    }
    
    // Removes the enemy and plays a sound when it hits the zombie
    func zombieHit(enemy: SKSpriteNode)
    {
        // Make the zombie invincible (chapter 3 challenge #2)
        invincible = true
        
        // Code provided by the book for chapter 3 challenge #2
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration)
        {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        
        // Not sure what this is for (yes, I peeked at the code...)(chapter 3 challenge #2)???
        let setHidden = SKAction.run()
        {
            [weak self] in
            self?.zombie.isHidden = false
            self?.invincible = false
        }
        
        // Run the actions above
        zombie.run(SKAction.sequence([blinkAction, setHidden]))
        //enemy.removeFromParent() // Don't remove the enemy as outlined in chapter 3 challenge #2
        run(enemyCollisionSound)
        
        // Remove cats from the conga line and take away a life
        loseCats()
        lives -= 1
    }
    
    // Checks if the zombie has run into any cats/enemies
    func checkCollisions()
    {
        // Array to store the hit cats
        var hitCats: [SKSpriteNode] = []
        
        // Enumerates through any child of the scene with the name "cat"
        enumerateChildNodes(withName: "cat")
        {
            node, _ in
            let cat = node as! SKSpriteNode
            
            // If the zombie hits a cat, add it to the array
            if cat.frame.intersects(self.zombie.frame)
            {
                hitCats.append(cat)
            }
        }
        
        // Loops through the array and removes the cats from the scene
        for cat in hitCats
        {
            zombieHit(cat: cat)
        }
        
        // If the zombie is invincible, then simply return and don't do anything else
        if invincible
        {
            return
        }
        
        // Array to store the hit enemies
        var hitEnemies: [SKSpriteNode] = []
        
        // Enumerates through any child of the scene with the name "enemy"
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            
            // If the zombie hits an enemy, add it to the array
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame)
            {
                hitEnemies.append(enemy)
            }
        }
        
        // Loops through the array and removes the enemy from the scene
        for enemy in hitEnemies
        {
            zombieHit(enemy: enemy)
        }
    }
    
    // Moves cats towards the position of the previous cat (code
    // provided by the book for chapter 3 challenge #3
    func moveTrain()
    {
        // Track number of cats in the train
        var trainCount = 0
        
        // Keeps the train behind the zombie
        var targetPosition = zombie.position
        
        enumerateChildNodes(withName: "train")
        {
            node, stop in
            trainCount += 1
            
            if !node.hasActions()
            {
                let actionDuration = 0.3
                let offset = targetPosition - node.position // a
                let direction = offset.normalized() // b
                let amountToMovePerSec = direction * self.catMovePointsPerSec // c
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration) // d
                let moveAction = SKAction.moveBy(x: amountToMove.x, y: amountToMove.y, duration: actionDuration) // e
                node.run(moveAction)
            }
            
            targetPosition = node.position
        }
        
        // If they manage to get over 15 cats in the conga line
        // and the game isn't over already, then they win
        if trainCount >= 15 && !gameOver
        {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            // Create new scene
            let gameOverScene = GameOverScene(size: size, won: true)
            
            // Create transition object
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            // Call method to show the new scene
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        // Update the label that shows the number of cats in the conga line
        catsLabel.text = "Cats: \(trainCount)"
    }
    
    // Remvoes cats from the conga line
    func loseCats()
    {
        // Keeps track of the number of cats remvoed from the conga line
        var loseCount = 0
        enumerateChildNodes(withName: "train")
        {
            node, stop in
            // Find random offset from the cat's current position
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            // Actions to move the cat towards the random spot while it spins
            // and scales down along the way
            node.name = ""
            node.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotate(byAngle: (π * 4), duration: 1.0),
                        SKAction.move(to: randomSpot, duration: 1.0),
                        SKAction.scale(to: 0, duration: 1.0)
                        ]),
                    SKAction.removeFromParent()
                    ]))
            
            // Update number of cats removed from the conga line
            loseCount += 1
            
            // Tell SpriteKit to stip enumerating the conga line once we've removed 2 cats
            if loseCount >= 2
            {
                stop[0] = true
            }
        }
    }
    
    // Combines two backgrounds to make one large image so the scene can scroll
    func backgroundNode() -> SKSpriteNode
    {
        // Create node to store both backgrounds
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        // Load background image #1 and pin it to the bottom left
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        // Load background image #2 and pin it next to background #1
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        // Set background node to the size of both images
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                                     height: background1.size.height)
        
        // Return the new background
        return backgroundNode
    }
    
    // Moves the camera
    func moveCamera()
    {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(deltaTime)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background")
        {
            node, _ in
            let background = node as! SKSpriteNode
            
            if (background.position.x + background.size.width) < self.cameraRect.origin.x
            {
                background.position = CGPoint(x: background.position.x + (background.size.width * 2),
                                              y: background.position.y)
            }
        }
    }
    
    // Draws a rectangle around the playable area so we can see it
    func debugDrawPlayableArea()
    {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}

//
//  HomeScene.swift
//  Flappy Demo
//
//  Created by Mia Noyola on 4/24/24.
//

import Foundation
import SpriteKit

class HomeScene: SKScene{
    override func didMove(to view: SKView){
        let backgroundColor = SKSpriteNode(imageNamed: "mountains")
        backgroundColor.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundColor.zPosition = -1  // Ensure it stays in the background
        let scale =  frame.size.height/backgroundColor.size.height
        //backgroundColor.scale(to: frame.size) // Scale the image to fit the frame
        backgroundColor.setScale(scale)
        addChild(backgroundColor)
        
        let titleLabel = SKLabelNode(fontNamed: "Courier-Bold")
        titleLabel.text = "Flappy Falcon"
        titleLabel.fontSize = 60
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        addChild(titleLabel)
        
        
        let startGameLabel = SKLabelNode(fontNamed: "Courier")
        startGameLabel.text = "Tap Flappy Falcon to Take Flight"
        startGameLabel.fontSize = 25
        startGameLabel.fontColor = .white
        startGameLabel.position = CGPoint(x: frame.midX, y: frame.midY - 300)
        addChild(startGameLabel)
        
        // Create the bouncing action
//        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
//        let moveDown = moveUp.reversed()
//        let bounce = SKAction.sequence([moveUp, moveDown])
//        let repeatBounce = SKAction.repeatForever(bounce)

        // Run the action
        //startGameLabel.run(repeatBounce)
        
        let bigFalcon = SKSpriteNode(imageNamed: "Falcon 1")
        bigFalcon.name = "falcon"
        bigFalcon.position = CGPoint(x: frame.midX, y: frame.midY)
        bigFalcon.size = CGSize(width: size.width * 0.5, height: size.width * 0.6)
        bigFalcon.zPosition = 2
        addChild(bigFalcon)
        
        // Create the bouncing action
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
        let moveDown = moveUp.reversed()
        let bounce = SKAction.sequence([moveUp, moveDown])
        let repeatBounce = SKAction.repeatForever(bounce)

        // Run the action
        bigFalcon.run(repeatBounce)
        
        addClouds()
        
        
    }
    
    func createCloud() -> SKSpriteNode{
        //let cloud = SKSpriteNode(imageNamed: "cloud1")
        let cloudImages = ["cloud1", "cloud2", "cloud3", "cloud4"]
        let randomIndex = Int(arc4random_uniform(UInt32(cloudImages.count)))
        let cloud = SKSpriteNode(imageNamed: cloudImages[randomIndex])
        cloud.size = CGSize(width: size.width * 0.5, height: size.width * 0.6)
        // putting it to the far right of the screen ... tbadjusted for positiong on both the right and left side of the screen
//        cloud.position = CGPoint(x: size.width + cloud.size.width / 2, y: CGFloat.random(in: 0...size.height))
        
        // randomly decide if the cloud starts from the left or right
        let startsFromRight = Bool.random()
        let startPositionX = startsFromRight ? size.width + cloud.size.width / 2 : -cloud.size.width / 2
        let moveDirectionMultiplier: CGFloat = startsFromRight ? -1 : 1  // Determines direction of movement
        
        cloud.position = CGPoint(x: startPositionX, y: CGFloat.random(in: 100...size.height - 100))
        //cloud.position = CGPoint(x: size.width + cloud.size.width / 2, y: CGFloat.random(in: 100...size.height-100))
        cloud.zPosition = 25
        cloud.alpha = 1 // start invisisble or offscreen
        cloud.name = "cloud"
        return cloud
    }
    
    func addClouds(){
        for _ in 0..<50{ // 30 clouds, hopefully covers the whole screen
            let cloud = createCloud()
            addChild(cloud)
        }
    }
    
    func animateClouds(completion: @escaping () -> Void){
        let duration = 3.0 // duration for clouds to cover the screen
        children.forEach{ node in
            if let cloud = node as? SKSpriteNode, cloud.name == "cloud" {
                // generate a random x endpoint within the screen bounds
                let randomX = CGFloat.random(in: 0...size.width)
                let endPosition = CGPoint( x: randomX, y: cloud.position.y)
                let moveAction = SKAction.move(to: endPosition, duration: duration)
                cloud.run(moveAction)
                print("the clouds are moving!")
            }
            
        }
        
        run(SKAction.wait(forDuration: duration), completion:completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "falcon" {
                    // start cloud animation and then transition
                    animateClouds {
                        self.transitionToGameScene()
                    }
                }
            }
        }
    }
        
    private func transitionToGameScene() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
}

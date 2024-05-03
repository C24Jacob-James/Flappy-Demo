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
        let cloud = SKSpriteNode(imageNamed: "cloud1")
        cloud.position = CGPoint(x: cloud.size.width, y: CGFloat.random(in: 0...size.height))
        cloud.zPosition = 25
        cloud.alpha = 1 // start invisisble or offscreen
        print("the cloud was made")
        cloud.name = "cloud1"
        
        return cloud
    }
    
    func addClouds(){
        for _ in 0..<5{ // 5 clouds
            let cloud = createCloud()
            addChild(cloud)
            print("the cloud was added")
        }
    }
    
    func animateClouds(completion: @escaping () -> Void){
        let duration = 2.5 // duration for clouds to cover the screen
        children.forEach{ node in
            if let cloud = node as? SKSpriteNode, cloud.name == "cloud1" {
                let endPosition = CGPoint( x: -cloud.size.width, y: cloud.position.y)
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

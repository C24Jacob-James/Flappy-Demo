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
        //backgroundColor = .white // Or any appropriate background color
        let backgroundColor = SKSpriteNode(imageNamed: "mountains")
        backgroundColor.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundColor.zPosition = -1  // Ensure it stays in the background
        backgroundColor.scale(to: frame.size) // Scale the image to fit the frame
        addChild(backgroundColor)
        
        let titleLabel = SKLabelNode(fontNamed: "Arial")
        titleLabel.text = "Welcome to the Game"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(titleLabel)
        
        
        let startGameLabel = SKLabelNode(fontNamed: "Arial")
        startGameLabel.text = "Tap to Start Game"
        startGameLabel.fontSize = 30
        startGameLabel.fontColor = .blue
        startGameLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(startGameLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node is SKLabelNode {
                    transitionToGameScene()
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

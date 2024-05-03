//
// GameScene.swift
// Flappy Falcon
//
// Name: Jacob M. James & Angelica M. Noyola
// Assignment: Final Project - Flappy Falcon

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var score = 0
    
    override func didMove(to view: SKView){
//        //backgroundColor = .white // Or any appropriate background color
//        let backgroundColor = SKSpriteNode(imageNamed: "mountains")
//        backgroundColor.position = CGPoint(x: frame.midX, y: frame.midY)
//        backgroundColor.zPosition = -1  // Ensure it stays in the background
//        let scale =  frame.size.height/backgroundColor.size.height
//        //backgroundColor.scale(to: frame.size) // Scale the image to fit the frame
//        backgroundColor.setScale(scale)
//        addChild(backgroundColor)
        
//        let titleLabel = SKLabelNode(fontNamed: "Courier-Bold")
//        titleLabel.text = "Flappy Falcon"
//        titleLabel.fontSize = 60
//        titleLabel.fontColor = .black
//        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 300)
//        addChild(titleLabel)
//        
//        
//        let startGameLabel = SKLabelNode(fontNamed: "Courier")
//        startGameLabel.text = "Tap Flappy Falcon to Start"
//        startGameLabel.fontSize = 30
//        startGameLabel.fontColor = .white
//        startGameLabel.position = CGPoint(x: frame.midX, y: frame.midY - 300)
//        addChild(startGameLabel)
//
//        
//        let bigFalcon = SKSpriteNode(imageNamed: "Falcon 1")
//        bigFalcon.name = "falcon"
//        bigFalcon.position = CGPoint(x: frame.midX, y: frame.midY)
//        bigFalcon.size = CGSize(width: size.width * 0.5, height: size.width * 0.6)
//        bigFalcon.zPosition = 2
//        addChild(bigFalcon)
//        
//        // Create the bouncing action
//        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.5)
//        let moveDown = moveUp.reversed()
//        let bounce = SKAction.sequence([moveUp, moveDown])
//        let repeatBounce = SKAction.repeatForever(bounce)
//
//        // Run the action
//        bigFalcon.run(repeatBounce)
        
        
        let gameOverWindow = SKSpriteNode(color:. white, size: CGSize(width: 300, height: 200))
        gameOverWindow.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverWindow.zPosition = 10
        addChild(gameOverWindow)
        
        // Score Display
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 0, y: 10)
        gameOverWindow.addChild(scoreLabel)

        // New Game Button
        let newGameButton = SKLabelNode(fontNamed: "Courier")
        newGameButton.name = "newGame"
        newGameButton.text = "New Game"
        newGameButton.fontSize = 18
        newGameButton.fontColor = .blue
        newGameButton.position = CGPoint(x: -50, y: -40)
        gameOverWindow.addChild(newGameButton)
        
        // Return Home Button
        let returnHomeButton = SKLabelNode(fontNamed: "Courier")
        returnHomeButton.name = "returnHome"
        returnHomeButton.text = "Return to Home"
        returnHomeButton.fontSize = 18
        returnHomeButton.fontColor = .blue
        returnHomeButton.position = CGPoint(x: 50, y: -40)
        gameOverWindow.addChild(returnHomeButton)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            let location = touch?.location(in: self)
            let node = self.atPoint(location!)
//            for node in nodes {
//                if node.name == "falcon" {
//                    transitionToGameScene()
//                }
//            }
            if node.name == "newGame"{
                transitionToGameScene()
            } else if node.name == "returnHome"{
                transitionToHomeScene()
            }
        
    }
        
    private func transitionToGameScene() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    private func transitionToHomeScene() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let homeScene = HomeScene(size: self.size)  // Assuming you have a HomeScene class
        self.view?.presentScene(homeScene, transition: transition)
    }
}


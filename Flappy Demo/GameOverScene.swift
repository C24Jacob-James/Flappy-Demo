import Foundation
import SpriteKit

class GameOverScene: SKScene {
    override func didMove(to view: SKView){
        //backgroundColor = .white // Or any appropriate background color
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
        startGameLabel.text = "Tap Flappy Falcon to Start"
        startGameLabel.fontSize = 30
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
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "falcon" {
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


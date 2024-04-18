import Foundation
import SpriteKit

class GameOverScene: SKScene {
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let message1 = "LOSER >_<"
        let message2 = "Touch the screen to play again!"
        
        let label1 = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label1.text = message1
        label1.fontSize = 40
        label1.fontColor = SKColor.black
        label1.position = CGPoint(x: size.width / 2, y: size.height / 2 + 20) // Adjust Y position for first line
        addChild(label1)
        
        let label2 = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label2.text = message2
        label2.fontSize = 20
        label2.fontColor = SKColor.black
        label2.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20) // Adjust Y position for second line
        addChild(label2)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
    }
}

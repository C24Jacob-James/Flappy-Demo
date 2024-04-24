/* Name: Jacob M. James & Angelica M. Noyola
* Assignment: Final Project - Flappy Falcon
* Documentation Stmt:
 
    We used Chat GPT to make it so that GameOverScene does not go away until the user touches the screen: https://chat.openai.com/share/38f4bf91-c46e-4436-9947-f9ac5238e7bd
 
    Used Chat GPT to generate the loading screen - blue sky gradient:
 
    
*/


import UIKit
import SpriteKit


class LoadingScene: SKScene {
    override func didMove(to view: SKView) {
        let backgroundColor = SKSpriteNode(imageNamed: "loadingScreen")
        //backgroundColor = .white // Or any appropriate background color
        backgroundColor.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundColor.zPosition = -1  // Ensure it stays in the background
        backgroundColor.scale(to: frame.size) // Scale the image to fit the frame
        addChild(backgroundColor)
        
        let falconSprite = SKSpriteNode(imageNamed: "falcon")
        falconSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        falconSprite.size = CGSize(width: size.width * 0.3, height: size.width * 0.4)

        // Define the flight path
        let flightPath = UIBezierPath()
        flightPath.move(to: CGPoint(x: frame.minX, y: frame.midY))
        flightPath.addCurve(to: CGPoint(x: frame.maxX, y: frame.midY), controlPoint1: CGPoint(x: frame.midX/2, y: frame.minY), controlPoint2: CGPoint(x: frame.midX*1.5, y: frame.maxY))

        // Falcon follows the path
        let followPath = SKAction.follow(flightPath.cgPath, asOffset: false, orientToPath: false, speed: 200)
        falconSprite.run(SKAction.repeatForever(followPath))

        addChild(falconSprite)
    }
}

class GameViewController: UIViewController {
    
    var isLoading = true // here to manage loading status
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
   // let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
  //  scene.scaleMode = .resizeFill
  //  skView.presentScene(scene)
      
      // Present the appropriate scene based on loading state
              if isLoading {
                  presentLoadingScene(skView)
              } else {
                  presentGameScene(skView)
              }
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
    private func presentLoadingScene(_ skView: SKView) {
        let loadingScene = LoadingScene(size: view.bounds.size)
        loadingScene.scaleMode = .resizeFill
        skView.presentScene(loadingScene)
        
        // Simulate loading process
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Adjust time as needed
            self.isLoading = false
            self.presentGameScene(skView)
        }
    }
    
    private func presentGameScene(_ skView: SKView) {
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
}

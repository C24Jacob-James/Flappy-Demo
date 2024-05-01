/* Name: Jacob M. James & Angelica M. Noyola
* Assignment: Final Project - Flappy Falcon
* Documentation Stmt:
 
    We used Chat GPT to make it so that GameOverScene does not go away until the user touches the screen: https://chat.openai.com/share/38f4bf91-c46e-4436-9947-f9ac5238e7bd
 
    Used Chat GPT to generate the loading screen - blue sky gradient, and helped me set up and organize my loading screen. Including the code to make the falcon fly across the screen: https://chat.openai.com/share/6c073900-b947-46f9-9960-c9cc824e16e0
 
    Chat GPT helped me fix the home screen background image, before it was really really squished together and it was difficult adjusting it to fit normally on the screen, chat chpt gave me the formual to adjust the size of the image by adjusting the scale of the home screen image. https://chat.openai.com/share/1c43a61e-260d-420f-a1c0-4647dd582b92
 
    Chat GPT helped me adjust the fonts of the homescreen, as well as helped me figure out how to make the falcon bounce on the home screen: https://chat.openai.com/share/4cba7db0-e79f-4586-91cd-ccf53185f9d9
    
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

        // Create a squiggly flight path
        let flightPath = UIBezierPath()
        flightPath.move(to: CGPoint(x: frame.minX, y: frame.midY))

        // Define points for a squiggly line
        let numberOfSquiggles = 5
        let squiggleWidth = frame.width / CGFloat(numberOfSquiggles)
        var currentX = frame.minX
                
        for i in 0..<numberOfSquiggles {
            let nextX = currentX + squiggleWidth
            let controlPoint1Y = frame.midY + (i % 2 == 0 ? -50 : 50)  // Alternate bump directions
            let controlPoint2Y = frame.midY + (i % 2 == 0 ? 50 : -50)
            flightPath.addCurve(to: CGPoint(x: nextX, y: frame.midY),
                        controlPoint1: CGPoint(x: currentX + squiggleWidth / 2, y: controlPoint1Y),
                        controlPoint2: CGPoint(x: currentX + squiggleWidth / 2, y: controlPoint2Y))
            currentX = nextX
        }

        // Falcon follows the path
        let followPath = SKAction.follow(flightPath.cgPath, asOffset: false, orientToPath: false, speed: 200)
        falconSprite.run(SKAction.repeatForever(followPath))

        addChild(falconSprite)
        
        // Add loading text
        let loadingLabel = SKLabelNode(fontNamed: "Courier")
        loadingLabel.text = "Loading..."
        loadingLabel.fontSize = 30
        loadingLabel.fontColor = SKColor.black
        loadingLabel.position = CGPoint(x: frame.midX, y: falconSprite.position.y - falconSprite.size.height / 2 - 20)  // Adjust the Y position to be below the falcon
        addChild(loadingLabel)
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
                  presentHomeScene(skView)
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
            self.presentHomeScene(skView)
        }
    }
    
    private func presentGameScene(_ skView: SKView) {
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    private func presentHomeScene(_ skView: SKView) {
            let homeScene = HomeScene(size: view.bounds.size)
            homeScene.scaleMode = .resizeFill
            skView.presentScene(homeScene)
    }
}

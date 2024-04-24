/* Name: Jacob M. James & Angelica M. Noyola
* Assignment: Final Project - Flappy Falcon
* Documentation Stmt:
 
    We used Chat GPT to make it so that GameOverScene does not go away until the user touches the screen: https://chat.openai.com/share/38f4bf91-c46e-4436-9947-f9ac5238e7bd
 
    
*/


import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var isLoading = true // here to manage loading status
    
    
  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}

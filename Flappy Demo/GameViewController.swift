/* Name: Jacob M. James
* Assignment: Pex 3 - Rocks and Rockets
* Documentation Stmt: I used chat gpt to generate the image for the earth sprite. I used chat gpt to remove the explosions after 0.8 seconds in the function "rocketDidCollideWithEarth" within the GameScene file. I used chat gpt to help with implementing the accelerometer. The following link is the transcript where I asked Chat gpt to help with the explosion removal and with the accelerometer: https://chat.openai.com/share/05a58c25-7e07-4c6a-a4ac-5cb54b1fc3df
*/


import UIKit
import SpriteKit

class GameViewController: UIViewController {
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

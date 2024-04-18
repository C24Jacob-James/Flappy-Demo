//
//  GameScene.swift
//  RocksAndgliders
//
//  Created by Chad Mello on 2/6/20.
//  Copyright © 2020 Chad Mello. All rights reserved.
//

import SpriteKit
import CoreMotion

// Some operator overloads to deal with GCPoint vector ,math

//Go here for more info on simple vector math: https://www.mathsisfun.com/algebra/vectors.html
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

// no need to worry about this -
// This is a precompiler directive to tweak the
// sqrt function according to the processor/platform.
// Some older 32-bit devices (like anything older than 5S) cannot
// handle 64-bit Float types.
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

// add some vector functionality to the CGPoint class...
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

// Our custom game scene...
class GameScene: SKScene {
  
    struct PhysicsCategory {
        static let none      : UInt32   = 0
        static let all       : UInt32   = UInt32.max
        static let glider   : UInt32    = 0b1
        static let projectile: UInt32   = 0b10
        static let falcon: UInt32       = 0b100
    }
      
    //create the falcon node
    let falcon = SKSpriteNode(imageNamed: "falcon")
    let mountain = SKSpriteNode(imageNamed: "mountains")
    var glidersDestroyed = 0
    var falconHit = 0
    var spaceshipHit = 0
    var score = 0
    
   
    
//    let stars = SKEmitterNode(fileNamed: "Stars")!

    // create the motion manager
    var motionManager: CMMotionManager!
    
    override func didMove(to view: SKView) {
        
        super.didMove(to: view)
        
        // Initialize and start the motion manager
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        
        // set our scene's background color
        backgroundColor = SKColor.skyBlue
        

        createfalcon()
        addMountains()

        
        
        // we're in space - so no gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        
        // we will handle user taps from here...
        physicsWorld.contactDelegate = self
        
        // add some background music
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        // Now, start the game loop
        run(SKAction.repeatForever(
          SKAction.sequence([
            SKAction.run(addGlider),
//            SKAction.run(showScoreBoard),
            SKAction.wait(forDuration: 1.0)
            ])
        ))
        
      }
    
    func createfalcon() {
        // center falcon in Y-axis
        falcon.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        falcon.zPosition = 2
        falcon.size = CGSize(width: size.width * 0.3, height: size.width * 0.4)
//        falcon.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        falcon.physicsBody = SKPhysicsBody(circleOfRadius: falcon.size.width / 4)
        falcon.physicsBody?.isDynamic = true
        // belongs to the "falcon category"
        falcon.physicsBody?.categoryBitMask = PhysicsCategory.falcon
        falcon.physicsBody?.contactTestBitMask = PhysicsCategory.falcon
        
        // add falcon to the scene
        addChild(falcon)
    }
    
    func addMountains() {
        // center the mountains in the y axis
        mountain.position = CGPoint(x: size.width / 2, y: size.height / 2)
        mountain.size = CGSize(width: size.width * 5, height: size.height)
        mountain.zPosition = 1
        addChild(mountain)

    }
    

    

    

      
      //utility function for creating random number...
      func random() -> CGFloat
      {
        //Note: arc4random returns an unsigned integer up to (2^32)-1
        //      Here, we're forcing a return of a float between 0 and 1.
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
      }
      
      func random(min: CGFloat, max: CGFloat) -> CGFloat {
        // return a random number between min and max, inclusive
        return random() * (max - min) + min
      }
      
        
        
      func addGlider() {
        
        // Create sprite for the glider
        let glider = SKSpriteNode(imageNamed: "glider")
          
        
        // change size of plane
          let gliderScale = (size.width * 0.4) / glider.size.width
          glider.setScale(gliderScale)
          
        // add physics simulation to the glider node
        glider.physicsBody = SKPhysicsBody(rectangleOf: glider.size)
        
        // Affected by gravity, friction, collisions, etc..
        glider.physicsBody?.isDynamic = true
        
        // belongs to the "glider category"
        glider.physicsBody?.categoryBitMask = PhysicsCategory.glider
        
        // Here, we're interested in whether the rocker makes contact with a rock, the falcon, and the earth
          glider.physicsBody?.contactTestBitMask = PhysicsCategory.falcon | PhysicsCategory.projectile

        
        // define which categories of physics bodies can collide with a glider
        glider.physicsBody?.collisionBitMask = PhysicsCategory.none
        

        // Determine where to spawn the glider along the Y axis
        let actualY = random(min: glider.size.height/2, max: size.height - glider.size.height/2)
        
        // Position the glider slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        glider.position = CGPoint(x: size.width + glider.size.width/2, y: actualY)
          glider.zPosition = 3
        
        // Add the glider to the scene
        addChild(glider)
          
        // Determine speed of the glider...
        // can take between 2 and 4 seconds to go from one end of the screen to the other
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions...
        
        // setup an action to move the glider from the right to the left, within a certian frame of time.

          let actionMove = SKAction.move(to: CGPoint(x: 0 - glider.size.width, y: glider.position.y), duration: TimeInterval(actualDuration))
          
          
        // shoot directly at the falcon (USED FOR TESTING)
//        let actionMove = SKAction.move(to: CGPoint(x: falcon.position.x, y: falcon.position.y), duration: TimeInterval(actualDuration))

          

          
    
        
        
        // When movement is complete, we want to remove the glider from the scene (VERY IMPORTANT)
        let actionMoveDone = SKAction.removeFromParent()
        
        // This is what happens when the falcon loses (glider gets past you)
        
        // In this clase we're creating a "closure" - or what many might know as a "lambda"
        let loseAction = SKAction.run() { [weak self] in //remember why we use "weak"?
          guard let `self` = self else { return } //
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//          let gameOverScene = GameOverScene(size: self.size, won: false)
//          self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        // ok, set this new glider node in motion with all of the actions we dfined above
        glider.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
    
    
  
  // User touched the screen to throw a rock, let's determine what to do from here...
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    
    
    // Get falcon's projectile (i.e. a new rock) ready to launch
    
    let touchLocation = touch.location(in: self)
    
      falcon.physicsBody?.velocity = CGVector(dx: 0, dy: 750)
      
  }
  
    // Here, we respond to a collision between rock and glider.
    func projectileDidCollideWithglider(projectile: SKSpriteNode, glider: SKSpriteNode) {
      print("glider destroyed")
      projectile.removeFromParent()
      glider.removeFromParent()
      
        score += 10
        
      glidersDestroyed += 1
      if glidersDestroyed > 30 {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        view?.presentScene(gameOverScene, transition: reveal)
      }
    }
    
    // Here, we respond to a collision between glider and falcon.
    func gliderDidCollideWithfalcon(glider: SKSpriteNode, falcon: SKSpriteNode) {
        print("Hit falcon")
        glider.removeFromParent()
      
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false)
        view?.presentScene(gameOverScene, transition: reveal)

    }
    
  

        
 

    // Here, we respond to a collision between projectile and the spaceship.
    func projectileDidCollideWithSpaceship(projectile: SKSpriteNode, spaceship: SKSpriteNode) {
      print("Hit spaceship")
      projectile.removeFromParent()
      
        score += 50
    
        // Add the particle effects
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = CGPoint(x: projectile.position.x, y: projectile.position.y)
            explosion.particleLifetime = 5
            addChild(explosion)
            
            // Remove explosion after 2 seconds
            let removeAfterDelay = SKAction.sequence([
                SKAction.wait(forDuration: 0.8),
                SKAction.removeFromParent()
            ])
            explosion.run(removeAfterDelay)
        }
        
        
      spaceshipHit += 1
      if spaceshipHit >= 100 {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: true)
        view?.presentScene(gameOverScene, transition: reveal)
      }
    }
    
 
}

// Here, we're told that two objects made contact
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Let's get at the objects that made contact...
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        
        print(firstBody.categoryBitMask)
        print(secondBody.categoryBitMask)
        
        // respond if we determine that a rock and glider made contact
        if ((firstBody.categoryBitMask & PhysicsCategory.glider == firstBody.categoryBitMask) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile == secondBody.categoryBitMask)) {
            
            
            if let glider = firstBody.node as? SKSpriteNode,
               let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithglider(projectile: projectile, glider: glider)
            }
        }
        
        // respond if we determine that a glider and the falcon made contact
        if ((firstBody.categoryBitMask & PhysicsCategory.glider == firstBody.categoryBitMask) &&
            (secondBody.categoryBitMask & PhysicsCategory.falcon == secondBody.categoryBitMask)) {
            
            if let glider = firstBody.node as? SKSpriteNode,
               let falcon = secondBody.node as? SKSpriteNode {
                gliderDidCollideWithfalcon(glider: glider, falcon: falcon)
            }
        }
        
        

    }
    
    // This method gets called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        super.update(currentTime)
        
        // end the game if the edges are hit
        if (falcon.position.y < 0 || falcon.position.y > size.height) {
              
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            view?.presentScene(gameOverScene, transition: reveal)

            }
        }
            
}
    



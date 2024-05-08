//
//  GameScene.swift
//  Flappy Falcon
//
// Name: Jacob M. James & Angelica M. Noyola
// Assignment: Final Project - Flappy Falcon
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
        static let glider    : UInt32   = 0b1
        static let twotter   : UInt32   = 0b10
        static let falcon    : UInt32   = 0b100
        static let t53       : UInt32   = 0b1000
    }
    
    // set to true to show the plane hitboxes (Used for debugging)
    var showHitBoxes = true
    
    var gameReadyToStart = false
    
    //create the falcon node
    let falcon = SKSpriteNode(imageNamed: "falcon")
    
    // create the background nodes
    var background1: SKSpriteNode!
    var background2: SKSpriteNode!
    
    // create the timer nodes
    var timerLabel: SKLabelNode!
    var elapsedTime: TimeInterval = 0
    var lastUpdateTime: TimeInterval = 0
    
    // create the score nodes
    var score = 0
    var scoreLabel: SKLabelNode!
    var scoreOutline: SKLabelNode!
    
    // create the motion manager
    var motionManager: CMMotionManager!
    
    // set up pause window
    var pauseWindow: SKNode?
    
    // game over pop up window
    var isGameOver = false
    var gameOverWindow: SKNode?
    
    override func didMove(to view: SKView) {
        
        // Initialize and set up backgrounds
        background1 = createBackground()
        background1.position = CGPoint(x: 0, y: 0)
        addChild(background1)

        background2 = createBackground()
        background2.position = CGPoint(x: background1.size.width, y: 0)
        addChild(background2)
        
        // Start the background movement
        startMovingBackgrounds()
        
        // start the timer
        setupTimerLabel()
        
        // track the score
        setupScoreLabel()
        
        // put the pause button
        setUpPauseButton()
        
        super.didMove(to: view)
        
        // Initialize and start the motion manager
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        
        // set our scene's background color
        backgroundColor = SKColor.skyBlue
        
        createfalcon()

    
        // we're in space - so no gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        
        // we will handle user taps from here...
        physicsWorld.contactDelegate = self
        
        // add some background music
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        // clear the clouds out of the frame and let the planes start coming in
        clearCloudsAndStartGame()
        

        
    }
    
    func startGame(){
        //Now, start the game loop
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(spawnRandomPlane),
                //            SKAction.run(showScoreBoard),
                SKAction.wait(forDuration: 1.5)     // waits 1.5 seconds before spawning a random plane
            ])
        ))
    }
    
    func clearCloudsAndStartGame(){
        let duration = 2.5 // duration for clouds to move out
        for node in children {
                if let cloud = node as? SKSpriteNode, cloud.name == "cloud" {
                    let moveDirection = Bool.random() ? 1: -1 // randomly decide the clearing direciton
                    let endPositionX = moveDirection > 0 ? size.width + cloud.size.width : -cloud.size.width
                    let moveOut = SKAction.move(to: CGPoint(x: endPositionX, y: cloud.position.y), duration: duration)
                    cloud.run(moveOut)
                }
            }
        
        
        // Ensure all actions complete before starting game activities
            run(SKAction.wait(forDuration: duration)) {
                self.gameReadyToStart = true
                self.startGame()
            }
    }
    
    func setUpPauseButton(){
        let pause = SKSpriteNode(imageNamed: "pause")
        pause.size = CGSize(width: size.width * 0.08, height: size.width * 0.11)
        pause.zPosition = 4
        pause.position = CGPoint(x: size.width * 0.9, y: size.height * 0.93)
        pause.name = "pause"
        addChild(pause)
    }
    
    func setupScoreLabel(){
        scoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold") // Assuming the bold version is correctly named
        scoreLabel.fontSize = 60 // Set font size to 60
        scoreLabel.fontColor = SKColor.black // Text color is white
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.9) // Adjusted position
        scoreLabel.zPosition = 10 // Ensure it is above other nodes
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "\(score)"
        
        scoreOutline = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        scoreOutline.fontSize = scoreLabel.fontSize
        scoreOutline.fontColor = SKColor.white
        scoreOutline.position = CGPoint(x: 0, y: 0) // Adjust outline offset
        scoreOutline.zPosition = -1 // Ensure the outline is behind the main text
        scoreOutline.horizontalAlignmentMode = .right
        scoreOutline.text = "\(score)"
        
        scoreLabel.addChild(scoreOutline) // Add outline as a child of the main label to keep them aligned
        addChild(scoreLabel) // Add the main label to the scene
    }
    
    
    func setupTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "AmericanTypewriter-Bold") // Assuming the bold version is correctly named
        timerLabel.fontSize = 20 // Set font size to 60
        timerLabel.fontColor = SKColor.black // Text color is white
        //timerLabel.position = CGPoint(x: size.width * 0.1, y: size.height * 0.9) // Adjusted position
        timerLabel.position = CGPoint(x: size.width * 0.84, y: size.height * 0.875)
        timerLabel.zPosition = 5 // Ensure it is above other nodes
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.text = "Time: 0.0"

        // Set up outline
        let outline = SKLabelNode(fontNamed: "AmericanTypewriter-Bold")
        outline.fontSize = timerLabel.fontSize
        outline.fontColor = SKColor.white
        //outline.position = CGPoint(x: 0, y: 0) // Adjust outline offset
        outline.position = CGPoint(x: size.width * 0.84, y: size.height * 0.875)
        outline.zPosition = -1 // Ensure the outline is behind the main text
        outline.horizontalAlignmentMode = .left
        outline.text = "Time: 0.0"

        timerLabel.addChild(outline) // Add outline as a child of the main label to keep them aligned
        addChild(timerLabel) // Add the main label to the scene
    }
    
        
    func createBackground() -> SKSpriteNode {
        let bg = SKSpriteNode(imageNamed: "mountains") // Replace with your actual image
        bg.zPosition = -1 // Ensure it's behind other sprites
        bg.anchorPoint = CGPoint.zero
        
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
//      bg.size = CGSize(width: size.width * 5, height: size.height)
        bg.zPosition = 1
        let scale =  frame.size.height/bg.size.height
        bg.setScale(scale)
        
        return bg
    }
    
    func startMovingBackgrounds() {
        let moveLeft = SKAction.moveBy(x: -background1.size.width, y: 0, duration: 40.0) // Adjust duration for speed
        let resetPosition = SKAction.moveBy(x: background1.size.width, y: 0, duration: 0)
        let moveSequence = SKAction.sequence([moveLeft, resetPosition])
        let repeatForever = SKAction.repeatForever(moveSequence)

        background1.run(repeatForever)
        background2.run(repeatForever)
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
    
    func createfalcon() {
        
        let physicsSize = size.width / 8
        
        // center falcon in Y-axis
        falcon.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        falcon.zPosition = 2
        falcon.size = CGSize(width: size.width * 0.3, height: size.width * 0.4)
        falcon.physicsBody = SKPhysicsBody(circleOfRadius: physicsSize)
        falcon.physicsBody?.isDynamic = false
        // belongs to the "falcon category"
        falcon.physicsBody?.categoryBitMask = PhysicsCategory.falcon
        falcon.physicsBody?.contactTestBitMask = PhysicsCategory.t53
        
        // Show the hitboxes
        if(showHitBoxes){
            let debugShape = SKShapeNode(circleOfRadius: physicsSize)
            debugShape.strokeColor = SKColor.red
            debugShape.lineWidth = 5.0
            debugShape.zPosition = 1 // Ensure it does not cover the sprite visually
            falcon.addChild(debugShape)
        }
        
        // add falcon to the scene
        addChild(falcon)
    }
    
    func spawnRandomPlane() {
//        let randomPlane = Int(random(min: 1, max: 3))
        let randomPlane = 2

        
        if randomPlane == 1{
            addGlider()
//            print("glider")
        }
        if randomPlane == 2{
            addTwotter()
//            print("twotter")
        }
        if randomPlane == 3{
            addT53()
//            print("t53")
        }
    }
    
    func addGlider() {
        
        // Create sprite for the glider
        let glider = SKSpriteNode(imageNamed: "glider 1")
        
        let physicsSize = CGSize(width: glider.size.width * 0.25, height: glider.size.height * 0.25)
        
        // change size of glider
        glider.size = physicsSize
        
        // add physics simulation to the glider node
        glider.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: glider.size.width * 0.4, height: glider.size.height * 0.1))
        
        // Affected by gravity, friction, collisions, etc..
        glider.physicsBody?.isDynamic = true
        
        // belongs to the "glider category"
        glider.physicsBody?.categoryBitMask = PhysicsCategory.glider
        
        // Here, we're interested in whether the rocker makes contact with a rock, the falcon, and the earth
        glider.physicsBody?.contactTestBitMask = PhysicsCategory.falcon
        
        
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
        
        if(showHitBoxes){
            let debugShape = SKShapeNode(rectOf: CGSize(width: glider.size.width * 0.4, height: glider.size.height * 0.1))
            debugShape.strokeColor = SKColor.red
            debugShape.lineWidth = 5.0
            debugShape.zPosition = 1 // Ensure it does not cover the sprite visually
            glider.addChild(debugShape)
        }
        
        
        // Create the actions...
        
        // setup an action to move the glider from the right to the left, within a certian frame of time.
        
        let actionMove = SKAction.move(to: CGPoint(x: 0 - glider.size.width, y: glider.position.y), duration: TimeInterval(4)) // takes 4 seconds for the glider to cross the screen (slow)
        
        // score increases if falcon passes the glider
        let checkPass = SKAction.run{
            if glider.parent != nil{
                self.score += 1
                self.scoreOutline.text = "\(self.score)"
                self.scoreLabel.text = "\(self.score)" // display the new score
//                print("cleared the glider")
            }
            else{
//                print("you thought mia")
            }
        }
        
        // When movement is complete, we want to remove the glider from the scene (VERY IMPORTANT)
        let actionMoveDone = SKAction.removeFromParent()
        
        
        // ok, set this new glider node in motion with all of the actions we dfined above
        glider.run(SKAction.sequence([actionMove, checkPass, actionMoveDone]))
    }
    
    func addTwotter() {
        
        // Create sprite for the glider
        let twotter = SKSpriteNode(imageNamed: "Twotter")
        
        let physicsSize = CGSize(width: size.width * 0.3, height: size.height * 0.1)
        
        // change size of plane
        twotter.size = CGSize(width: size.width * 0.4, height: size.height * 0.35)
        
        // add physics simulation to the twotter node
        twotter.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)

        // Affected by gravity, friction, collisions, etc..
        twotter.physicsBody?.isDynamic = true
        
        // belongs to the "twotter category"
        twotter.physicsBody?.categoryBitMask = PhysicsCategory.twotter
        
        // Here, we're interested in whether the rocker makes contact with a rock, the falcon, and the earth
        twotter.physicsBody?.contactTestBitMask = PhysicsCategory.falcon
        
        
        // define which categories of physics bodies can collide with a twotter
        twotter.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        
        // Determine where to spawn the twotter along the Y axis
        let actualY = random(min: twotter.size.height/2, max: size.height - twotter.size.height/2)
        
        // Position the twotter slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        twotter.position = CGPoint(x: size.width + twotter.size.width/2, y: actualY)
        twotter.zPosition = 3
        
        // Add the twotter to the scene
        addChild(twotter)
        
        // Show the hitboxes
        if(showHitBoxes){
            let debugShape = SKShapeNode(rectOf: physicsSize)
            debugShape.strokeColor = SKColor.red
            debugShape.lineWidth = 5.0
            debugShape.zPosition = 1 // Ensure it does not cover the sprite visually
            twotter.addChild(debugShape)
        }
        
        // Create the actions...
        
        // setup an action to move the twotter from the right to the left, within a certian frame of time.
        
        let actionMove = SKAction.move(to: CGPoint(x: 0 - twotter.size.width, y: twotter.position.y), duration: TimeInterval(3)) // takes 3 seconds for the twotter to cross the screen (slow)
        
        // score increases if falcon passes the twotter
        let checkPass = SKAction.run{
            if twotter.parent != nil{
                self.score += 1
                self.scoreOutline.text = "\(self.score)"
                self.scoreLabel.text = "\(self.score)" // display the new score
//                print("cleared the twotter")

            }
            else{
//                print("you thought mia")
            }
        }
        
        // When movement is complete, we want to remove the twotter from the scene (VERY IMPORTANT)
        let actionMoveDone = SKAction.removeFromParent()

        
        // ok, set this new twotter node in motion with all of the actions we dfined above
        twotter.run(SKAction.sequence([actionMove,checkPass,actionMoveDone]))
    }

    func addT53(){
        
        // Create sprite for the t53
        let t53 = SKSpriteNode(imageNamed: "T53")
        
        
        // change size of plane
        let t53Scale = (size.width * 0.4) / t53.size.width
        t53.setScale(t53Scale)
        
        let physicsSize = CGSize(width: t53.size.width, height: t53.size.height)
        
        // add physics simulation to the twotter node
        t53.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        
        // Affected by gravity, friction, collisions, etc..
        t53.physicsBody?.isDynamic = true
        
        // belongs to the "t53 category"
        t53.physicsBody?.categoryBitMask = PhysicsCategory.t53
        
        // Here, we're interested in whether the rocker makes contact with the falcon
        t53.physicsBody?.contactTestBitMask = PhysicsCategory.falcon
        
        
        // define which categories of physics bodies can collide with a t53
        t53.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        
        // Determine where to spawn the twotter along the Y axis
        let actualY = random(min: t53.size.height/2, max: size.height - t53.size.height/2)
        
        // Position the twotter slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        t53.position = CGPoint(x: size.width + t53.size.width/2, y: actualY)
        t53.zPosition = 3
        
        // Add the twotter to the scene
        addChild(t53)
        
        // Show the hitboxes
        if(showHitBoxes){
            let debugShape = SKShapeNode(rectOf: physicsSize)
            debugShape.strokeColor = SKColor.red
            debugShape.lineWidth = 5.0
            debugShape.zPosition = 1 // Ensure it does not cover the sprite visually
            t53.addChild(debugShape)
        }
        
        // Create the actions...
        
        // setup an action to move the twotter from the right to the left, within a certian frame of time.
        
        let actionMove = SKAction.move(to: CGPoint(x: 0 - t53.size.width, y: t53.position.y), duration: TimeInterval(2)) // takes 2 seconds for the twotter to cross the screen (slow)
        
        // score increases if falcon passes the twotter
        let checkPass = SKAction.run{
            if t53.parent != nil{
                self.score += 1
                self.scoreOutline.text = "\(self.score)"
                self.scoreLabel.text = "\(self.score)" // display the new score
//                print("cleared the t53")
            }
            else{
//                print("you thought mia")
            }
        }
        
        // When movement is complete, we want to remove the twotter from the scene (VERY IMPORTANT)
        let actionMoveDone = SKAction.removeFromParent()

        
        // ok, set this new t53 node in motion with all of the actions we defined above
        t53.run(SKAction.sequence([actionMove, checkPass, actionMoveDone]))
    }
    
    
    func setupPauseWindow() {
        // Define a linear gradient that transitions from white in the center to sky blue in the corners
        let gradient = SKShader(source: """
            void main() {
                vec2 coord = v_tex_coord - vec2(0.5, 0.5); // Centered and normalized to -0.5 to 0.5
                float maxDist = 0.5; // Maximum distance from center to corners
                float dist = max(abs(coord.x), abs(coord.y)); // Compute distance to the nearest edge
                vec4 innerColor = vec4(1.0, 1.0, 1.0, 1.0); // White center
                vec4 outerColor = vec4(0.529, 0.808, 1.0, 1.0); // Sky blue at edges
                gl_FragColor = mix(innerColor, outerColor, smoothstep(0.3, 0.5, dist)); // Gradually mix to blue towards the edges
            }
        """)

        // Create the rounded gradient background node
        let gradientNode = SKShapeNode(rect: CGRect(x: -175, y: -125, width: 350, height: 250), cornerRadius: 20)
        gradientNode.fillShader = gradient
        gradientNode.strokeColor = SKColor.black // Thick black border
        gradientNode.lineWidth = 10
        gradientNode.zPosition = 9

        // Create the pause window frame
        pauseWindow = SKSpriteNode(color: .clear, size: CGSize(width: 350, height: 250))
        pauseWindow?.position = CGPoint(x: frame.midX, y: frame.midY)
        pauseWindow?.zPosition = 10
        pauseWindow?.addChild(gradientNode)

        // Styling the "Game Paused" label
        let pauseLabel = SKLabelNode(fontNamed: "Courier-Bold")
        pauseLabel.text = "Game Paused"
        pauseLabel.fontSize = 24
        pauseLabel.fontColor = SKColor.black
        pauseLabel.position = CGPoint(x: 0, y: 40) // Adjusted position for larger size
        pauseLabel.zPosition = 11
        pauseWindow?.addChild(pauseLabel)

        // Styling the score label
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.text = "Current Score: \(score)"  // Update with actual score
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: 0, y: -50) // Adjusted position for larger size
        scoreLabel.zPosition = 12
        pauseWindow?.addChild(scoreLabel)
    }




    
    func togglePause(){
        if self.isPaused{
            // resume the game
            self.isPaused = false
            pauseWindow?.removeFromParent()
        } else{
            // pause the game
            self.isPaused = true
            setupPauseWindow()
            if let pauseWindow = pauseWindow{
                self.addChild(pauseWindow)
            }
        }
    }
    
    func setUpGameOverWindow(){
        gameOverWindow = SKSpriteNode(color: .white, size: CGSize(width: 300, height: 200))
        gameOverWindow?.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverWindow?.zPosition = 11
        
        // Define a linear gradient that transitions from white in the center to sky blue in the corners
        let gradient = SKShader(source: """
            void main() {
                vec2 coord = v_tex_coord - vec2(0.5, 0.5); // Centered and normalized to -0.5 to 0.5
                float maxDist = 0.5; // Maximum distance from center to corners
                float dist = max(abs(coord.x), abs(coord.y)); // Compute distance to the nearest edge
                vec4 innerColor = vec4(1.0, 1.0, 1.0, 1.0); // White center
                vec4 outerColor = vec4(0.529, 0.808, 1.0, 1.0); // Sky blue at edges
                gl_FragColor = mix(innerColor, outerColor, smoothstep(0.3, 0.5, dist)); // Gradually mix to blue towards the edges
            }
        """)

        // Create the rounded gradient background node
        let gradientNode = SKShapeNode(rect: CGRect(x: -175, y: -125, width: 350, height: 250), cornerRadius: 20)
        gradientNode.fillShader = gradient
        gradientNode.strokeColor = SKColor.black // Thick black border
        gradientNode.lineWidth = 10
        gradientNode.zPosition = 10
        gameOverWindow?.addChild(gradientNode)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier-Bold")
        gameOverLabel.text = "Flappy Falcon Died"
        gameOverLabel.fontSize = 24
        gameOverLabel.fontColor = .black
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 12
        gameOverWindow?.addChild(gameOverLabel)

        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.text = "Score: \(score)"  // Update with actual score
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: 0, y: 10)
        scoreLabel.zPosition = 13
        gameOverWindow?.addChild(scoreLabel)
        
        let highScoreLabel = SKLabelNode(fontNamed: "Courier")
        highScoreLabel.text = "High Score: \(loadHighScore())"  // Update with actual score
        highScoreLabel.fontSize = 20
        highScoreLabel.fontColor = .black
        highScoreLabel.position = CGPoint(x: 0, y: -20)
        highScoreLabel.zPosition = 14
        gameOverWindow?.addChild(highScoreLabel)

        let newGameButton = SKLabelNode(fontNamed: "Courier")
        newGameButton.name = "newGame"
        newGameButton.text = "New Game"
        newGameButton.fontSize = 18
        newGameButton.fontColor = .blue
        newGameButton.position = CGPoint(x: -90, y: -60)
        newGameButton.zPosition = 15
        gameOverWindow?.addChild(newGameButton)

        let returnHomeButton = SKLabelNode(fontNamed: "Courier")
        returnHomeButton.name = "returnHome"
        returnHomeButton.text = "Return to Home"
        returnHomeButton.fontSize = 18
        returnHomeButton.fontColor = .blue
        returnHomeButton.position = CGPoint(x: 50, y: -60)
        returnHomeButton.zPosition = 15
        gameOverWindow?.addChild(returnHomeButton)
    }
    
    func handleGameOver(){
        saveHighScore(score: score)
        // pop up window over the current game scene
        setUpGameOverWindow()
        if let window = gameOverWindow {
            addChild(window)
            isGameOver = true
            self.isPaused = true  // This will freeze the game elements
        }
    }
    
    func restartGame() {
        let transition = SKTransition.fade(withDuration: 1.0)  // Use your preferred transition
        let gameScene = GameScene(size: self.size)
        self.view?.presentScene(gameScene, transition: transition)
    }

    func returnToHome() {
        let transition = SKTransition.fade(withDuration: 1.0)  // Use your preferred transition
        let homeScene = HomeScene(size: self.size)  // Assuming you have a HomeScene class
        self.view?.presentScene(homeScene, transition: transition)
    }
    
    
    // Functions to save high score and timer
    func saveHighScore(score: Int) {
        let defaults = UserDefaults.standard
        // Check if the current score is greater than the saved high score
        let highScore = defaults.integer(forKey: "highScore")
        if score > highScore {
            defaults.set(score, forKey: "highScore")
        }
    }
    
    func loadHighScore() -> Int {
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: "highScore")
    }
    
    
    
    // User touched the screen after game ended.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let location = touch?.location(in: self)
        let node = self.atPoint(location!)
        
        if isGameOver {
            if node.name == "newGame"{
                restartGame()
            } else if node.name == "returnHome"{
                returnToHome()
            }
        } else{
            if node.name == "pause" {
                togglePause()
            } else{
                // Everytime we touch the screen, there the jumps upward.
                falcon.physicsBody?.velocity = CGVector(dx: 0, dy: 750)
                
                if gameReadyToStart{
                    if !(falcon.physicsBody?.isDynamic ?? false) {
                        falcon.physicsBody?.isDynamic = true
                        falcon.physicsBody?.velocity = CGVector(dx: 0, dy: 750)
                    }
                }
            }
        }
        
    }
    
    
    // Here, we respond to a collision between glider and falcon.
    func gliderDidCollideWithfalcon(glider: SKSpriteNode, falcon: SKSpriteNode) {
        let reveal = SKTransition.crossFade(withDuration: 3)
        handleGameOver()
    }
    
    // Here, we respond to a collision between the twotter and falcon.
    func twotterDidCollideWithfalcon(twotter: SKSpriteNode, falcon: SKSpriteNode) {
        let reveal = SKTransition.crossFade(withDuration: 3)
        handleGameOver()
    }
    
    // Here, we respond to a collision between the t53 and falcon.
    func t53DidCollideWithfalcon(t53: SKSpriteNode, falcon: SKSpriteNode) {
        let reveal = SKTransition.crossFade(withDuration: 3)
        handleGameOver()
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
        
        // respond if we determine that a glider and the falcon made contact
        if ((firstBody.categoryBitMask & PhysicsCategory.glider == firstBody.categoryBitMask) &&
            (secondBody.categoryBitMask & PhysicsCategory.falcon == secondBody.categoryBitMask)) {
            
            if let glider = firstBody.node as? SKSpriteNode,
               let falcon = secondBody.node as? SKSpriteNode {
                gliderDidCollideWithfalcon(glider: glider, falcon: falcon)
            }
        }
        
        
        // respond if we determine that the twotter and the falcon made contact
        if ((firstBody.categoryBitMask & PhysicsCategory.twotter == firstBody.categoryBitMask) &&
            (secondBody.categoryBitMask & PhysicsCategory.falcon == secondBody.categoryBitMask)) {
            
            if let twotter = firstBody.node as? SKSpriteNode,
               let falcon = secondBody.node as? SKSpriteNode {
                twotterDidCollideWithfalcon(twotter: twotter, falcon: falcon)
            }
        }
        
        // respond if we determine that the t53 and the falcon made contact
        if ((firstBody.categoryBitMask & PhysicsCategory.falcon == firstBody.categoryBitMask) &&
            (secondBody.categoryBitMask & PhysicsCategory.t53 == secondBody.categoryBitMask)) {
            
            if let t53 = firstBody.node as? SKSpriteNode,
               let falcon = secondBody.node as? SKSpriteNode {
                t53DidCollideWithfalcon(t53: t53, falcon: falcon)
            }
        }
        

    }
    
    // This method gets called before each frame is rendered
    override func update(_ currentTime: TimeInterval) {
        
        // update the timer
        super.update(currentTime)

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = currentTime - lastUpdateTime
        elapsedTime += deltaTime

        // Format the new time
        let formattedTime = String(format: "Time: %.1f", elapsedTime)

        // Update the main timer label and its outline
        timerLabel.text = formattedTime
        if let outlineLabel = timerLabel.children.first as? SKLabelNode {
            outlineLabel.text = formattedTime
        }

        lastUpdateTime = currentTime
        
        // end the game if the edges are hit
        if (falcon.position.y < 0 || falcon.position.y > size.height) {
              
            let reveal = SKTransition.crossFade(withDuration: 3)
            //let gameOverScene = GameOverScene(size: self.size)
            //view?.presentScene(gameOverScene, transition: reveal)
            handleGameOver()

//            let gameOverScene = GameOverScene(size: self.size)
//            view?.presentScene(gameOverScene, transition: reveal)

            }
        }
            
}
    



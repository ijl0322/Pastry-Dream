//
//  GameScene.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 16/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Edge: UInt32 = 0b1  //1
    static let Obstacle: UInt32 = 0b10 //2
    static let LeftWood: UInt32 = 0b100 //4
    static let RightWood: UInt32 = 0b1000 //8
    static let LeftCat: UInt32 = 0b10000 //16
    static let RightCat: UInt32 = 0b100000 //32
    static let Bread: UInt32 = 0b1000000 //64
    static let Floor: UInt32 = 0b10000000 //128
}

enum GameState: Int {
    case initial=0, start, play, win, lose, reload, pause, end
}

class GameScene: SKScene, SKPhysicsContactDelegate{

    let TileWidth: CGFloat = 100.0
    let TileHeight: CGFloat = 100.0
    let space: CGFloat = 50.0
    var level = Level(num: 1)
    var scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 80)
    var timeLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 80)
    var playableMargin: CGFloat = 0.0
    var seesawLeftBound: CGFloat = 0.0
    var seesawRightBound: CGFloat = 0.0
    var elapsedTime: Int = 0
    var startTime: Int?
    var timeLimit = 10
    var seesawNode: SeesawNode?
    var rightCatNode: CatSpriteNode!
    var leftCatNode: CatSpriteNode!
    var gameEndNotificationNode: GameEndNotificationNode?
    var pausedNotice: GamePausedNotificationNode?
    
    //Game State
    var score = 0
    var gameState: GameState = .initial
    
    override func didMove(to view: SKView) {
        if gameState == .initial {
            setUpScene(view: view)
        } else if gameState == .pause && seesawNode == nil{
            gameState = .reload
            pausedNotice = GamePausedNotificationNode()
            pausedNotice?.zPosition = 90
            addChild(pausedNotice!)
            addMKLabels()
            addCatAndSeesaw()
            timeLabel.outlinedText = (timeLimit - elapsedTime).secondsToFormatedString()
        }
        //view.showsPhysics = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactToTouches(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactToTouches(touches: touches)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameState != .play {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask
            | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.Bread {
            eatBread(contact: contact, catNode: leftCatNode)
        }
        
        if collision == PhysicsCategory.RightCat | PhysicsCategory.Bread {
            eatBread(contact: contact, catNode: rightCatNode)
        }
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.LeftWood {
            fixCat(catSeatSide: .left)
            releaseCat(catNode: rightCatNode)
        }
        
        if collision == PhysicsCategory.RightCat | PhysicsCategory.RightWood {
            fixCat(catSeatSide: .right)
            releaseCat(catNode: leftCatNode)
        }
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.Floor {
            print("Cat fell!")
            if gameState == .play {
                gameState = .lose
                print(level.levelCompleteStatus(score: score))
                leftCatNode.angryAnimation()
            }
        }
        
        if collision == PhysicsCategory.RightCat | PhysicsCategory.Floor {
            print("Cat fell!")
            
            if gameState == .play {
                gameState = .lose
                print(level.levelCompleteStatus(score: score))
                rightCatNode.angryAnimation()
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //print(gameState)
        
        if gameState == .play {
            checkGameState()
            updateTime(currentTime: currentTime)
        }
        
        if gameState == .pause || gameState == .reload {
            isPaused = true
            return
        }
        
        if gameState == .win {
            endGame()
            gameState = .end
            return
        }
        
        if gameState == .lose {
            seesawNode?.stopMovement()
            endGame()
            gameState = .end
            return
        }
        
        if gameState == .end {
            
        }
    }
    
    //MARK: - Encode/Decoder
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(level.levelNum, forKey: "Scene.level")
        aCoder.encode(Float(playableMargin), forKey: "Scene.playableMargin")
        aCoder.encode(Float(seesawLeftBound), forKey: "Scene.seesawLeftBound")
        aCoder.encode(Float(seesawRightBound), forKey: "Scene.seesawRightBound")
        aCoder.encode(elapsedTime, forKey: "Scene.elapsedTime")
        aCoder.encode(timeLimit, forKey: "Scene.timeLimit")
        aCoder.encode(score, forKey: "Scene.score")
        aCoder.encode(gameState.rawValue,
                      forKey: "Scene.gameState")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let savedGameState = aDecoder.decodeInteger(
            forKey: "Scene.gameState")
        if let gameState = GameState(rawValue: savedGameState),
            gameState == .pause {
            self.gameState = gameState
            level = Level(num: aDecoder.decodeInteger(forKey: "Scene.level"))
            _ = level.loadBread()
            playableMargin = CGFloat(aDecoder.decodeFloat(forKey: "Scene.playableMargin"))
            seesawLeftBound = CGFloat(aDecoder.decodeFloat(forKey: "Scene.seesawLeftBound"))
            seesawRightBound = CGFloat(aDecoder.decodeFloat(forKey: "Scene.seesawRightBound"))
            elapsedTime = aDecoder.decodeInteger(forKey: "Scene.elapsedTime")
            timeLimit = aDecoder.decodeInteger(forKey: "Scene.timeLimit")
            score = aDecoder.decodeInteger(forKey: "Scene.score")
            scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 80)
            timeLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 80)
        }
        
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Game Helper Functions

extension GameScene {
    
    //MARK: - Game State Manegement Helper
    func endGame() {
        gameEndNotificationNode = GameEndNotificationNode(score: score, levelStatus: level.levelCompleteStatus(score: score), time: timeLimit - elapsedTime, level: level.levelNum)
        gameEndNotificationNode?.zPosition = 150
        self.scene?.addChild(gameEndNotificationNode!)
        gameEndNotificationNode?.animateStarsReceived()
        score += (gameEndNotificationNode?.animateBonus(time: timeLimit - elapsedTime))!
        UserData.shared.updateHighScoreForLevel(level.levelNum, score: score, levelCompleteType: level.levelCompleteStatus(score: score))
        LeaderBoardManager.sharedInstance.postScore(score, level: level.levelNum)
        timeLabel.removeAllActions()
    }
    
    // Update the timer's time according to the start/elapsed time
    func updateTime(currentTime: TimeInterval) {
        if let startTime = startTime {
            elapsedTime = Int(currentTime) - startTime
        } else {
            startTime = Int(currentTime) - elapsedTime
        }
        
        timeLabel.outlinedText = (timeLimit - elapsedTime).secondsToFormatedString()
        
        if timeLimit - elapsedTime <= 5 {
            if timeLabel.action(forKey: "timeout") == nil {
                let warningAction = SKAction.scale(by: 1.3, duration: 0.5)
                let reversedAction = warningAction.reversed()
                let sequence = SKAction.sequence([warningAction, reversedAction])
                timeLabel.run(SKAction.repeatForever(sequence), withKey: "timeout")
            }
        }
    }
    
    // Handles transitioning to a new game scene
    func transitionToScene(level: Int) {
        print("Transitionaing to new scene")
        guard let newScene = SKScene(fileNamed: "GameScene")
            as? GameScene else {
                fatalError("Level: \(level) not found")
        }
        newScene.scaleMode = .aspectFill
        newScene.level = Level(num: level)
        view!.presentScene(newScene,
                           transition: SKTransition.flipVertical(withDuration: 0.5))
    }
    
    // Hangles transitioning to the level select scene
    func transitionToLevelSelect() {
        print("Transitionaing to level select")
        guard let newScene = SKScene(fileNamed: "LevelSelectionScene")
            as? LevelSelectionScene else {
                fatalError("Cannot load level selection scene")
        }
        newScene.scaleMode = .aspectFill
        view!.presentScene(newScene,
                           transition: SKTransition.flipVertical(withDuration: 0.5))
    }
    
    // Draw a red rectangle around the playable area (an area that can show properly on all devices)
    func debugDrawPlayableArea(playableRect: CGRect) {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 10.0
        addChild(shape)
    }
    
    // Check current game state
    // This only checks for win => which is when all bread are eaten
    // And lose => when time is up
    // Other situations like the cat falling to the ground is handled by collision detection
    func checkGameState() {
        
        if score >= level.highestScore {
            gameState = .win
        }
        
        if timeLimit - elapsedTime <= 0 {
            gameState = .lose
        }
    }
    
    //MARK: - Cat Animation Helper
    
    // Animate the cat eating a bread, add score, remove bread, and drop the cat slightly
    func eatBread(contact: SKPhysicsContact, catNode: CatSpriteNode?) {
        let breadNode = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Bread ? contact.bodyA.node :
            contact.bodyB.node
        let breadAte = breadNode as? BreadNode
        catNode?.dropSlightly()
        catNode?.eatBreadAnimation()
        score += (breadAte?.remove())!
        scoreLabel.borderOffset = CGPoint(x: 1, y: 1)
        scoreLabel.outlinedText = "\(score)"
        //print("My Score: \(score)")
    }
    
    // Remove the cat's join from the seesaw, enabling the cat to jump
    func releaseCat(catNode: CatSpriteNode) {
        
        catNode.disableSeesawContact()
        seesawNode?.releaseCat(catSide: catNode.seatSide)
        if catNode.canJump {
            catNode.jump()
            catNode.canJump = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            //print("Enabling the contact")
            catNode.enableSeesawContact()
        })
    }
    
    // Add a join between the cat and the seesaw, 
    // Fixing it appropriately to it's side of the seesaw
    func fixCat(catSeatSide: SeatSide) {
        switch catSeatSide {
        case .left:
            let xPosition = (seesawNode?.position.x)! - ((seesawNode?.frame.width)!/4)
            let yPosition = (seesawNode?.position.y)! + (leftCatNode.frame.height)/2.5
            leftCatNode?.position = CGPoint(x: xPosition, y: yPosition)
            leftCatNode.canJump = true
            seesawNode?.fixCat(catNode: leftCatNode!)
        case .right:
            let xPosition = (seesawNode?.position.x)! + ((seesawNode?.frame.width)!/4)
            let yPosition = (seesawNode?.position.y)! + (rightCatNode.frame.height)/2.5
            rightCatNode?.position = CGPoint(x: xPosition, y: yPosition)
            rightCatNode.canJump = true
            seesawNode?.fixCat(catNode: rightCatNode!)
        default:
            return
        }
    }
    
    // MARK: - Bread Helper
    
    // Add bread nodes to the scene
    func addBread(breads: Set<Bread>) {
        for bread in breads {
            let size = CGSize(width: TileWidth, height: TileHeight)
            let sprite = BreadNode(size: size, breadType: bread.breadType)
            sprite.position = pointFor(column: bread.column, row: bread.row)
            self.scene?.addChild(sprite)
            bread.sprite = sprite
        }
    }
    
    // Returns a CGPoint to position the bread, according to the row and column
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*(TileWidth + space) + TileWidth/2 + playableMargin,
            y: CGFloat(row)*TileHeight + TileHeight/2 + size.height/2)
    }
    
    //MARK: - Game Scene Setup
    
    // Set up the game scene
    // Add a bounding rectangle to constraint the cat's position
    
    func setUpScene(view: SKView) {
        
        gameState = .start
        
        let maxAspectRatio: CGFloat = 9.0/16.0
        let maxAspectRatioWidth = size.height * maxAspectRatio
        playableMargin = (size.width
            - maxAspectRatioWidth)/2
        let playableRect = CGRect(x:  playableMargin, y: 0,
                                  width: maxAspectRatioWidth, height: size.height)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        timeLimit = level.timeLimit
        
        addMKLabels()
        addCatAndSeesaw()
        
        let allBreads = level.loadBread()
        addBread(breads: allBreads)
    }
    
    // Add cat and seesaw to the scene
    func addCatAndSeesaw() {
        seesawNode = SeesawNode()
        seesawLeftBound = playableMargin + (seesawNode?.frame.width)!/2
        seesawRightBound = size.width - playableMargin - (seesawNode?.frame.width)!/2
        seesawNode?.physicsBody?.isDynamic = false
        self.scene?.addChild(seesawNode!)
        seesawNode?.didMoveToScene()
        
        let rightCatxPosition = (seesawNode?.position.x)! + ((seesawNode?.frame.width)!/4)
        let leftCatxPosition = (seesawNode?.position.x)! - ((seesawNode?.frame.width)!/4)
        let catyPosition = (seesawNode?.position.y)! + (330)/2
        
        rightCatNode = CatSpriteNode(catType: .cat2, isLeftCat: false)
        rightCatNode.position = CGPoint(x: rightCatxPosition, y: catyPosition)
        rightCatNode.zPosition = 20
        self.scene?.addChild(rightCatNode)
        
        leftCatNode = CatSpriteNode(catType: .cat1, isLeftCat: true)
        leftCatNode.position = CGPoint(x: leftCatxPosition, y: catyPosition)
        leftCatNode.zPosition = 30
        self.scene?.addChild(leftCatNode)
    }
    
    // Add score/time label to the scene
    func addMKLabels() {
        scoreLabel.borderColor = UIColor.red
        scoreLabel.fontColor = UIColor.white
        scoreLabel.outlinedText = "\(score)"
        scoreLabel.zPosition = 15
        scoreLabel.position = CGPoint(x: 1217, y: 25)
        addChild(scoreLabel)
    
        timeLabel.borderColor = UIColor.red
        timeLabel.fontColor = UIColor.white
        timeLabel.outlinedText = timeLimit.secondsToFormatedString()
        timeLabel.zPosition = 15
        timeLabel.position = CGPoint(x: 364, y: 25)
        addChild(timeLabel)
    }
    
    //MARK: - Touches Helper
    
    func reactToTouches(touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        switch gameState {
            
        case .start:
            seesawNode?.physicsBody?.isDynamic = true
            gameState = .play
            isPaused = false
            seesawNode?.fixCat(catNode: rightCatNode)
            releaseCat(catNode: leftCatNode)
            
        case .play:
            seesawNode?.moveWithinBounds(targetLocation: touchLocation.x, leftBound: seesawLeftBound,
                                         rightBound: seesawRightBound)
        case .end:
            if let touchedNode =
                atPoint(touch.location(in: self)) as? SKSpriteNode {
                if touchedNode.name == ButtonName.replay {
                    transitionToScene(level: level.levelNum)
                } else if touchedNode.name == ButtonName.next {
                    transitionToScene(level: level.levelNum + 1)
                } else if touchedNode.name == ButtonName.levels {
                    transitionToLevelSelect()
                } else if touchedNode.name == ButtonName.leaderBoard {
                    let gameEndNotice = childNode(withName: "gameEndNotification")
                    gameEndNotice?.removeFromParent()
                    var leaderBoard = childNode(withName: "leaderBoard")
                    if leaderBoard == nil {
                        leaderBoard = LeaderBoardNode(level: level.levelNum, levelStatus: level.levelCompleteStatus(score: score))
                        self.addChild(leaderBoard!)
                    }
                }
            }
        case .reload:
            if let touchedNode =
                atPoint(touch.location(in: self)) as? SKSpriteNode {
                if touchedNode.name == ButtonName.yes {
                    print("Resume game")
                    pausedNotice?.removeFromParent()
                    isPaused = false
                    startTime = nil
                    gameState = .start
                } else if touchedNode.name == ButtonName.no {
                    transitionToScene(level: level.levelNum)
                }
            }
        default:
            return
        }
    }
}

//MARK: - Game Archieving

extension GameScene {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidEnterBackground),
                                               name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    func applicationDidBecomeActive() {
        if gameState == .pause {
            gameState = .reload
            pausedNotice = GamePausedNotificationNode()
            pausedNotice?.zPosition = 90
            addChild(pausedNotice!)
            addMKLabels()
            addCatAndSeesaw()
        }
    }
    
    func applicationWillResignActive() {
        
        isPaused = true
        if gameState == .play {
            gameState = .pause
            print("pausing game")
        }
    }
    
    func applicationDidEnterBackground() {
        if gameState == .pause {
            let pauseNotice = childNode(withName: "pauseNotice")
            if let pauseNotice = pauseNotice {
                pauseNotice.removeFromParent()
            }
            scoreLabel.removeFromParent()
            timeLabel.removeFromParent()
            leftCatNode.removeFromParent()
            rightCatNode.removeFromParent()
            seesawNode?.removeFromParent()
            seesawNode = nil
            print("Entering background")
            saveGame()
        }
    }
    
    // Archive current game to user's device
    func saveGame() {
        let fileManager = FileManager.default
        guard let directory =
            fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
        let saveURL = directory.appendingPathComponent("SavedGames")
        do {
            try fileManager.createDirectory(atPath: saveURL.path,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch let error as NSError {
            fatalError(
                "Failed to create directory: \(error.debugDescription)")
        }

        let fileURL = saveURL.appendingPathComponent("level\(level.levelNum)")
        print("* Saving: \(fileURL.path)")
        NSKeyedArchiver.archiveRootObject(self, toFile: fileURL.path)
    }
    
    // Load a saved level from the user's device
    class func loadLevel(num: Int) -> SKScene? {
        print("* loading game")
        var scene: SKScene?
        let fileManager = FileManager.default
        guard let directory =
            fileManager.urls(for: .libraryDirectory,
                             in: .userDomainMask).first
            else { return nil }
        let url = directory.appendingPathComponent(
            "SavedGames/level\(num)")
        if FileManager.default.fileExists(atPath: url.path) {
            scene = NSKeyedUnarchiver.unarchiveObject(
                withFile: url.path) as? GameScene
            _ = try? fileManager.removeItem(at: url)
        }
        return scene
    }
    
}

//
//  TutorialScene.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 30/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
//
//  GameScene.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 16/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import SpriteKit
import GameplayKit

enum TutorialState: Int {
    case slideSeesaw = 0, tapJump, catchCat, wait, eatBread, end, fail
    
    var instruction: String {
        if rawValue == 0 {
            return "Swipe to move the seesaw"
        } else if rawValue == 1 {
            return "Tap to make the cat jump"
        } else if rawValue == 2 {
            return "Move the seesaw to catch the cat!"
        } else if rawValue == 3 {
            return "Time to eat some bread!"
        } else if rawValue == 4 {
            return ""
        } else if rawValue == 5 {
            return "Great! Now, let's go play the game!"
        } else {
            return "Opps! Don't let kitty fall!"
        }
    }
}

class TutorialScene: SKScene, SKPhysicsContactDelegate{
    
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
    var handNode: SKSpriteNode!
    var instructionLabel: SKLabelNode?
    var nextLabel: SKLabelNode?
    
    //Game State
    var score = 0
    var gameState: GameState = .initial
    var tutorialState: TutorialState = .slideSeesaw {
        didSet {
            instructionLabel?.text = tutorialState.instruction
        }
    }
    
    override func didMove(to view: SKView) {
        setUpScene(view: view)
        
        //view.showsPhysics = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactToTouches(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactToTouches(touches: touches)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if tutorialState == .slideSeesaw || tutorialState == .wait || tutorialState == .fail || tutorialState == .tapJump {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask
            | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.Bread {
            eatBread(contact: contact, catNode: leftCatNode)
            tutorialState = .end
            perform(#selector(transitionToLevelSelect), with: nil, afterDelay: 3)
        }
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.LeftWood {
            if tutorialState == .catchCat {
                tutorialState = .wait
                addBreadSprites()
                fixCat(catSeatSide: .left)
                seesawNode?.zRotation = 0
                seesawNode?.physicsBody?.isDynamic = false
                let moveToCenter = SKAction.moveTo(x: 900, duration: 0.5)
                seesawNode?.run(moveToCenter)
            } else {
                fixCat(catSeatSide: .left)
            }
        }
        
        if collision == PhysicsCategory.RightCat | PhysicsCategory.RightWood {
            fixCat(catSeatSide: .right)
            releaseCat(catNode: leftCatNode)
        }
        
        if collision == PhysicsCategory.LeftCat | PhysicsCategory.Floor {
            print("Cat fell!")
            leftCatNode.angryAnimation()
            tutorialState = .fail
            perform(#selector(transitionToScene), with: nil, afterDelay: 3)
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    //MARK: - Encode/Decoder
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


//MARK: - Game Helper Functions

extension TutorialScene {
    
    //Mark: - Game State Manegement Helper
    // Handles transitioning to a new game scene
    func transitionToScene(level: Int) {
        print("Transitionaing to new scene")
        guard let newScene = SKScene(fileNamed: "TutorialScene1")
            as? TutorialScene else {
                fatalError("Level: \(level) not found")
        }
        newScene.scaleMode = .aspectFill
        newScene.level = Level(num: 1)
        newScene.tutorialState = .tapJump
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
    
    func addBreadSprites() {
        let size = CGSize(width: TileWidth, height: TileHeight)
        let sprite = BreadNode(size: size, breadType: .chocoDonut)
        sprite.position = CGPoint(x: 768, y: 830)
        sprite.zPosition = 10
        self.scene?.addChild(sprite)
        
        let sprite2 = BreadNode(size: size, breadType: .strawberryHeartCookie)
        sprite2.position = CGPoint(x: 768, y: 720)
        sprite2.zPosition = 10
        self.scene?.addChild(sprite2)
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
        
        if tutorialState == .slideSeesaw {
            handNode = SKSpriteNode(imageNamed: "hand")
            handNode.zPosition = 50
            handNode.position = CGPoint(x: 685, y: 590)
            addChild(handNode)
            
            let swipeAction = SKAction.move(by: CGVector(dx: 400, dy: 0), duration: 1.2)
            let waitAction = SKAction.wait(forDuration: 0.7)
            let swipeBack = SKAction.move(by: CGVector(dx: -400, dy: 0), duration: 0.1)
            
            let swipeSequence = SKAction.sequence([swipeAction, waitAction, swipeBack])
            handNode.run(SKAction.repeatForever(swipeSequence))
        } else {
            fixCat(catSeatSide: .left)
            fixCat(catSeatSide: .right)
        }

        instructionLabel = childNode(withName: "instructionLabel") as? SKLabelNode
        instructionLabel?.text = tutorialState.instruction
        nextLabel = childNode(withName: "nextLabel") as? SKLabelNode
        nextLabel?.alpha = 0
    
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
        
        if let touchedNode =
            atPoint(touch.location(in: self)) as? SKLabelNode {
            if touchedNode.name == "nextLabel" {
                let currentStateValue = tutorialState.rawValue
                let nextState = TutorialState.init(rawValue: currentStateValue + 1)
                if nextState != nil {
                    tutorialState = nextState!
                    nextLabel?.removeFromParent()
                }
                return
            }
        }
        
        switch tutorialState {
            
        case .slideSeesaw:
            handNode.removeFromParent()
            nextLabel?.alpha = 1
            seesawNode?.physicsBody?.isDynamic = false
            fixCat(catSeatSide: .left)
            fixCat(catSeatSide: .right)
            seesawNode?.moveWithinBounds(targetLocation: touchLocation.x, leftBound: seesawLeftBound,
                                         rightBound: seesawRightBound)
        case .tapJump:
            seesawNode?.physicsBody?.isDynamic = true
            releaseCat(catNode: leftCatNode)
            tutorialState = .catchCat
            
        case .catchCat:
            seesawNode?.moveWithinBounds(targetLocation: touchLocation.x, leftBound: seesawLeftBound,
                                         rightBound: seesawRightBound)
        case .eatBread:
            seesawNode?.moveWithinBounds(targetLocation: touchLocation.x, leftBound: seesawLeftBound,
                                         rightBound: seesawRightBound)
        case .wait:
            tutorialState = .eatBread
            seesawNode?.physicsBody?.isDynamic = true
            releaseCat(catNode: leftCatNode)
            return
            
        default:
            return
        
        }
    }
}

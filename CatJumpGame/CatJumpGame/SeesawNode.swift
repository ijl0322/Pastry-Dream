//
//  SeesawNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 17/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import SpriteKit
class SeesawNode: SKSpriteNode {
    private var leftContactPointNode = SKSpriteNode()
    private var rightContactPointNode = SKSpriteNode()
    var leftCatJoint: SKPhysicsJointFixed?
    var rightCatJoint: SKPhysicsJointFixed?
    
    var leftCatFixed: Bool {
        return leftCatJoint != nil
    }
    var rightCatFixed: Bool {
        return rightCatJoint != nil
    }
    
    init() {
        let texture = SKTexture(imageNamed: "seesaw")
        let size = CGSize(width: 600, height: 105)
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.position = CGPoint(x: 768, y: 152.5)
        self.zPosition = 1
        self.name = "seesaw"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
    
    func didMoveToScene() {
        print("seesaw added to scene")
        
        guard let scene = scene else {
            return
        }
        
        // Set up physics body for the seesaw
        
        let seesawBodyTexture = SKTexture(imageNamed: "seesaw_physics")
        physicsBody = SKPhysicsBody(texture: seesawBodyTexture,
                                    size: seesawBodyTexture.size())
        physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        physicsBody?.collisionBitMask = PhysicsCategory.LeftCat | PhysicsCategory.RightCat | PhysicsCategory.Obstacle | PhysicsCategory.Floor
        physicsBody?.contactTestBitMask = 0
        
        
        // Add contact points for left cat and right cat
        
        leftContactPointNode.size = CGSize(width: 30, height: 10)
        leftContactPointNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leftContactPointNode.position = CGPoint(x: -self.frame.size.width/4, y: self.frame.size.height/2)
        leftContactPointNode.physicsBody = SKPhysicsBody(rectangleOf: leftContactPointNode.frame.size)
        
        leftContactPointNode.physicsBody?.categoryBitMask = PhysicsCategory.LeftWood
        leftContactPointNode.physicsBody?.collisionBitMask = 0
        self.addChild(leftContactPointNode)
        
        rightContactPointNode.size = CGSize(width: 30, height: 10)
        rightContactPointNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightContactPointNode.position = CGPoint(x: self.frame.size.width/4, y: self.frame.size.height/2)
        rightContactPointNode.physicsBody = SKPhysicsBody(rectangleOf: rightContactPointNode.frame.size)
        
        rightContactPointNode.physicsBody?.categoryBitMask = PhysicsCategory.RightWood
        rightContactPointNode.physicsBody?.collisionBitMask = 0
        self.addChild(rightContactPointNode)
        
        // Fix the contact point to the seesaw
        
        let leftEdgeJoint = SKPhysicsJointFixed.joint(withBodyA: physicsBody!, bodyB: leftContactPointNode.physicsBody!, anchor: self.position)
        scene.physicsWorld.add(leftEdgeJoint)
        
        let rightEdgeJoint = SKPhysicsJointFixed.joint(withBodyA: physicsBody!, bodyB: rightContactPointNode.physicsBody!, anchor: self.position)
        scene.physicsWorld.add(rightEdgeJoint)
        
        let moveConstaint = SKConstraint.positionY(SKRange(value: self.frame.size.height/2 + 100,
                                                           variance: 0))
        let rotationConstraint = SKConstraint.zRotation(
            SKRange(lowerLimit: -30.toRadians(), upperLimit: 30.toRadians()))
        
        self.constraints = [moveConstaint, rotationConstraint]
    }
    
    func fixCat(catNode: CatSpriteNode) {
        guard let scene = scene else {
            return
        }
        
        if catNode.seatSide == .left {
            if !leftCatFixed{
                catNode.zRotation = 0
                self.zRotation = 0
                leftCatJoint = SKPhysicsJointFixed.joint(withBodyA: physicsBody!, bodyB: (catNode.physicsBody)!, anchor: self.position)
                scene.physicsWorld.add(leftCatJoint!)
            }
        } else {
            if !rightCatFixed{
                catNode.zRotation = 0
                self.zRotation = 0
                rightCatJoint = SKPhysicsJointFixed.joint(withBodyA: physicsBody!, bodyB: (catNode.physicsBody)!, anchor: self.position)
                scene.physicsWorld.add(rightCatJoint!)
            }
        }
    }
    
    func moveWithinBounds(targetLocation: CGFloat, leftBound: CGFloat, rightBound: CGFloat) {
        if targetLocation > leftBound && targetLocation < rightBound {
            run(SKAction.moveTo(x: targetLocation, duration: 0.7), withKey: "seesaw-move")
        }
        else if targetLocation < leftBound {
            run(SKAction.moveTo(x: leftBound, duration: 0.7), withKey: "seesaw-move")
        }
        else if targetLocation > rightBound {
            run(SKAction.moveTo(x: rightBound, duration: 0.7), withKey: "seesaw-move")
        }
    }
    
    func stopMovement(){
        removeAction(forKey: "seesaw-move")
        physicsBody?.isDynamic = false
    }
    
    func catInTheAir() -> SeatSide {
        if !leftCatFixed {
            return .left
        } else if !rightCatFixed {
            return .right
        } else {
            return .both
        }
    }
    
    func releaseCat(catSide: SeatSide) {
        
        switch catSide {
        case .left:
            if leftCatFixed {
                scene!.physicsWorld.remove(leftCatJoint!)
                leftCatJoint = nil
            }
            return
        case .right:
            if rightCatFixed {
                scene!.physicsWorld.remove(rightCatJoint!)
                rightCatJoint = nil
            }
            return
        default:
            return
        }
    }
}

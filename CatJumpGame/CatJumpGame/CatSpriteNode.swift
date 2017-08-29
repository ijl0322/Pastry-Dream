//
//  CatSpriteNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 22/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

enum SeatSide: Int {
    case left = 0, right, both
    
    init?(raw: Int) {
        self.init(rawValue: raw)
    }
    
    var physicsBody: SKTexture {
        return SKTexture(imageNamed: "cat_physicsBody")
    }
}

enum CatType: Int, CustomStringConvertible {
    case unknown = 0, cat1, cat2
    
    init?(raw: Int) {
        self.init(rawValue: raw)
    }
    
    var spriteName: String {
        let spriteNames = ["unknown","cat1", "cat2"]
        return spriteNames[rawValue]
    }
    
    var body: String {
        return "\(spriteName)_body"
    }
    
    var head: String {
        return "\(spriteName)_head"
    }
    
    var eyes: String {
        return "\(spriteName)_blink1"
    }
    
    var mouth: String {
        return "\(spriteName)_smile"
    }
    
    var feet: String {
        return "\(spriteName)_feet"
    }
    
    var tail: String {
        return "\(spriteName)_tail"
    }
    
    var sadMouth: String {
        return "\(spriteName)_sadMouth"
    }
    
    var blink: [SKTexture] {
        var textures:[SKTexture] = []
        for i in 1...3 {
            textures.append(SKTexture(imageNamed: "\(spriteName)_blink\(i)"))
        }
        textures.append(SKTexture(imageNamed: "\(spriteName)_blink\(1)"))
        return textures
    }
    
    var angryMark: [SKTexture] {
        var texture: [SKTexture] = []
        for i in 1...2 {
            texture.append(SKTexture(imageNamed: "\(spriteName)_angryMark\(i)"))
        }
        texture.append(SKTexture(imageNamed: "\(spriteName)_angryMark\(1)"))
        return texture
    }
    
    var angryEyes: [SKTexture] {
        var textures:[SKTexture] = []
        for i in 1...2 {
            textures.append(SKTexture(imageNamed: "\(spriteName)_sadEyes\(i)"))
        }
        return textures
    }
    
    var openMouth: [SKTexture] {
        let textureNames = ["\(spriteName)_mouthOpen", "\(spriteName)_smile"]
        var texture:[SKTexture] = []
        for image in textureNames {
            texture.append(SKTexture(imageNamed: image))
        }
        return texture
    }
    
    var description: String {
        return spriteName
    }
}


import SpriteKit
class CatSpriteNode: SKSpriteNode {
    var isPinned = false
    var catType: CatType!
    var seatSide: SeatSide!
    var canJump = true
    
    // Nodes
    var bodyNode: SKSpriteNode!
    var headNode: SKSpriteNode!
    var eyesNode: SKSpriteNode!
    var mouthNode: SKSpriteNode!
    var feetNode: SKSpriteNode!
    var tailNode: SKSpriteNode!
    

    // MARK: - Initialization
    
    init(catType: CatType, isLeftCat: Bool) {
        let size = CGSize(width: 330, height: 330)
        self.catType = catType
        
        super.init(texture: nil, color: UIColor.clear, size: size)
        bodyNode = SKSpriteNode(imageNamed: catType.body)
        bodyNode.position = CGPoint(x: 0, y: -80)
        bodyNode.name = "body"
        self.addChild(bodyNode)
        
        headNode = SKSpriteNode(imageNamed: catType.head)
        headNode.position = CGPoint(x: 10.8, y: 136.5)
        headNode.zPosition = 1
        headNode.name = "head"
        bodyNode.addChild(headNode)
        
        eyesNode = SKSpriteNode(imageNamed: catType.eyes)
        eyesNode.position = CGPoint(x: -3, y: -17)
        eyesNode.zPosition = 2
        eyesNode.name = "eyes"
        headNode.addChild(eyesNode)
        
        mouthNode = SKSpriteNode(imageNamed: catType.mouth)
        mouthNode.position = CGPoint(x: -1.9, y: -63.5)
        mouthNode.zPosition = 2
        mouthNode.name = "mouth"
        headNode.addChild(mouthNode)
        
        feetNode = SKSpriteNode(imageNamed: catType.feet)
        feetNode.position = CGPoint(x: 0, y: -40)
        feetNode.zPosition = 2
        feetNode.name  = "feet"
        bodyNode.addChild(feetNode)
        
        tailNode = SKSpriteNode(imageNamed: catType.tail)
        tailNode.position = CGPoint(x: -50, y: -45.5)
        tailNode.zPosition = -1
        tailNode.anchorPoint = CGPoint(x: 1, y: 0)
        tailNode.name = "tail"
        bodyNode.addChild(tailNode)
        
        if isLeftCat {
            seatSide = .left
            name = "leftCat"
        } else {
            seatSide = .right
            name = "rightCat"
        }
        
        didMoveToScene()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isPinned = aDecoder.decodeBool(forKey: "Cat.isPinned")
        canJump = aDecoder.decodeBool(forKey: "Cat.canJump")
        catType = CatType.init(raw: aDecoder.decodeInteger(forKey: "Cat.catType"))
        seatSide = SeatSide.init(raw: aDecoder.decodeInteger(forKey: "Cat.seatSide"))
        
        bodyNode = childNode(withName: "body") as! SKSpriteNode
        headNode = childNode(withName: "//head") as! SKSpriteNode
        eyesNode = childNode(withName: "//eyes") as! SKSpriteNode
        mouthNode = childNode(withName: "//mouth") as! SKSpriteNode
        feetNode = childNode(withName: "//feet") as! SKSpriteNode
        tailNode = childNode(withName: "//tail") as! SKSpriteNode
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(isPinned, forKey: "Cat.isPinned")
        aCoder.encode(canJump, forKey: "Cat.canJump")
        aCoder.encode(catType.rawValue,
                      forKey: "Cat.catType")
        aCoder.encode(seatSide.rawValue,
                      forKey: "Cat.seatSide")
        super.encode(with: aCoder)
    }
    
    func didMoveToScene() {
        print("new cat added to scene")
        
        setPhysicsBody()
        normalStateAnimation()
    }
    
    func setPhysicsBody() {
        
        let catBodyTexture = seatSide.physicsBody
        physicsBody = SKPhysicsBody(texture: catBodyTexture,
                                    size: catBodyTexture.size())
        
        physicsBody?.collisionBitMask = PhysicsCategory.Edge | PhysicsCategory.Obstacle | PhysicsCategory.Floor | PhysicsCategory.RightCat | PhysicsCategory.LeftCat
        
        if seatSide == .left {
            physicsBody?.categoryBitMask = PhysicsCategory.LeftCat
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.LeftWood | PhysicsCategory.RightCat | PhysicsCategory.Floor
        } else {
            physicsBody?.categoryBitMask = PhysicsCategory.RightCat
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.RightWood | PhysicsCategory.LeftCat | PhysicsCategory.Floor
            self.xScale = -1
        }
        
        physicsBody?.friction  = 0
        
        let rotationConstraint = SKConstraint.zRotation(
            SKRange(lowerLimit: -30.toRadians(), upperLimit: 30.toRadians()))
        self.constraints = [rotationConstraint]
    }
    
    //MARK: - Actions
    
    func jump() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5000))
    }
    
    func bounceOff() {
        if seatSide == .left {
            physicsBody?.applyImpulse(CGVector(dx: -400, dy: 200))
        } else {
            physicsBody?.applyImpulse(CGVector(dx: 400, dy: 200))
        }
    }
    
    func dropSlightly() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: -300))
    }
    
    func enableSeesawContact() {
        if seatSide == .left {
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.LeftWood | PhysicsCategory.RightCat | PhysicsCategory.Floor
        } else {
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.RightWood | PhysicsCategory.LeftCat | PhysicsCategory.Floor
        }
    }
    
    func disableSeesawContact() {
        if seatSide == .left {
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.RightCat | PhysicsCategory.Floor
        } else {
            physicsBody?.contactTestBitMask = PhysicsCategory.Bread | PhysicsCategory.LeftCat | PhysicsCategory.Floor
        }
    }
    
    //MARK: - Animations
    
    func angryAnimation() {
        
        // Angry Mark
        let angryMark = SKSpriteNode(texture: self.catType.angryMark[0])
        angryMark.position = CGPoint(x: -58, y: 34)
        angryMark.zPosition = 3
        headNode.addChild(angryMark)
        
        let angryTextures = self.catType.angryMark
        let angryAnimation = SKAction.animate(with: angryTextures, timePerFrame: 0.2)
        let waitAnimation = SKAction.wait(forDuration: 0.3)
        let fullAnimation = SKAction.sequence([angryAnimation, angryAnimation, waitAnimation])
        angryMark.run(SKAction.repeatForever(fullAnimation), withKey: "angry-mark")
        
        // Eyes
        let textures = self.catType.angryEyes
        let eyesAnimation = SKAction.animate(with: textures,
                                              timePerFrame: 0.7)
        let eyesWaitAnimation = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([eyesAnimation, eyesAnimation, eyesWaitAnimation])
        eyesNode.run(SKAction.repeatForever(sequence), withKey: "eyes")
        
        // Mouth
        let sadMouthTexture = SKTexture(imageNamed: self.catType.sadMouth)
        mouthNode.texture = sadMouthTexture
    }
    
    func eatBreadAnimation() {
        // Open Mouth
        let mouthTextures = self.catType.openMouth
        let openMouthAnimation = SKAction.animate(with: mouthTextures, timePerFrame: 0.2)
        mouthNode.run(openMouthAnimation)
    }
    
    func normalStateAnimation() {
        
        // Eyes
        
        let textures = self.catType.blink
        let blinkAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        let waitAnimation = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([blinkAnimation, blinkAnimation, waitAnimation])
        eyesNode.run(SKAction.repeatForever(sequence), withKey: "eyes")
        
        
        // Tail
        
        let tailWaitAnimation = SKAction.wait(forDuration: 2)
        let tailRotationAnimation = SKAction.rotate(byAngle: 7.toRadians(), duration: 1.5)
        let tailRotationReversed = tailRotationAnimation.reversed()
        let fullTailAnimation = SKAction.sequence([tailWaitAnimation, tailRotationAnimation,
                                                   tailRotationReversed])
        tailNode.run(SKAction.repeatForever(fullTailAnimation), withKey: "normal-tail")
        
        
        // Mouth
        
        let mouthWaitAnimation = SKAction.wait(forDuration: 1.5)
        let mouthMoveAnimation = SKAction.moveBy(x: 0, y: -3, duration: 0.2)
        let mouthMoveReversed = mouthMoveAnimation.reversed()
        
        let fullMouthAnimation = SKAction.sequence([mouthWaitAnimation, mouthMoveAnimation,
                                                    mouthMoveReversed, mouthWaitAnimation])
        mouthNode.run(SKAction.repeatForever(fullMouthAnimation), withKey: "normal-mouth")
        
        // Body
        
        let bodyBounceAnimation = SKAction.moveBy(x: 0, y: 5, duration: 0.5)
        let bodyBounceReversed = bodyBounceAnimation.reversed()
        let fullBodyAnimation = SKAction.sequence([bodyBounceAnimation, bodyBounceReversed])
        
        bodyNode.run(SKAction.repeatForever(fullBodyAnimation), withKey: "normal-body")
        
        // Feet
        let feetBounceAnimation = SKAction.moveBy(x: 0, y: -5, duration: 0.5)
        let feetBounceReversed = feetBounceAnimation.reversed()
        let fullfeetAnimation = SKAction.sequence([feetBounceAnimation, feetBounceReversed])
        
        feetNode.run(SKAction.repeatForever(fullfeetAnimation), withKey: "normal-feet")
    }
}

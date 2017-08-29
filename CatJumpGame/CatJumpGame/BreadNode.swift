//
//  BreadNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 18/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import SpriteKit
class BreadNode: SKSpriteNode {
    var notAte = true
    var points = 10
    
    init(size: CGSize, breadType: BreadType) {
        let texture = SKTexture(imageNamed: breadType.spriteName)
        super.init(texture: texture, color: UIColor.clear, size: size)
        points = breadType.points
        didMoveToScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        points = aDecoder.decodeInteger(forKey: "Bread.points")
        notAte = aDecoder.decodeBool(forKey: "Bread.notAte")
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(notAte, forKey: "Bread.notAte")
        aCoder.encode(points, forKey: "Bread.points")
    }
    
    func didMoveToScene() {
        print("bread added to scene")

        let size = CGSize(width: self.frame.size.width/2, height: self.frame.size.height/2)
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Bread
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.LeftCat | PhysicsCategory.RightCat
        
        let randomTime = CGFloat.random(min: 0.1, max: 0.5)
        let leftWiggle = SKAction.rotate(byAngle: 10.toRadians(), duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let pause = SKAction.wait(forDuration: TimeInterval(randomTime))
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle, pause])
        let wiggleForever = SKAction.repeatForever(fullWiggle)
        self.run(wiggleForever, withKey: "wiggle")
        
        self.name = "bread"
    }
    
    func remove() -> Int{
        if notAte {
            print("Ate bread")
            print("Got points: \(points)")
            notAte = false
            //SKAction.playSoundFileNamed("tink.mp3",waitForCompletion: false),
            run(SKAction.sequence([
                SKAction.scale(to: 0.8, duration: 0.3),
                SKAction.removeFromParent()
            ]))
            return points
        }
        return 0
    }
}


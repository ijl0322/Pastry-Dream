//
//  LevelButtonNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 27/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//


import SpriteKit
class LevelButtonNode: SKSpriteNode {
    
    let darkRed = UIColor(red: 188/255, green: 7/255, blue: 1/255, alpha: 1)
    
    var level = 0 {
        didSet {
            print("Changing level number for level button \(level)")
        }
    }
    var starsNode: SKSpriteNode?
    var levelNumNode: MKOutlinedLabelNode?
    var levelCompleteType = LevelCompleteType.locked
    
    init(level: Int, levelCompleteType: LevelCompleteType) {
        let texture = SKTexture(imageNamed: levelCompleteType.baseButtonImageName)
        let size = CGSize(width: 150, height: 150)
        self.level = level
        self.levelCompleteType = levelCompleteType
        super.init(texture: texture, color: UIColor.clear, size: size)
        
        self.name = "level"
        
        if levelCompleteType != .locked {
            
            
            levelNumNode = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 96)
            levelNumNode?.borderColor = darkRed
            levelNumNode?.borderWidth = 10
            levelNumNode?.borderOffset = CGPoint(x: -3, y: -3)
            levelNumNode?.fontColor = UIColor.white
            levelNumNode?.outlinedText = "\(level)"
            levelNumNode?.zPosition = 10
            levelNumNode?.position = CGPoint(x: 0,y: -30)
            levelNumNode?.name = "levelNum"
            addChild(levelNumNode!)
            
            starsNode = SKSpriteNode(imageNamed: levelCompleteType.imageName)
            starsNode?.position = CGPoint(x: 0, y: -56.5)
            starsNode?.zPosition = 1
            addChild(starsNode!)
            
            let levelTouchSensorNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSize(width: 150, height: 150))
            levelTouchSensorNode.position = CGPoint(x: 0, y: 0)
            levelTouchSensorNode.zPosition = 100
            levelTouchSensorNode.name = "levelButton"
            addChild(levelTouchSensorNode)
        }
    }
    
    func animateButton() {
        let scaleAction = SKAction.scale(by: 1.3, duration: 0.3)
        run(SKAction.sequence([scaleAction, scaleAction.reversed()]))
    }
    
    func unlock() {
        if levelCompleteType == .locked {
            levelCompleteType = .lose
            self.texture = SKTexture(imageNamed: levelCompleteType.baseButtonImageName)
            levelNumNode = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 96)
            levelNumNode?.borderColor = darkRed
            levelNumNode?.borderWidth = 10
            levelNumNode?.borderOffset = CGPoint(x: -3, y: -3)
            levelNumNode?.fontColor = UIColor.white
            levelNumNode?.outlinedText = "\(level)"
            levelNumNode?.zPosition = 10
            levelNumNode?.position = CGPoint(x: 0,y: -30)
            addChild(levelNumNode!)
            
            starsNode = SKSpriteNode(imageNamed: levelCompleteType.imageName)
            starsNode?.position = CGPoint(x: 0, y: -56.5)
            starsNode?.zPosition = 1
            addChild(starsNode!)
            
            let scaleAction = SKAction.scale(by: 1.3, duration: 0.3)
            run(SKAction.sequence([scaleAction, scaleAction.reversed()]))
        }
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
    }
}

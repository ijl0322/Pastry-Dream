//
//  GamePausedNotificationNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 26/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import SpriteKit
class GamePausedNotificationNode: SKSpriteNode {
    
    var yesButton: SKSpriteNode!
    var noButton: SKSpriteNode!

    init() {
        let texture = SKTexture(imageNamed: "pausedNotice")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 910, height: 800))
        self.position = CGPoint(x: 768, y: 1200)
        self.name = "pauseNotice"
        addButtons()
        didMoveToScene()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
    func addButtons() {
        yesButton = SKSpriteNode(imageNamed: ButtonName.yes)
        yesButton.position = CGPoint(x: -280, y: -340)
        yesButton.zPosition = 1
        yesButton.name = ButtonName.yes
        
        addChild(yesButton)
        
        noButton = SKSpriteNode(imageNamed: ButtonName.no)
        noButton.position = CGPoint(x: 280, y: -340)
        noButton.zPosition = 1
        noButton.name = ButtonName.no
        addChild(noButton)
    }
    
    func didMoveToScene() {
        
    }
}


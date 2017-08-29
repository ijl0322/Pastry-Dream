//
//  LeaderBoardNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 29/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import SpriteKit
class LeaderBoardNode: SKSpriteNode {
    
    var scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var timeLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var coinsLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var levelsButton: SKSpriteNode!
    var replayButton: SKSpriteNode!
    var nextButton: SKSpriteNode!
    var leaderBoardButton: SKSpriteNode!
    var levelStatus: LevelCompleteType = .lose
    var level = 0
    let darkRed = UIColor(red: 188/255, green: 7/255, blue: 1/255, alpha: 1)
    let scoreData: [[String:Any]] = []
    
    init(level: Int, levelStatus: LevelCompleteType) {
        let texture = SKTexture(imageNamed: "highScoreNotification")
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 910, height: 1270))
        self.position = CGPoint(x: 768, y: 1200)
        self.name = "leaderBoard"
        self.zPosition = 100
        
        self.level = level
        self.levelStatus = levelStatus
        
        let noResultLabel = SKLabelNode(fontNamed: "BradyBunchRemastered")
        noResultLabel.fontColor = self.darkRed
        noResultLabel.text = "No high score yet!"
        noResultLabel.horizontalAlignmentMode = .left
        noResultLabel.fontSize = 75
        noResultLabel.zPosition = 1
        noResultLabel.position = CGPoint(x: -300, y: 275)
        self.addChild(noResultLabel)

        LeaderBoardManager.sharedInstance.highScoreForLevel(level, completion: { (scoreData) in
            guard let scoreData = scoreData else{
                print("no data")
                return
            }
            self.addBlocks(result: scoreData)
        })
        addButtons()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBlocks(result: [[String:Any]]) {
        for i in 0..<result.count {
            let nameBlock = SKSpriteNode(imageNamed: "leaderBoardNameBlock")
            nameBlock.position = CGPoint(x: 0, y: 260 - 190 * i)
            nameBlock.zPosition = 5
            addChild(nameBlock)
            
            let nameLabel = SKLabelNode(fontNamed: "BradyBunchRemastered")
            nameLabel.fontColor = darkRed
            nameLabel.text = result[i]["nickname"] as? String
            nameLabel.horizontalAlignmentMode = .left
            nameLabel.fontSize = 75
            nameLabel.zPosition = 20
            nameLabel.position = CGPoint(x: -300, y: 275 - 190 * i)
            addChild(nameLabel)
            
            
            let scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 120)
            scoreLabel.borderWidth = 10
            scoreLabel.borderOffset = CGPoint(x: -3, y: -3)
            scoreLabel.borderColor = UIColor.red
            scoreLabel.fontColor = UIColor.white
            scoreLabel.outlinedText = "\(result[i]["score"] ?? 0)"
            scoreLabel.zPosition = 15
            scoreLabel.position = CGPoint(x: 180, y: 202 - 190*i)
            addChild(scoreLabel)
        }
    }
    
    func addButtons() {
        levelsButton = SKSpriteNode(imageNamed: ButtonName.levels)
        levelsButton.position = CGPoint(x: -310, y: -534)
        levelsButton.zPosition = 30
        levelsButton.name = ButtonName.levels
        
        addChild(levelsButton)
        
        replayButton = SKSpriteNode(imageNamed: ButtonName.replay)
        replayButton.position = CGPoint(x: -105, y: -534)
        replayButton.zPosition = 30
        replayButton.name = ButtonName.replay
        addChild(replayButton)
        
        if (levelStatus == .lose && level >= UserData.shared.unlockedLevels) || level >= AllLevels.shared.numberOfLevels {
            nextButton = SKSpriteNode(imageNamed: ButtonName.noNext)
            nextButton.position = CGPoint(x: 105, y: -534)
            nextButton.zPosition = 30
            nextButton.name = ButtonName.noNext
            addChild(nextButton)
        } else {
            nextButton = SKSpriteNode(imageNamed: ButtonName.next)
            nextButton.position = CGPoint(x: 105, y: -534)
            nextButton.zPosition = 30
            nextButton.name = ButtonName.next
            addChild(nextButton)
        }
        
        leaderBoardButton = SKSpriteNode(imageNamed: ButtonName.leaderBoard)
        leaderBoardButton.position = CGPoint(x: 310, y: -534)
        leaderBoardButton.zPosition = 30
        leaderBoardButton.name = ButtonName.leaderBoard
        addChild(leaderBoardButton)
    }
    

    
    func addScoreLabel(score: Int) {
        scoreLabel.borderWidth = 10
        scoreLabel.borderOffset = CGPoint(x: -3, y: -3)
        scoreLabel.borderColor = UIColor.red
        scoreLabel.fontColor = UIColor.white
        scoreLabel.outlinedText = "\(score)"
        scoreLabel.zPosition = 15
        scoreLabel.position = CGPoint(x: 143, y: -327)
        addChild(scoreLabel)
    }
    
    func addTimeLabel(time: Int) {
        let formattedTime = time.secondsToFormatedString()
        timeLabel.borderWidth = 10
        timeLabel.borderOffset = CGPoint(x: -3, y: -3)
        timeLabel.borderColor = UIColor.red
        timeLabel.fontColor = UIColor.white
        timeLabel.outlinedText = formattedTime
        timeLabel.zPosition = 15
        timeLabel.position = CGPoint(x: 208, y: -140)
        addChild(timeLabel)
    }
    
    func addCoinsLabel(coins: Int) {
        coinsLabel.borderWidth = 10
        coinsLabel.borderOffset = CGPoint(x: -3, y: -3)
        coinsLabel.borderColor = UIColor.red
        coinsLabel.fontColor = UIColor.white
        coinsLabel.outlinedText = "\(coins)"
        coinsLabel.zPosition = 15
        coinsLabel.position = CGPoint(x: 188, y: 42)
        addChild(coinsLabel)
    }
    
}

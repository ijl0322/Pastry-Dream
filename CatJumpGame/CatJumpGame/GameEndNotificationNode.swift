//
//  GameEndNotificationNode.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 25/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

enum ButtonName {
    static let home = "homeButton"
    static let next = "nextButton"
    static let leaderBoard = "leaderBoardButton"
    static let levels = "levelsButton"
    static let replay = "replayButton"
    static let no = "noButton"
    static let yes = "yesButton"
    static let noNext = "noNextButton"
    static let ok = "okButton"
}

import SpriteKit
class GameEndNotificationNode: SKSpriteNode {
    
    var scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var timeLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var coinsLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
    var star1: SKSpriteNode!
    var star2: SKSpriteNode!
    var star3: SKSpriteNode!
    var levelsButton: SKSpriteNode!
    var replayButton: SKSpriteNode!
    var nextButton: SKSpriteNode!
    var leaderBoardButton: SKSpriteNode!
    var score = 0
    var level = 0
    var levelStatus: LevelCompleteType = .lose
    
    
    init(score: Int, levelStatus: LevelCompleteType, time: Int, level: Int) {
        var texture = SKTexture(imageNamed: "levelComplete")
        if levelStatus == .lose {
            texture = SKTexture(imageNamed: "levelFailed")
        }
        
        self.levelStatus = levelStatus
        self.score = score
        self.level = level
        
        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 910, height: 1270))
        self.name = "gameEndNotification"
        self.position = CGPoint(x: 768, y: 1200)
        addCoinsLabel(coins: levelStatus.coins)
        addScoreLabel(score: score)
        addTimeLabel(time: time)
        addGreyStars()
        addButtons()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func animateStarsReceived() {
        switch levelStatus {
        case .oneStar:
            animate(star: star1, delay: 0.1)
            return
        case .twoStar:
            animate(star: star1, delay: 0.1)
            animate(star: star2, delay: 0.9)
        case .threeStar:
            animate(star: star1, delay: 0.1)
            animate(star: star2, delay: 0.9)
            animate(star: star3, delay: 1.7)
        default:
            return
        }
    }
    
    func animate(star: SKSpriteNode, delay: Double) {
        let yellowStar = SKTexture(imageNamed: "star_yellow")
        let wait = SKAction.wait(forDuration: delay)
        let changeColor = SKAction.animate(with: [yellowStar], timePerFrame: 0.2, resize: false, restore: false)
        let enlarge = SKAction.scale(by: 1.3, duration: 0.3)
        let shrink = enlarge.reversed()
        let starAnimation = SKAction.sequence([wait, changeColor, enlarge, shrink])
        star.run(starAnimation)
    }
    
    func animateBonus(time: Int) -> Int{
        if levelStatus != .threeStar {
            return 0
        }
        
        let bonus = SKLabelNode(fontNamed: "BradyBunchRemastered")
        bonus.text = "+\(time*10)"
        bonus.fontColor = SKColor.red
        bonus.fontSize = 144
        bonus.zPosition = 30
        bonus.position = CGPoint(x: 414, y: -57)
        bonus.setScale(0)
        addChild(bonus)
        
        let waitAction = SKAction.wait(forDuration: 2.4)
        let setScale = SKAction.scale(to: 1.0, duration: 0.1)
        let enlargeAction = SKAction.scale(by: 2, duration: 0.4)
        let shrinkAction = enlargeAction.reversed()
        bonus.run(SKAction.sequence([waitAction, setScale, enlargeAction, shrinkAction]), completion: { () -> Void in
            self.scoreLabel.removeFromParent()
            self.scoreLabel = MKOutlinedLabelNode(fontNamed: "BradyBunchRemastered", fontSize: 130)
            self.scoreLabel.borderWidth = 10
            self.scoreLabel.borderOffset = CGPoint(x: -3, y: -3)
            self.scoreLabel.borderColor = UIColor.red
            self.scoreLabel.fontColor = UIColor.white
            self.scoreLabel.outlinedText = "\(self.score + time * 10)"
            self.scoreLabel.zPosition = 15
            self.scoreLabel.position = CGPoint(x: 143, y: -327)
            self.addChild(self.scoreLabel)
        })
        
        return time * 10
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
    
    func addGreyStars() {
        star1 = SKSpriteNode(imageNamed: "star_grey")
        star2 = SKSpriteNode(imageNamed: "star_grey")
        star3 = SKSpriteNode(imageNamed: "star_grey")
        
        star1.position = CGPoint(x: -241, y: 294)
        star2.position = CGPoint(x: 0, y: 294)
        star3.position = CGPoint(x: 241, y: 294)
        
        star1.zPosition = 30
        star2.zPosition = 30
        star3.zPosition = 30
        
        addChild(star1)
        addChild(star2)
        addChild(star3)
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

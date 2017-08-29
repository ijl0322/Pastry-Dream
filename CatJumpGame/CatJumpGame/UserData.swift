//
//  UserData.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 27/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit

// A singleton that keeps track of the user's current game status
// Including the high scores/ levels status/ levels unlocked, 
// Save/Get data from user defaults, and also sends the status to firebase

class UserData {
    static let shared = UserData()
    let defaults = UserDefaults.standard
    var highScores = [0]
    var levelStatus: [LevelCompleteType] = [.lose]
    var nickName = "Anonymous"
    var coins = 0
    var unlockedLevels: Int {
        return highScores.count
    }
    
    init() {
        
        //If there are data saved in user defaults, initialize the singleton using values from user defaults
        if let nickName = defaults.object(forKey: "nickName") as? String {
            self.nickName = nickName
            print("Getting from user defaults")
        } else {
            defaults.set(nickName, forKey: "nickName")
        }
        
        if let highScores = defaults.array(forKey: "highScores") as? [Int] {
            self.highScores = highScores
        } else {
            defaults.set(highScores, forKey: "highScores")
        }
        
        if let levelStatusRaw = defaults.array(forKey: "levelStatus") as? [Int] {
            self.levelStatus = rawToLevelStatus(raw: levelStatusRaw)
        } else {
            defaults.set(levelStatusToRaw(), forKey: "levelStatus")
        }
        
        if let coins = defaults.integer(forKey: "coins") as Int?{
            self.coins = coins
        } else {
            defaults.set(coins, forKey: "coins")
        }
    }
        
//    func getDataFromFirebase() {
//        FirebaseManager.sharedInstance.getUserData(completion: { (snapshot) in
//            self.nickName = snapshot["nickName"] as! String
//            self.highScores = snapshot["highScores"] as! [Int]
//            print("User init from firebase")
//        })
//    }
    
    // The user can transfer their game data from different devices
    // This function transfers data from firebase to user's device
    func updateFromTransfer(snapshot: [String:Any]) {

        self.nickName = snapshot["nickName"] as! String
        self.highScores = snapshot["highScores"] as! [Int]
        let rawLevelStatus = snapshot["levelStatus"] as! [Int]
        
        self.levelStatus = self.rawToLevelStatus(raw: rawLevelStatus)
        self.coins = snapshot["coins"] as! Int
        self.defaults.set(self.nickName, forKey: "nickName")
        self.defaults.set(self.coins, forKey: "coins")
        self.defaults.set(self.highScores, forKey: "highScores")
        self.defaults.set(self.levelStatusToRaw(), forKey: "levelStatus")
    }
    

//    func highScoreForLevel(_ num: Int) -> Int? {
//        if num <= highScores.count {
//            return highScores[num - 1]
//        }
//        return nil
//    }
    
    
    // Changes the user's nickname and update to firebase
    func changeNickname(name: String) {
        nickName = name
        print("Changing nickname to \(nickName)")
        defaults.set(nickName, forKey: "nickName")
        saveToFirebase()
    }
    
    // LevelCompleteType is a enumeration that can be initialized from Int value
    // This converts the levelStatus array to and Int array
    func levelStatusToRaw() -> [Int]{
        let newLevelStatusArray = levelStatus.map({ (value: LevelCompleteType) -> Int in
            return value.rawValue
        })
        return newLevelStatusArray
    }
    
    // Converts an Int array to a LevelCompleteType array
    func rawToLevelStatus(raw: [Int]) -> [LevelCompleteType] {
        let newLevelStatus = raw.map({ (value: Int) -> LevelCompleteType in
            return LevelCompleteType.init(raw: value)!
        })
        return newLevelStatus
    }
    
    // Update the High Score for a certain level and updates user defaults and firebase's data
    func updateHighScoreForLevel(_ num: Int, score: Int, levelCompleteType: LevelCompleteType) {
        print("Updating user high score")

        if num <= highScores.count {
            if highScores[num - 1] < score {
                highScores[num - 1] = score
                levelStatus[num - 1] = levelCompleteType
                print("High Score for level \(num) is: \(highScores[num - 1])")
                saveToFirebase()
            }
        } else {
            highScores.append(score)
            print("High Score for level \(num) is: \(highScores[num - 1])")
            levelStatus[num - 1] = levelCompleteType
            saveToFirebase()
        }
        
        if levelCompleteType != .lose && num == highScores.count{
            print("unlocking a new level")
            highScores.append(0)
            levelStatus.append(.lose)
        }
        
        coins += levelCompleteType.coins
        print("The user now has \(coins) coins")
        
        defaults.set(coins, forKey: "coins")
        defaults.set(highScores, forKey: "highScores")
        defaults.set(levelStatusToRaw(), forKey: "levelStatus")
        
        saveToFirebase()
    }
    
    // Save the current user data to firebase
    func saveToFirebase() {
        let newLevelStatus = levelStatusToRaw()
        FirebaseManager.sharedInstance.updateUserData(data: ["nickName": nickName, "highScores": highScores, "levelStatus" : newLevelStatus, "coins": coins])
    }
    
}

//
//  Level.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 20/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation

let NumColumns = 8
let NumRows = 9

// An enumeration that denotes Level Completion Type.
enum LevelCompleteType: Int, CustomStringConvertible {
    case lose = 0, oneStar, twoStar, threeStar, locked
    
    init?(raw: Int) {
        self.init(rawValue: raw)
    }

    var description: String {
        let status = ["noStars", "oneStar", "twoStars", "threeStars", "locked"]
        
        return status[rawValue]
    }
    
    var imageName: String {
        return description
    }
    
    var baseButtonImageName: String {
        if rawValue == 4 {
            return "levelLockedButton"
        }
        return "levelBaseButton"
    }
    
    var coins: Int {
        let cointsReceived = [0, 1000, 1200, 1500, 0]
        return cointsReceived[rawValue]
    }
}

// A custom class that loads a level from JSOM file

class Level {
    
    fileprivate var breads = Array2D<Bread>(columns: NumColumns, rows: NumRows)
    fileprivate var tiles = Array2D<Int>(columns: NumColumns, rows: NumRows)
    
    var highestScore = 0
    var timeLimit = 0
    var levelNum = 0
    
    init(num: Int) {
        
        let filename = "Level_\(num)"
        levelNum = num
        
        // This will first load from user's document (which is downloaded from firebase)
        // If this level is not available, fall back to try loading it from the main bundle 
        // (which has 5 levels in case the user is not connected to the internet at all)
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromDocument(filename: filename) else { return }
 
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        guard let time = dictionary["timeLimit"] as? Int else {return}
        self.timeLimit = time
        
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            for (column, value) in rowArray.enumerated() {
                tiles[column, tileRow] = value
            }
        }
    }
    
    // Returns the bread at a location
    func breadAt(column: Int, row: Int) -> Bread? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return breads[column, row]
    }
    
    // Using the values in tiles array (which is number from 1 ... 13), 
    // the numbers can be used to initialize bread types
    // More Information of this type can be found in Bread.swift
    
    func loadBread() -> Set<Bread> {
        var set = Set<Bread>()
        highestScore = 0
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != 0{
                    let breadType = BreadType.init(raw: tiles[column, row]!)
                    if let breadType = breadType {
                        let bread = Bread(column: column, row: row, breadType: breadType)
                        breads[column, row] = bread
                        set.insert(bread)
                        highestScore += breadType.points
                    }
                }
            }
        }
        
        print("Hightest score for this level: \(highestScore)")
        return set
    }
    
    // Return levelCompleteStatus depending on the score
    // If the score is over 75% of the max score possible of this level, => one star
    // If it's over 90% => two star
    // If they obtained the max score, => three star
    
    func levelCompleteStatus(score: Int) -> LevelCompleteType{
        if Double(score) >= Double(highestScore){
            return .threeStar
        } else if Double(score) >= Double(highestScore) * 0.8 {
            return .twoStar
        } else if Double(score) >= Double(highestScore) * 0.6 {
            return .oneStar
        } else {
            return .lose
        }
    }
}

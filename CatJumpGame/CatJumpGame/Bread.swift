//
//  Bread.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 20/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

// A enumeration representing different types of bread, the number of points if gives,
// and its spriteName

enum BreadType: Int, CustomStringConvertible {
    case unknown = 0, croissant, chocoDonut, chocoCroissant, chocoHeartCooike,
    darkChocoCroissant, donut, elephantEar, heartCookie,
    oreoDonut, strawberryCroissant, strawberryDonut, strawberryHeartCookie,
    whiteChocoHeartCookie
    
    init?(raw: Int) {
        self.init(rawValue: raw)
    }
    var spriteName: String {
        let spriteNames = ["croissant", "chocoDonut", "chocoCroissant", "chocoHeartCookie",
                           "darkChocoCroissant", "donut", "elephantEar", "heartCookie",
                           "oreoDonut", "strawberryCroissant", "strawberryDonut", "strawberryHeartCookie",
                           "whiteChocoHeartCookie"]
        return spriteNames[rawValue - 1]
    }
    var description: String {
        return spriteName
    }
    var points: Int {
        let pointsReceived = [0, 20, 50, 30, 20,
                              30, 40, 30, 20,
                              80, 40, 60, 30,
                              40]
        return pointsReceived[rawValue]
    }
}

// A custom class that represents a bread in the game
// The game has a tile map of 8 columns and 9 rows
// Each tile can hold a bread

class Bread: CustomStringConvertible, Hashable{
    var column: Int
    var row: Int
    let breadType: BreadType
    var sprite: BreadNode?
    var hashValue: Int {
        return row*10 + column
    }
    
    init(column: Int, row: Int, breadType: BreadType) {
        self.column = column
        self.row = row
        self.breadType = breadType
    }
    
    static func ==(lhs: Bread, rhs: Bread) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
    
    var description: String {
        return "type:\(breadType) square:(\(column),\(row))"
    }
}

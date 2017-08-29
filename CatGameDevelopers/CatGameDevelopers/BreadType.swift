//
//  BreadType.swift
//  CatGameDevelopers
//
//  Created by Isabel  Lee on 28/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

enum BreadType: Int, CustomStringConvertible {
    case unknown = 0, croissant, chocoDonut, chocoCroissant, chocoHeartCooike,
    darkChocoCroissant, donut, elephantEar, heartCookie,
    oreoDonut, strawberryCroissant, strawberryDonut, strawberryHeartCookie,
    whiteChocoHeartCookie, none
    
    init?(raw: Int) {
        self.init(rawValue: raw)
    }
    var spriteName: String {
        let spriteNames = ["croissant", "chocoDonut", "chocoCroissant", "chocoHeartCookie",
                           "darkChocoCroissant", "donut", "elephantEar", "heartCookie",
                           "oreoDonut", "strawberryCroissant", "strawberryDonut", "strawberryHeartCookie",
                           "whiteChocoHeartCookie", "none"]
        return spriteNames[rawValue - 1]
    }
    var description: String {
        return spriteName
    }
    var points: Int {
        let pointsReceived = [0, 20, 50, 30, 20,
                              30, 40, 30, 20,
                              80, 40, 60, 30,
                              40, 0]
        return pointsReceived[rawValue]
    }
}

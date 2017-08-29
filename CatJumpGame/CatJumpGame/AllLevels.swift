//
//  AllLevels.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 28/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation

//A singleton who's main purpose is reading through all locally stored Level files to determine
//how many levels the users has downloaded (since new levels will be downloaded automatically from 
//firebase, this assumes that if the user has level 3, he/she must have level 1, 2, and if the user does
//not have level 4, he/she does not have level 5)

class AllLevels {
    static let shared = AllLevels()
    var numberOfLevels = 0
    func countAvailableLevels() {
        var i = 1
        while true {
            let filename = "Level_\(i)"
            let dictionary = Dictionary<String, AnyObject>.loadJSONFromDocument(filename: filename)
            if dictionary == nil || (dictionary?.isEmpty)! {
                print("\n\n\n\n\nAvailable levels \(numberOfLevels)")
                break
            } else {
                numberOfLevels = i
                i += 1
            }
        }
    }
}

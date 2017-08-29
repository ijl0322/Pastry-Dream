//
//  Int+Extension.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 18/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//


import CoreGraphics
public extension Int {
    /**
     * Converts an angle in degrees to radians.
     */
    public func toRadians() -> CGFloat{
        return π * CGFloat(self) / 180.0
    }
    
    public func secondsToFormatedString() -> String {
        if self >= 0 {
            let minutes = (self/60) % 60
            let seconds = self % 60
            let timeText = String(format: "%01d:%02d", minutes, seconds)
            return timeText
        } else {
            return "0:00"
        }
    }
}

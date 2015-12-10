//
//  SaveManager.swift
//  Asteroid Blaster
//
//  Created by Brandon Groff on 12/7/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import Foundation

private struct SavedValues {
    static let Highscore = "Highscore"
    static let pausedGameTime = "PausedGameTime"
}

class SaveManager {
    
    static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    class func getSavedHighscore() -> Int{
        if(self.userDefaults.valueForKey(SavedValues.Highscore) == nil){
            self.userDefaults.setInteger(0, forKey: SavedValues.Highscore)
        }
        return self.userDefaults.integerForKey(SavedValues.Highscore)
    }
    
    class func updateHighscore(newScore: Int) -> Bool{
        let currentHigh = self.getSavedHighscore()
        if (currentHigh < newScore){
            self.userDefaults.setInteger(newScore, forKey: SavedValues.Highscore)
            return true
        }
        return false
    }
    
    class func saveGameTime(time: Int) {
        self.userDefaults.setObject(time, forKey: SavedValues.pausedGameTime)
    }
    
    class func getPausedGameTime() -> Int {
        if(self.userDefaults.valueForKey(SavedValues.pausedGameTime) == nil){
            self.userDefaults.setObject(NSDate(), forKey: SavedValues.pausedGameTime)
        }
        return self.userDefaults.integerForKey(SavedValues.pausedGameTime)
    }
}
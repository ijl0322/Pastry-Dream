//
//  FirebaseManager.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 27/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Firebase
import UIKit

//A singleton that handles all network activities regarding firebase

class FirebaseManager {
    static let sharedInstance = FirebaseManager()
    let levelsRef = FIRDatabase.database().reference(withPath: "levels")
    let userDataRef = FIRDatabase.database().reference(withPath: "users")
    let highScoreDataRef = FIRDatabase.database().reference(withPath: "highScores")
    let id = UIDevice().identifierForVendor?.uuidString
    
    //Load all levels from firebase, and save them locally on the user's device
    func loadAllLevels() {
        levelsRef.observeSingleEvent(of: .value, with: { snapshot in
            //print(snapshot)
            
            let levels = snapshot.value as! [[String: Any]]
            dump(levels.count)
            for (index, levelData) in levels.enumerated() {
                self.saveToDoc(levelData: levelData, level: index + 1)
            }
            AllLevels.shared.countAvailableLevels()
        })
    }
    
    //Load a single level from firebase (currently not in use)
    func loadLevel(num: Int) {
        levelsRef.child("\(num)").observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot)
            let level = snapshot.value as! [String: Any]
            self.saveToDoc(levelData: level, level: num)
        })
    }
    
    //Upload the user's data to firebase
    //The structure of the data can be found in UserData.swift
    func updateUserData(data: [String:Any]) {
        userDataRef.child(id!).setValue(data)
    }

    //Pull the user's data from firebase
    //The structure of the data can be found in UserData.swift
    func getUserData(completion: @escaping ([String:Any]) -> Void) {
        userDataRef.child(id!).observeSingleEvent(of: .value, with: { snapshot in
            let userData = snapshot.value as! [String: Any]
            completion(userData)
        })
    }
    
    //The user can use transfer code to transfer progress from one device to another device.
    //Thus, this gets user data using the transfer code
    func getUserDataFromTransfer(code: String, completion: @escaping ([String:Any]?) -> Void) {
        userDataRef.child(code).observeSingleEvent(of: .value, with: { snapshot in
            let userData = snapshot.value as? [String: Any]
            completion(userData)
        })
    }
        
    //Takes levelData, which is a dictionary download from firebase, and save it locally in the user's 
    //Document directory
    func saveToDoc(levelData: [String: Any], level: Int){
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        //print(docs.absoluteString)
        let fileUrl = docs.appendingPathComponent("Level_\(level).json")
        do {
            let data = try JSONSerialization.data(withJSONObject: levelData, options: [])
            try data.write(to: fileUrl, options: [])
        } catch {
            print(error)
        }
    }
}

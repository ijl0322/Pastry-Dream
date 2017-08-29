//
//  LeaderBoardManager.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 29/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

// Manage network calls to the google app engine server

class LeaderBoardManager {
    
    static let sharedInstance = LeaderBoardManager()
    private init() {}
    let domainName = "https://catgamebackend.appspot.com/"
    
    // Send post request of the user's newest score to the server
    
    func postScore(_ score: Int, level: Int) {
        print("Attempting to post score")
        var request = URLRequest(url: URL(string: domainName + "new/level/\(level)")!)
        request.httpMethod = "POST"
        let nickname = UserData.shared.nickName
        let postString = "nickname=\(nickname)&score=\(score)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error ?? "no error" as! Error)")
                return
            }
    
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //print("response = \(response)")
            }
    
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    // Get the highest 4 scores for a given level, and return the player's nickname and highscore in an array
    
    func highScoreForLevel(_ level: Int, completion: @escaping ([[String:Any]]?) -> Void) {
        let urlString = domainName + "score/level/\(level)"
        
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                return
            }
            
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print(json)
                
                guard let highScoreArray = json as? [[String: Any]] else {
                    fatalError("We couldn't cast the JSON to an array of dictionaries")
                }
                
                completion(highScoreArray)
                
            } catch {
                print("error serializing JSON: \(error)")
                
                completion(nil)
            }

        })
        
        task.resume()
    }
}

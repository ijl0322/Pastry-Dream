//
//  Dictionary+JsonExtension.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 20/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        var dataOK: Data
        var dictionaryOK: NSDictionary = NSDictionary()
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions()) as Data!
                dataOK = data!
            }
            catch {
                print("Could not load level file: \(filename), error: \(error)")
                return nil
            }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: dataOK, options: JSONSerialization.ReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as! NSDictionary as? Dictionary<String, AnyObject>)! as NSDictionary
            }
            catch {
                print("Level file '\(filename)' is not valid JSON: \(error)")
                return nil
            }
        }
        return dictionaryOK as? Dictionary<String, AnyObject>
    }
    
    static func loadJSONFromDocument(filename: String) -> Dictionary<String, AnyObject>? {
        var dataOK: Data
        var dictionaryOK: NSDictionary = NSDictionary()
        
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
        let path = docs.appendingPathComponent("\(filename).json")
        
        do {
            let data = try Data(contentsOf: path, options: NSData.ReadingOptions()) as Data!
            dataOK = data!
        }
        catch {
            print("Could not load level file: \(filename), error: \(error)")
            print("Falling back to use native file")
            return loadJSONFromBundle(filename: filename)
        }
        do {
            let dictionary = try JSONSerialization.jsonObject(with: dataOK, options: JSONSerialization.ReadingOptions()) as AnyObject!
            dictionaryOK = (dictionary as! NSDictionary as? Dictionary<String, AnyObject>)! as NSDictionary
        }
        catch {
            print("Level file '\(filename)' is not valid JSON: \(error)")
            return nil
        }
        return dictionaryOK as? Dictionary<String, AnyObject>
    }
}

//
//  NewLevelViewController.swift
//  CatGameDevelopers
//
//  Created by Isabel  Lee on 28/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit



class NewLevelViewController: UIViewController {
    
    @IBOutlet weak var timeLimitTextField: UITextField!
    var screenWidth = 0.0
    var spriteWidth = 0.0
    var screenHeight = 0.0
    var largerSpriteWidth = 0.0
    var largerSpriteSpacing = 0.0
    var spacing = 0.0
    var vspacing = 3.0
    var timeLimit = 60
    var breadTypeImageViews: [UIImageView] = []
    var currentBread: BreadType = .croissant
    var breadTiles = [ [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0],
                       [0, 0, 0, 0, 0, 0, 0, 0] ]
    
    
    @IBAction func addLevel(_ sender: UIButton) {
        FirebaseManager.sharedInstance.addLevelToFirebase(tiles: breadTiles, timeLimit: timeLimit)
        let alert = UIAlertController(title: "", message: "Data Sent to Firebase", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = Double(view.frame.size.width)
        spriteWidth = screenWidth/10
        largerSpriteWidth = screenWidth/8
        largerSpriteSpacing = screenWidth * 0.02
        spacing = screenWidth * 0.028
        screenHeight = Double(view.frame.size.height)
        timeLimitTextField.delegate = self
        
        for j in 0...8 {
            for i in 0...7 {
                let newView = UIImageView(frame: CGRect(x: (spriteWidth + spacing) * Double(i), y: (spriteWidth + vspacing) * Double(j) + 60, width: spriteWidth, height: spriteWidth))
                newView.image = UIImage(named: "none")
                newView.isUserInteractionEnabled = true
                newView.tag = (j + 1) * 10 + i + 1
                let gesutre = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                newView.addGestureRecognizer(gesutre)
                self.view.addSubview(newView)
            }
        }
        
        for i in 1...7 {
            let newView = UIImageView(frame: CGRect(x: (largerSpriteWidth + largerSpriteSpacing) * Double(i-1), y: screenHeight - (largerSpriteWidth * 2), width: largerSpriteWidth, height: largerSpriteWidth))
            let bread = BreadType.init(raw: i)
            newView.image = UIImage(named: (bread?.spriteName)!)
            newView.tag = 100 + i
            newView.layer.borderColor = UIColor.white.cgColor
            newView.layer.borderWidth = 0
            newView.isUserInteractionEnabled = true
            let gesutre = UITapGestureRecognizer(target: self, action: #selector(changeBreadTap(_:)))
            newView.addGestureRecognizer(gesutre)
            breadTypeImageViews.append(newView)
            self.view.addSubview(newView)
        }
        
        for i in 8...14 {
            let newView = UIImageView(frame: CGRect(x: (largerSpriteWidth + largerSpriteSpacing) * Double(i-8), y: screenHeight - (largerSpriteWidth), width: largerSpriteWidth, height: largerSpriteWidth))
            let bread = BreadType.init(raw: i)
            newView.image = UIImage(named: (bread?.spriteName)!)
            newView.layer.borderColor = UIColor.white.cgColor
            newView.layer.borderWidth = 0
            newView.tag = 100 + i
            newView.isUserInteractionEnabled = true
            let gesutre = UITapGestureRecognizer(target: self, action: #selector(changeBreadTap(_:)))
            newView.addGestureRecognizer(gesutre)
            breadTypeImageViews.append(newView)
            self.view.addSubview(newView)
        }
    
        breadTypeImageViews[0].layer.borderWidth = 3
        
        // Do any additional setup after loading the view.
        
    }
    
    func handleTap(_ recognizer:UITapGestureRecognizer) {
        print("\(recognizer.view?.tag ?? 0)")
        let imageView = recognizer.view as! UIImageView
        imageView.image = UIImage(named: currentBread.spriteName)
        let tag = (recognizer.view?.tag)!
        let row = tag/10 - 1
        let colum = tag%10 - 1
        breadTiles[row][colum] = currentBread.rawValue % 14
        // %14 because there are only 13 types of bread, but a none type is created to denote none
        // 0 can't be a tag for views, so the none type's raw value is 14, but when uploading the json 
        // a empty block should be 0 (this is how the game is structured)
        print(breadTiles)
    }

    func changeBreadTap(_ recognizer: UITapGestureRecognizer) {
        print("\(recognizer.view?.tag ?? 0)")
        for bread in breadTypeImageViews {
            bread.layer.borderWidth = 0
        }
        recognizer.view?.layer.borderWidth = 3
        currentBread = BreadType.init(raw: (recognizer.view?.tag)! - 100)!
        print("Current Bread Type: \(currentBread)")
    }
    
}

extension NewLevelViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let text = textField.text {
            print("Text Entered: \(text)")
            if let time = Int(text) {
                if time > 0 {
                    timeLimit = time
                    print("New Time Limit \(time)")
                } else {
                    timeLimitTextField.text = "Enter int(>0)"
                }
            }
        }
        return
    }
}

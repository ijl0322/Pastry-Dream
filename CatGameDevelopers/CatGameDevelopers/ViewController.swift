//
//  ViewController.swift
//  CatGameDevelopers
//
//  Created by Isabel  Lee on 24/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var levelRef: FIRDatabaseReference!
    var messageToSend = ""
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBAction func sendMessage(_ sender: UIButton) {
        print("sending message")
        textField.resignFirstResponder();
        messageLabel.text = textField.text
        if let message = textField.text {
            messageToSend = message
            ClouldKitManager.sharedInstance.send(message: messageToSend)
            textField.text = ""
            let alert = UIAlertController(title: "", message: "Notificaiton Sent", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func sendLevels(_ sender: UIButton) {
        var allLevels: [[String:AnyObject]] = []
        var i = 1
        while true {
            if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: "Level_\(i)") {
                if dictionary.isEmpty {
                    break
                } else {
                    allLevels.append(dictionary)
                    print("level \(i) upload succeeded")
                    levelRef.child("\(i-1)").setValue(dictionary)
                    i += 1
                }
            }
        }
    }

    @IBAction func previewMessage(_ sender: UIButton) {
        if let message = textField.text {
            messageToSend = message
            messageLabel.text = message
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        levelRef = FIRDatabase.database().reference(withPath: "levels")
    }
    
    @IBAction func unwindToRoot(_ sender: UIStoryboardSegue) {
        
    }
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let text = textField.text {
            print("Text Entered: \(text)")
            messageLabel.text = text
        }
        return
    }
}

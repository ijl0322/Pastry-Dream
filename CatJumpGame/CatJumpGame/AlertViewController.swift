//
//  AlertViewController.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 28/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

// Handle showing different alerts for game transfer

class AlertViewController: UIViewController {
    
    var alertType: AlertType?
    var transferCode = ""

    @IBOutlet weak var alertLabel: UILabel!
    
    @IBAction func okayButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        self.alertLabel.text = "Transfering data..."
        self.alertLabel.font = UIFont(name: "BradyBunchRemastered", size: 20)
        self.yesButton.isHidden = true
        self.noButton.isHidden = true
        self.okButton.isHidden = false
        
        FirebaseManager.sharedInstance.getUserDataFromTransfer(code: transferCode, completion: { (snapshot) in
            if snapshot == nil {
                print("Unsucessful transfer")
                self.alertLabel.text = "Oops! There seems to be a problem. Make sure your transfer code is correct and you have internet connection"
                self.alertLabel.font = UIFont(name: "BradyBunchRemastered", size: 20)
            } else {
                UserData.shared.updateFromTransfer(snapshot: snapshot!)
                print("Transfer Success")
                self.alertLabel.text = "Your game transfer was successful!"
                self.alertLabel.font = UIFont(name: "BradyBunchRemastered", size: 20)
            }
            self.okButton.isHidden = false
        })
    }
    
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        if alertType == .transfer {
            okButton.isHidden = true
            alertLabel.text = "You are about to transfer game data to this device. After the transfer, all current data will be replaced. Do you wish to continue?"
            alertLabel.font = UIFont(name: "BradyBunchRemastered", size: 20)
        }
    }
}

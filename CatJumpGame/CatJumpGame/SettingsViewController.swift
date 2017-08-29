//
//  SettingsViewController.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 27/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

enum AlertType {
    case success
    case failed
    case transfer
}

// A View Controller that manages the settings of the app

class SettingsViewController: UIViewController {
    
    var playMusic = true

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var gameTransferCodeLabel: UILabel!
    @IBOutlet weak var transferCodeTextField: UITextField!
    @IBOutlet weak var musicButton: UIButton!
    
    @IBAction func transferGame(_ sender: UIButton) {
        if let code = transferCodeTextField.text {
            let vc = storyboard?.instantiateViewController(withIdentifier:
                "alertViewController") as! AlertViewController
            
            vc.alertType = .transfer
            vc.transferCode = code
            
            self.present(vc, animated: false) {
                print("Detached presented")
            }
        }
    }
    
    @IBAction func showGameTransferCode(_ sender: UIButton) {
        gameTransferCodeLabel.text = UIDevice().identifierForVendor?.uuidString
        gameTransferCodeLabel.font = UIFont(name: "BradyBunchRemastered", size: 20)
        print("\(UIDevice().identifierForVendor?.uuidString ?? "No code")")
    }
    
    @IBAction func musicButtonTapped(_ sender: UIButton) {
        if playMusic {
            musicButton.setImage(UIImage(named: "switchOff"), for: .normal)
            UserDefaults.standard.set(1, forKey: "musicStatus")
        } else {
            musicButton.setImage(UIImage(named: "switchOn"), for: .normal)
            UserDefaults.standard.set(0, forKey: "musicStatus")
        }
        
        playMusic = !playMusic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nickNameTextField.delegate = self
        nickNameTextField.text = UserData.shared.nickName
        nickNameTextField.font = UIFont(name: "BradyBunchRemastered", size: 30)
        
        transferCodeTextField.delegate = self
        
        let status = UserDefaults.standard.integer(forKey: "musicStatus")
        if status == 1 {
            musicButton.setImage(UIImage(named: "switchOff"), for: .normal)
            playMusic = false
        }
    }
    
    func showAlert(type: AlertType) {
        let vc = storyboard?.instantiateViewController(withIdentifier:
            "alertViewController") as! AlertViewController
        
        vc.alertType = type
        
        self.present(vc, animated: false) {
            print("Detached presented")
        }
    }
    
    @IBAction func unwindToSettingsVC(_ sender: UIStoryboardSegue) {
        
    }

}

extension SettingsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let text = textField.text {
            if textField.tag == 1 {
                print("Text Entered: \(text)")
                UserData.shared.changeNickname(name: text)
                
            }
        }
        return
    }
}


//
//  SplashScreenViewController.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 30/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController() as! RootViewController
            self.view.window?.rootViewController = viewController
        }
    }
}

//
//  AppDelegate.swift
//  CatJumpGame
//
//  Created by Isabel  Lee on 16/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        //Setting First Launch Date if it has not been set
        if let firstLaunch = UserDefaults.standard.object(forKey: "firstLaunchDate") {
            print("First Launch Date is set already to \(firstLaunch)")
        } else {
            print("\(NSDate())")
            let today = NSDate()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let new = formatter.string(from: today as Date)
            UserDefaults.standard.set(new, forKey: "firstLaunchDate")
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            } else {
                application.registerForRemoteNotifications()
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        ClouldKitManager.sharedInstance.registerNewSubscriptionsWithIdentifier("id5")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FirebaseManager.sharedInstance.loadAllLevels()
        AllLevels.shared.countAvailableLevels()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                with completionHandler: @escaping () -> Void){
        let response = response.notification.request.content
        print(response)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        //dump(userInfo)
        if aps["content-available"] as! NSNumber == 1 {
            let cloudKit = userInfo["ck"] as! [String: AnyObject]
            //let recordId = cloudKit["qry"]?["rid"] as! String
            let field = cloudKit["qry"]?["af"] as! [String: AnyObject]
            let message = field["Message"] as? String
            
            let content = UNMutableNotificationContent()
            content.title = "Message from the developer!"
            content.body = "Hello from developer!"
            if let message = message {
                content.body = "\(message)"
            }
            
            print(message ?? "No message")
            content.sound = UNNotificationSound.default()
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let center = UNUserNotificationCenter.current()
            let identifier = String(Date().timeIntervalSinceReferenceDate)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("An Error Occured: \(error)")
                } else {
                    print("Sending local notification")
                }
            })
            completionHandler(.newData)
        } else  {
            completionHandler(.newData)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        let response = response.notification.request.content
        print("Notification: \(response)")
        completionHandler()
    }
}


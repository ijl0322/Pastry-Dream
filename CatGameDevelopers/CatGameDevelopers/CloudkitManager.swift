//
//  CloudkitManager.swift
//  CatGameDevelopers
//
//  Created by Isabel  Lee on 24/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation
import UIKit

class ClouldKitManager {
    
    // MARK: - Properties
    let MessageRecordType = "Notifications"
    static let sharedInstance = ClouldKitManager()

    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    // MARK: - Initializers
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    //Add a location to Cloudkit public database
    func send(message: String) {
        let record = CKRecord(recordType: MessageRecordType)
        record["Message"] = message as CKRecordValue
        
        //Saving to public database
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    

    //Register a user to be receive a silent notification when a new spot is added
    //A custom local notification is created when the silent notification is received
    func registerSilentSubscriptionsWithIdentifier(_ identifier: String) {
        
        let uuid: UUID = UIDevice().identifierForVendor!
        let identifier = "\(uuid)-silent"
        
        // Create the notification that will be delivered
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["Message"]
        
        let subscription = CKQuerySubscription(recordType: MessageRecordType,
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = notificationInfo
        publicDB.save(subscription, completionHandler: ({returnRecord, error in
            if let err = error {
                print("subscription failed \(err.localizedDescription)")
            } else {
                print("silent subscription set up")
            }
        }))
    }
}

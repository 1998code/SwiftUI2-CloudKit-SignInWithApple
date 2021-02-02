//
//  CloudSignApp.swift
//  CloudSign
//
//  Created on 9/5/20.
//

import SwiftUI
import CloudKit

@main
struct CloudSignApp: App {
    
    // Load a image asset from iCloud Database
//    init(){
//        let publicDatabase = CKContainer.default().publicCloudDatabase
//
//        publicDatabase.fetch(withRecordID: CKRecord.ID(recordName: "3285B867-1908-54FD-0FBD-B4D49CC07625")){(record, error) in
//            if let fetchedInfo = record {
//               let assets = fetchedInfo["Image"] as? CKAsset
//               let assetsData = NSData(contentsOf: (assets?.fileURL!)!)
//               // You may try print(assetsData) and view on Console
//               // Save the data
//               UserDefaults.standard.set(assetsData, forKey: "demoImage")
//           }
//        }
//
//        sleep(1)
//    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

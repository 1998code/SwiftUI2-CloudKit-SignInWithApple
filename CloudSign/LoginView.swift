//
//  ContentView.swift
//  CloudSign
//
//  Created on 9/5/20. Updated on 1/25/2020.
//

import SwiftUI
import CloudKit                 // import CloudKit for iCloud Service
import AuthenticationServices   // import Auth Services to make Sign in with Apple works

// Start a new Login View
struct LoginView: View {
    
    // Give a login state, by default, it is false => not logined.
    @AppStorage("login") private var login = false
    
    @AppStorage("email") private var email = ""
    @AppStorage("firstName") private var firstName = ""
    @AppStorage("lastName") private var lastName = ""
    @AppStorage("userID") private var userID = ""
    
    init() {
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: "2EADC63D-0EB0-3968-A068-278DB49426AE")){(record, error) in
            if let fetchedInfo = record {
                let assets = fetchedInfo["Image"] as? CKAsset
                let assetsData = NSData(contentsOf: (assets?.fileURL!)!)
                // You may try print(assetsData) and view on Console
                // Save the data
                UserDefaults.standard.set(assetsData, forKey: "cloudBG")
           }
        }
    }
    
    var body: some View {
        // Use Navigation View
        NavigationView{
            ZStack{
                // Background image
                if UserDefaults.standard.object(forKey: "cloudBG") == nil {
                    Image("localBG").resizable().edgesIgnoringSafeArea(.all)
                } else {
                    Image(uiImage: UIImage(data: UserDefaults.standard.object(forKey: "cloudBG") as! Data) as! UIImage).resizable().edgesIgnoringSafeArea(.all)
                }
                
                VStack {
                    if (!login && (userID == "")) {
                        Spacer()
                        
                        HStack{
                            Spacer()
                            LottieView(name: "19934-flirting-dog")
                                .frame(width:400,height:400)
                                .padding(.trailing,-95)
                        }.ignoresSafeArea(.all)
                        
                        Spacer()
                        
                        signInWithApple
                        
                    }
                    else{
                        // Hide the button after logined
                        LottieView(name: "19938-happy-unicorn-dog")
                    }
                    
                    // Show User Info
                    if userID != "" {
                        userInfo
                    }
                }.padding()
            }
            .toolbar {
                if (login && (userID != "")) {
                    Button(action: {
                        login = false
                        userID = ""
                        email = ""
                        firstName = ""
                        lastName = ""
                    }) {
                        Text("Sign out").foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("CloudSign")
            .preferredColorScheme(.dark)
        }
    }
    
    var signInWithApple: some View {
        SignInWithAppleButton(
            // Request User FullName and Email
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]   // You can change them if needed.
            },
            // Once user complete login, get result
            onCompletion: { result in
                // Switch result
                switch result {
                    // Auth Success
                    case .success(let authResults):
                    switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            let uID = appleIDCredential.user
                        
                            if let emailAddress = appleIDCredential.email,
                            let givenName = appleIDCredential.fullName?.givenName,
                            let familyName = appleIDCredential.fullName?.familyName {
                                
                                // For New user to signup, and save the 3 records to CloudKit
                                let record = CKRecord(recordType: "UsersData", recordID: CKRecord.ID(recordName: uID))
                                record["email"] = emailAddress
                                record["firstName"] = givenName
                                record["lastName"] = familyName
                                CKContainer.default().publicCloudDatabase.save(record) { (_, _) in
                                    userID = record.recordID.recordName
                                }
                                
                                // Save to local
                                email = emailAddress
                                firstName = givenName
                                lastName = familyName
                                
                                // Change login state
                                self.login = true
                                
                            } else {
                                // For returning user to signin, fetch the saved records from Cloudkit
                                CKContainer.default().publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: uID)) { (record, error) in
                                    if let fetchedInfo = record {
                                        // Save to local
                                        userID = uID
                                        email = fetchedInfo["email"] as! String
                                        firstName = fetchedInfo["firstName"] as! String
                                        lastName = fetchedInfo["lastName"] as! String
                                        
                                        // Change login state
                                        self.login = true
                                    }
                                }
                            }
                        
                        // default break (don't remove)
                        default:
                            break
                        }
                    case .failure(let error):
                        print("failure", error)
                }
            }
        )
        .signInWithAppleButtonStyle(.white) // Button Style
        .frame(width:350,height:50)         // Set Button Size (Read iOS 14 beta 7 release note)
    }
    
    var userInfo: some View {
        VStack(alignment: .leading) {
            Label(NSLocalizedString("Welcome back", comment: "") + "! " + firstName + " " + lastName, systemImage: "lock.rotation.open")
                .font(.footnote)
            
            HStack {
                Label(NSLocalizedString("Your Email", comment: "") + ": ", systemImage: "envelope.circle")
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(email)
                }
            }.font(.footnote)
            
            HStack {
                Label(NSLocalizedString("User ID", comment: "") + ": ", systemImage: "person.crop.circle")
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(userID)
                }
            }.font(.footnote)
        }
        .padding()
        .background(Color("WB").opacity(0.5))
        .cornerRadius(25)
    }
}

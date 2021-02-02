//
//  ContentView.swift
//  CloudSign
//
//  Created on 9/5/20. Updated on 1/25/2020.
//

import SwiftUI
// import Auth Services to make Sign in with Apple works
import AuthenticationServices
// import CloudKit for iCloud Service
import CloudKit
// import Lottie Animation Library
import Lottie

// Start a new Login View
struct LoginView: View {
    
    // Give a login state, by default, it is false => not logined.
    @AppStorage("login") private var login = false
    
    // Play Lottie Animation by default
    @State var play = 1
    
    var body: some View {
        // Use Navigation View
        NavigationView{
            ZStack{
                // Add a background image
                Image("bg")
                //Image(uiImage: UIImage(data: UserDefaults.standard.object(forKey: "demoImage") as! Data) as! UIImage)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Let userID = saved userID
                    let userID = UserDefaults.standard.object(forKey: "userID") as? String

                    if (!login && (userID == nil)) {
                        Spacer()
                        
                        HStack{
                            Spacer()
                            LottieView(name: "19934-flirting-dog", play: $play)
                                .frame(width:400,height:400)
                                .padding(.trailing,-95)
                        }.ignoresSafeArea(.all)
                        
                        Spacer()
                        
                        // If login = false and userID is not exist,
                        // Show Sign in with Apple Button.
                        SignInWithAppleButton(
                            // Request User FullName and Email
                            onRequest: { request in
                                // You can change them if needed.
                                request.requestedScopes = [.fullName, .email]
                            },
                            // Once user complete, get result
                            onCompletion: { result in
                                // Switch result
                                switch result {
                                    // Auth Success
                                    case .success(let authResults):

                                    switch authResults.credential {
                                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                            let userID = appleIDCredential.user
                                            if let firstName = appleIDCredential.fullName?.givenName,
                                                let lastName = appleIDCredential.fullName?.familyName,
                                                let email = appleIDCredential.email{
                                                // For New user to signup, and
                                                // save the 3 records to CloudKit
                                                let record = CKRecord(recordType: "UsersData", recordID: CKRecord.ID(recordName: userID))
                                                record["email"] = email
                                                record["firstName"] = firstName
                                                record["lastName"] = lastName
                                                // Save to local
                                                UserDefaults.standard.set(email, forKey: "email")
                                                UserDefaults.standard.set(firstName, forKey: "firstName")
                                                UserDefaults.standard.set(lastName, forKey: "lastName")
                                                let publicDatabase = CKContainer.default().publicCloudDatabase
                                                publicDatabase.save(record) { (_, _) in
                                                    UserDefaults.standard.set(record.recordID.recordName, forKey: "userID")
                                                }
                                                // Change login state
                                                self.login = true
                                            } else {
                                                // For returning user to signin,
                                                // fetch the saved records from Cloudkit
                                                let publicDatabase = CKContainer.default().publicCloudDatabase
                                                publicDatabase.fetch(withRecordID: CKRecord.ID(recordName: userID)) { (record, error) in
                                                    if let fetchedInfo = record {
                                                        let email = fetchedInfo["email"] as? String
                                                        let firstName = fetchedInfo["firstName"] as? String
                                                        let lastName = fetchedInfo["lastName"] as? String
                                                        // Save to local
                                                        UserDefaults.standard.set(userID, forKey: "userID")
                                                        UserDefaults.standard.set(email, forKey: "email")
                                                        UserDefaults.standard.set(firstName, forKey: "firstName")
                                                        UserDefaults.standard.set(lastName, forKey: "lastName")
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
                        
                    }else{
                        // Hide the button after logined
                        LottieView(name: "19938-happy-unicorn-dog", play: $play)
                    }
                    
                    // Show User Info
                    if let userID = UserDefaults.standard.object(forKey: "userID") as? String {
                        VStack(alignment: .leading) {
                        
                            if let firstName = UserDefaults.standard.object(forKey: "firstName") as? String,
                            let lastName = UserDefaults.standard.object(forKey: "lastName") as? String{
                                Label(NSLocalizedString("Welcome back", comment: "") + "! " + firstName + " " + lastName, systemImage: "lock.rotation.open")
                                    .font(.footnote)
                            }
                            if let email = UserDefaults.standard.object(forKey: "email") as? String {
                                HStack {
                                    Label(NSLocalizedString("Your Email", comment: "") + ": ", systemImage: "envelope.circle")
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        Text(email)
                                    }
                                }.font(.footnote)
                            }
                            
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
                }.padding()
            }
            .navigationTitle("CloudSign")
        }
    }
}

// Lottie Animation View in UIViewRepresentable
struct LottieView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    var name: String!
    @Binding var play:Int

    var animationView = AnimationView()

    class Coordinator: NSObject {
        var parent: LottieView

        init(_ animationView: LottieView) {
            self.parent = animationView
            super.init()
        }
    }

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()

        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        animationView.loopMode = .loop
        animationView.play()
    }
}

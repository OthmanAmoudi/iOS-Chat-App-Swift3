//
//  Helper.swift
//  Z2LChatApp
//
//  Created by Othman Mashaab on 05/04/2017.
//  Copyright © 2017 Othman Mashaab. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit
import GoogleSignIn
class Helper{
   
    static let helper = Helper()
   
    func loginAnonymously() {
        print("login anonymously did tapped")
        // Anonymously log users in
        // switch view by setting navigation controller as root view controller
        
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                print("UserId: \(anonymousUser!.uid)")
                
                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                newUser.setValue(["displayname" : "anonymous", "id" : "\(anonymousUser!.uid)",
                    "profileUrl": ""])
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
        
        
        
    }
    func loginWithGoogle(_ authentication: GIDAuthentication) {
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }else {
//                print(user?.email)
//                print(user?.displayName)
//                print(user?.photoURL)
 
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                
                newUser.setValue(["displayname" : "\(user!.displayName!)", "id" : "\(user!.uid)",
                    "profileUrl": "\(user!.photoURL!)"])
                
                
                self.switchToNavigationViewController()
            }
        })
    }

    
    func switchToNavigationViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
        
    }

    
}

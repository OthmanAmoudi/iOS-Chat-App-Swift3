//
//  LoginViewController.swift
//  Z2LChatApp
//
//  Created by Othman Mashaab on 05/04/2017.
//  Copyright © 2017 Othman Mashaab. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        anonymousButton.layer.borderWidth = 1.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = "131014422343-ch26vfap00jh2d7brj2ab2uot9dbs6ns.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBOutlet weak var anonymousButton: UIButton!
    @IBAction func loginAnoumously(_ sender: Any) {
        print("Login anonymosuly did tapped")
        Helper.helper.loginAnonymously()
    }
    @IBAction func googleLoginTapped(_ sender: Any) {
        
        print("Login google")
        GIDSignIn.sharedInstance().signIn()
        

    }
    @IBOutlet weak var googleLoginDidTapped: UIButton!
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print(user.authentication)
        Helper.helper.loginWithGoogle(user.authentication)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(FIRAuth.auth()?.currentUser)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
            if user != nil {
                print(user)
                Helper.helper.switchToNavigationViewController()
            }else{
                print("Unauthorized")
            }
            })
    }
    

   

}

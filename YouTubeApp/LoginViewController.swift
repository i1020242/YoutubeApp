//
//  LoginViewController.swift
//  YouTubeApp
//
//  Created by BDAFshare on 1/16/17.
//  Copyright © 2017 TEST. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        let btnsignIn = GIDSignInButton(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
        btnsignIn.center = view.center
        let btnLogout = UIButton(frame: CGRect(x: 0, y: 400, width: 100, height: 50))
        btnLogout.center.x = view.center.x
        btnLogout.backgroundColor = UIColor.green
        btnLogout.setTitle("Button", for: UIControlState())
        btnLogout .addTarget(self, action: #selector(logout), for: .touchUpInside)
        view.addSubview(btnsignIn)
        view.addSubview(btnLogout)
        
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.readonly")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func logout()->Void {
        GIDSignIn .sharedInstance() .disconnect()
        GIDSignIn.sharedInstance() .signOut()
        
    }
    
    func sign(_ signIn: GIDSignIn!,
                present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
                dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

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
        let btnsignIn = GIDSignInButton(frame: CGRectMake(0,0,50,50))
        btnsignIn.center = view.center
        let btnLogout = UIButton(frame: CGRectMake(0, 400, 100, 50))
        btnLogout.center.x = view.center.x
        btnLogout.backgroundColor = UIColor.greenColor()
        btnLogout.setTitle("Button", forState: UIControlState.Normal)
        btnLogout .addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
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
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

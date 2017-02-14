//
//  LoginCollectionViewCell.swift
//  YouTubeApp
//
//  Created by BDAFshare on 1/16/17.
//  Copyright © 2017 TEST. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

class LoginCollectionViewCell: UICollectionViewCell, GIDSignInUIDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        GIDSignIn.sharedInstance().uiDelegate = self
        let btnsignIn = GIDSignInButton(frame: CGRectMake(0,0,50,50))
        
        let btnLogout = UIButton(frame: CGRectMake(80, 80, 100, 50))
        btnLogout.backgroundColor = UIColor.greenColor()
        btnLogout.setTitle("Button", forState: UIControlState.Normal)
        btnLogout .addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
        addSubview(btnsignIn)
        addSubview(btnLogout)
        //        let scope: NSString = "https://www.googleapis.com/auth/youtube"
        //        let currentScopes: NSArray = GIDSignIn.sharedInstance().scopes
        //        GIDSignIn.sharedInstance().scopes = currentScopes.arrayByAddingObject(scope)
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.readonly")
    }
    
    func logout()->Void {
        GIDSignIn .sharedInstance() .disconnect()
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        //self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        //self.dismissViewControllerAnimated(true, completion: nil)
    }


}

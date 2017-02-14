//
//  LoginCollectionView.swift
//  YouTubeApp
//
//  Created by BDAFshare on 1/16/17.
//  Copyright © 2017 TEST. All rights reserved.
//

import UIKit
import GoogleSignIn
import Google

protocol LoginCollectionDelegate {
    func loginView()->Void
}

private let loginCell = "loginCell"

class LoginCollectionView: UICollectionViewCell, GIDSignInUIDelegate {
    
    var delegate:LoginCollectionDelegate?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        let navigation = UINavigationController()
        let b=navigation.navigationBar.frame.size.height
        
        let cv = UICollectionView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height), collectionViewLayout: layout)
        
        //cv.dataSource = self
        //cv.delegate = self
        return cv
    }()


    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.scrollIndicatorInsets = UIEdgeInsetsZero
        collectionView.backgroundColor = UIColor .redColor()
        let nibname = UINib(nibName: "LoginCollectionViewCell", bundle: nil)
        collectionView.registerNib(nibname, forCellWithReuseIdentifier: loginCell)
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        addSubview(collectionView)
        setupBtnLogin()
    }
    func setupBtnLogin (){
        GIDSignIn.sharedInstance().uiDelegate = self
        let btnsignIn = GIDSignInButton(frame: CGRectMake(0,0,50,50))
        let btnLogout = UIButton(frame: CGRectMake(80, 80, 100, 50))
        btnLogout.backgroundColor = UIColor.greenColor()
        btnLogout.setTitle("Button", forState: UIControlState.Normal)
        btnLogout .addTarget(self, action: #selector(logout), forControlEvents: .TouchUpInside)
        addSubview(btnsignIn)
        addSubview(btnLogout)
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.readonly")
    }
    
    func logout()->Void {
        //self.delegate?.loginView()
        GIDSignIn .sharedInstance() .disconnect()
    }
    
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        
        self.delegate?.loginView()
        
        //self.presentViewController(viewController, animated: true) {
            
        }
    }
    
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        
    }




//extension LoginCollectionView:UICollectionViewDataSource{
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1;
//    }
//    
//    func collectionView(collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: screenSize.width, height: screenSize.height)
//        
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(loginCell, forIndexPath: indexPath) as! LoginCollectionViewCell
//        cell.backgroundColor = UIColor .greenColor()
//        return cell
//    }
//}
//
//extension LoginCollectionView:UICollectionViewDelegate {
//    
//}


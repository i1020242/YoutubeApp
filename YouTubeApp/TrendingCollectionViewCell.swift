//
//  TrendingCollectionViewCell.swift
//  YouTubeApp
//
//  Created by BDAFshare on 1/19/17.
//  Copyright © 2017 TEST. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn

protocol TrendingCollectionViewCellDelegate {
    func playVideoTrend(strVideoId:NSString)
}

let trendingCell = "homeCell"

class TrendingCollectionViewCell: UICollectionViewCell, GIDSignInDelegate {
    
    var delegate:TrendingCollectionViewCellDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        let navigation = UINavigationController()
        let b=navigation.navigationBar.frame.size.height
        
        let cv = UICollectionView(frame: CGRect(x: 0,y: 0,width: screenSize.width, height: screenSize.height - 130), collectionViewLayout: layout)
        
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var videos : [SearchModel]?
    override func awakeFromNib() {
        super.awakeFromNib()
        //fetchVideo()
        collectionView.scrollIndicatorInsets = UIEdgeInsetsZero
        collectionView.backgroundColor = UIColor .whiteColor()
        let nibname = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        collectionView.registerNib(nibname, forCellWithReuseIdentifier: trendingCell)
        
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        addSubview(collectionView)
        //setupFinishLogin()
        fetchVideo()
    }
    
    func fetchVideo(){
        
        ShareData.shareInstance.videoHomeProxy .fetchTrending({ (result, errCode) in
            self.videos = result as? [SearchModel]
            self.collectionView.reloadData()
            
            }) { (errorClosure) in
                
        }
    }
    func setupFinishLogin(){
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return GIDSignIn.sharedInstance().handleURL(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            
            let fullName = user.profile.name
            print(fullName)
            let email = user.profile.email
            print(email)
            
        } else {
            
            print("\(error.localizedDescription)")
        }
    }
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
}

extension TrendingCollectionViewCell:UICollectionViewDelegate {
    
}

//MARK: CollectionView DataSource
extension TrendingCollectionViewCell:UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if videos == nil {
            return 0
        }
        return videos!.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let height = (frame.width - 16 - 16) * 9 / 16
        return CGSizeMake(frame.width, height + 16 + 88)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(trendingCell, forIndexPath: indexPath)
            as! HomeCollectionViewCell
        cell.backgroundColor = UIColor .whiteColor()
        let video = self.videos![indexPath.item]
        
        cell.lblName.text = video.title
        cell.lblArtist.text = video.channelTitle
        if (video.profileImage != nil) {
            let urlProfile = NSURL(string: (video.profileImage)!)
            let urlBackground = NSURL(string: (video.profileImage)!)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: urlProfile!)
                let dataThumnail = NSData(contentsOfURL: urlBackground!)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.img.image = UIImage(data: data!)
                    cell.m_backgroundImg.image = UIImage(data: dataThumnail!)
                });
            }
        }
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let abc:SearchModel = self.videos![indexPath.row]
        let videoID:String = abc.videoId!
        let youtubeURL = "https://www.youtube.com/embed/\(videoID)"
        self.delegate?.playVideoTrend(youtubeURL)
    }
}




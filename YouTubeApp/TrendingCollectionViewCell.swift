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
    func playVideoTrend(_ strVideoId:NSString)
}

let trendingCell = "homeCell"

class TrendingCollectionViewCell: UICollectionViewCell, GIDSignInDelegate {
    
    var delegate:TrendingCollectionViewCellDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
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
        collectionView.scrollIndicatorInsets = UIEdgeInsets.zero
        collectionView.backgroundColor = UIColor.white
        let nibname = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        collectionView.register(nibname, forCellWithReuseIdentifier: trendingCell)
        
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
    
    func application(_ application: UIApplication,
                     openURL url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url,
                                                    sourceApplication: sourceApplication,
                                                    annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                withError error: Error!) {
        if (error == nil) {
            
            let fullName = user.profile.name
            print(fullName)
            let email = user.profile.email
            print(email)
            
        } else {
            
            print("\(error.localizedDescription)")
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: NSError!) {
        
    }
}

extension TrendingCollectionViewCell:UICollectionViewDelegate {
    
}

//MARK: CollectionView DataSource
extension TrendingCollectionViewCell:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if videos == nil {
            return 0
        }
        return videos!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let height = (frame.width - 16 - 16) * 9 / 16
        return CGSize(width: frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: trendingCell, for: indexPath)
            as! HomeCollectionViewCell
        cell.backgroundColor = UIColor.white
        let video = self.videos![indexPath.item]
        
        cell.lblName.text = video.title
        cell.lblArtist.text = video.channelTitle
        if (video.profileImage != nil) {
            let urlProfile = URL(string: (video.profileImage)!)
            let urlBackground = URL(string: (video.profileImage)!)
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
                let data = try? Data(contentsOf: urlProfile!)
                let dataThumnail = try? Data(contentsOf: urlBackground!)
                DispatchQueue.main.async(execute: {
                    cell.img.image = UIImage(data: data!)
                    cell.m_backgroundImg.image = UIImage(data: dataThumnail!)
                });
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let abc:SearchModel = self.videos![indexPath.row]
        let videoID:String = abc.videoId!
        let youtubeURL = "https://www.youtube.com/embed/\(videoID)"
        self.delegate?.playVideoTrend(youtubeURL as NSString)
    }
}




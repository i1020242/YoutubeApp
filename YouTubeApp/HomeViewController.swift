//
//  ViewController.swift
//  YouTubeApp
//
//  Created by BDAFshare on 8/16/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit
import GoogleSignIn

let screenSize = UIScreen.mainScreen().bounds
let cellHomeId = "cellHomeId"
let cellTrendingId = "trendingCellId"
let cellUserId = "cellUserId"

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var searchVC:SearchViewController? = nil
    var downloadVC:DownloadViewController? = nil
    var loginVC:LoginViewController?=nil
    var videos :[Video] = {
        var video = Video()
        return [video]
    }()
    var test:Int?
    var menuBar : MenuBar = {
        var mb : MenuBar = MenuBar()
        
        return mb
    }()
    
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        setUpHome()
        setUpMenuBarView()
        setupNavigationBar()
        
    }
    
    func setUpHome()->Void{
        
        navigationItem.title = "Home"
        
        navigationController?.navigationBar.barTintColor = UIColor.redColor()
        collectionView!.backgroundColor = UIColor .whiteColor()
        
        let homeNib = UINib(nibName: "FeedCell", bundle: nil)
        collectionView?.registerNib(homeNib, forCellWithReuseIdentifier: cellHomeId)
        
        let trendingCell = UINib(nibName: "TrendingCollectionViewCell", bundle: nil)
        collectionView?.registerNib(trendingCell, forCellWithReuseIdentifier: cellTrendingId)
        
        let naviBarSize = self.navigationController!.navigationBar.frame.size.height
        collectionView!.contentInset = UIEdgeInsetsMake(naviBarSize+130, 0, 0, 0)
        collectionView!.pagingEnabled = true
    }
    
    func setUpMenuBarView()->Void{
        
        let a = UIApplication.sharedApplication().statusBarFrame.height
        let b = self.navigationController!.navigationBar.frame.size.height
        let sizeNavi = self.navigationController?.navigationBar.frame.height
        print(sizeNavi!)
        let mb:MenuBar = MenuBar(frame: CGRect(x: 0, y: a+b, width: screenSize.width, height: 70))
        mb.delegate = self
        view.addSubview(mb)
    }
    
    func setupNavigationBar()->Void {

        let imageBarSearch = UIImage(named: "search_icon")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageBarMore = UIImage(named: "nav_more_icon")?.imageWithRenderingMode(.AlwaysOriginal)
        let imageBarUser = UIImage(named: "account")?.imageWithRenderingMode(.AlwaysOriginal)
        
        let barButtonSearch:UIBarButtonItem = UIBarButtonItem(image: imageBarSearch, style: .Plain, target: self, action: #selector(handleSearch))
        let barButtonMore:UIBarButtonItem = UIBarButtonItem(image: imageBarMore, style: .Plain, target: self, action: #selector(handleDownload))
        let barButtonUser:UIBarButtonItem = UIBarButtonItem(image: imageBarUser, style: .Plain, target: self, action: #selector(handleUser))
        navigationItem.rightBarButtonItems = [barButtonMore, barButtonSearch]
        navigationItem.leftBarButtonItems = [barButtonUser]
    }

    func handleSearch()->Void {

        if searchVC == nil {
            searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        }
        
        searchVC?.delegate = self
        navigationItem.title = ""
        self.navigationController! .pushViewController(searchVC!, animated: true)
    }
    
    func handleDownload()->Void{
        
        if downloadVC == nil {
            downloadVC = DownloadViewController(nibName: "DownloadViewController", bundle: nil)
        }
        self.navigationController! .pushViewController(downloadVC!, animated: true)
    }
    func handleUser(){
        if loginVC == nil {
            loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        }
        self.navigationController?.pushViewController(loginVC!, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let indexOfView = scrollView.contentOffset.x / screenSize.width
        let intValue = Int(indexOfView)
        test = intValue
        switch intValue {
        case 0:
            let menuSubview = view?.subviews[1] as! MenuBar
            menuSubview.setCellWhenScrollMenuBar(0)
        case 1:
            let menuSubview = view?.subviews[1] as! MenuBar
            menuSubview.setCellWhenScrollMenuBar(1)
        case 2:
            let menuSubview = view?.subviews[1] as! MenuBar
            menuSubview.setCellWhenScrollMenuBar(2)
        case 3:
            let menuSubview = view?.subviews[1] as! MenuBar
            menuSubview.setCellWhenScrollMenuBar(3)
        default: break
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 3;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: screenSize.width , height: screenSize.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellHomeId, forIndexPath: indexPath) as! FeedCell
            cell.delegate = self
            
            return cell
        }
            
        else if indexPath.item == 2 {
            
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellTrendingId, forIndexPath: indexPath) as! TrendingCollectionViewCell
        cell.delegate = self
        
        return cell
    }
}

extension HomeViewController: MenuBarDelegate {
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = NSIndexPath(forItem: menuIndex, inSection: 0)
        collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
    }
}

extension HomeViewController: SearchViewControllerDelegate {
    func sendDataToDownload(searchData: SearchModel) {
        if downloadVC == nil {
            downloadVC = DownloadViewController(nibName: "DownloadViewController", bundle: nil)
        }
        downloadVC?.addDataDownloadArray(searchData)
    }
}

extension HomeViewController:TrendingCollectionViewCellDelegate {
    
    func playVideoTrend(strVideoId: NSString) {
        let playVideoVC:PlayVideoViewController = PlayVideoViewController(nibName: "PlayVideoViewController", bundle: nil)
        playVideoVC.videoID = strVideoId as String
        self.navigationController?.pushViewController(playVideoVC, animated: true)
    }
}

extension HomeViewController:FeedCellDelegate {
    
    func playVideoFeed(strVideoId: NSString) {
        let playVideoVC:PlayVideoViewController = PlayVideoViewController(nibName: "PlayVideoViewController", bundle: nil)
        playVideoVC.videoID = strVideoId as String
        self.navigationController?.pushViewController(playVideoVC, animated: true)
    }
}




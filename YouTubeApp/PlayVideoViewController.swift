//
//  PlayVideoViewController.swift
//  YouTubeApp
//
//  Created by BDAFshare on 12/2/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

class PlayVideoViewController: UIViewController, UIApplicationDelegate {

    @IBOutlet weak var m_webView: UIWebView!
    
    var videoID:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let youtubeURL: NSURL = NSURL(string: videoID!)!
        m_webView.loadRequest(NSURLRequest(URL: youtubeURL))
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(animated: Bool) {
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}

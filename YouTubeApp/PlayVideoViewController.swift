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
        let youtubeURL: URL = URL(string: videoID!)!
        m_webView.loadRequest(URLRequest(url: youtubeURL))
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var shouldAutorotate : Bool {
        return false
    }

}

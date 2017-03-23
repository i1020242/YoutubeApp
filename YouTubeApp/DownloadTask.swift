//
//  DownloadTask.swift
//  YouTubeApp
//
//  Created by BDAFshare on 12/15/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

class DownloadTask: NSObject {
    
    var urlDownload:String?
    var isDownloading = false
    var progress: Float = 0.0
    
    var downloadTask: URLSessionDownloadTask?
    var resumeData: Data?
    
    init(url: String) {
        self.urlDownload = url
    }
}

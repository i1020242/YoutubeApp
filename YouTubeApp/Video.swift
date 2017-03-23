//
//  Video.swift
//  YouTubeApp
//
//  Created by BDAFshare on 9/8/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

class Video: NSObject {
    
    var thumbnailImageName: String?
    var title             : String?
    var numberOfViews     : NSNumber?
    var uploadDate        : Date?
    var channel           : Channel?
}

class Channel: NSObject {
    var name            : String?
    var profileImageName: String?
}

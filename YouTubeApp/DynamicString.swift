//
//  DynamicString.swift
//  YouTubeApp
//
//  Created by BDAFshare on 2/9/17.
//  Copyright © 2017 TEST. All rights reserved.
//

import Foundation

class DynamicString {
    typealias Listener = String -> Void
    var listener: Listener?
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    var value: String {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: String) {
        value = v
    }
}
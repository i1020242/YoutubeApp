//
//  SearchProxy.swift
//  YouTubeApp
//
//  Created by BDAFshare on 12/1/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

class SearchProxy: NSObject {
    
    
    func fetchVideosSearch(strSearch:String, completion:DidGetResultClosure, error:ErrorClosure){
        let newStr = strSearch .stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet .URLHostAllowedCharacterSet())
        let youtubeURL = String(format: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&maxResults=10&type=video&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go", newStr!)
        fetchDataForStringYT("\(youtubeURL)", completion:completion, errorHandler:error)
    }
    
    func fetchDataForStringYT(urlString:String, completion:DidGetResultClosure, errorHandler:ErrorClosure){
        let url = NSURL(string: urlString)
        var videosSearch = [SearchModel]()
        
        var arrTemp = [AnyObject]()
        NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                if let items = json["items"] as? [[String:AnyObject]] {
                    
                    for item in items {
                        let searchModel = SearchModel()
                        if let videoId = item["id"] as? [String:AnyObject] {
                            if let videoIdd = videoId["videoId"] as? String {
                                searchModel.videoId = videoIdd
                            }
                        }
                        
                        if let snippets = item["snippet"] as? [String:AnyObject] {
                            if let title = snippets["title"] as? String {
                                searchModel.title = title
                                
                            }
                            if let channelTitle = snippets["channelTitle"] as? String {
                                searchModel.channelTitle = channelTitle
                            }
                            if let thumbnails = snippets["thumbnails"] as? [String:AnyObject] {
                                
                                
                                if let medium = thumbnails["medium"] as? [String:AnyObject]{
                                    
                                    if let url = medium["url"] as? String {
                                        searchModel.profileImage = url
                        
                                    }
                                }
                            }
                        }
                        arrTemp.append(searchModel)
                    }
                    videosSearch = arrTemp as! [SearchModel]
                }
                dispatch_async(dispatch_get_main_queue(), {
                    completion(result: videosSearch, errCode: "errorCode")
                })
            } catch let jsonError{
                errorHandler(errorClosure: jsonError)
            }
        }.resume()
    }
    
    func fetchMP3Link(urlString:String, completion:DidGetResultClosure, errorHandler:ErrorClosure) {
        
        if let url = NSURL(string: urlString) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                if let link = json["link"] as? String {
                    completion(result: link, errCode: "")
                }
            } catch let jsonError{
                errorHandler(errorClosure: jsonError)
                }
            }.resume()
        }
    }
}
    
    
    



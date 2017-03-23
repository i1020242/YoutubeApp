//
//  VideoProxy.swift
//  YouTubeApp
//
//  Created by BDAFshare on 9/16/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit
typealias DidGetResultClosure = (_ result:AnyObject, _ errCode:String)->()
typealias ErrorClosure = (_ errorClosure:Error)->()


class VideoProxy: NSObject {

    fileprivate let youtubeURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=vatvo&type=video&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go"

    func fetchVideos(_ tokenStr:String,completion:@escaping DidGetResultClosure, error:@escaping ErrorClosure){
        let urltokenString = "https://www.googleapis.com/youtube/v3/activities?part=snippet&home=true&maxResults=15&access_token=\(tokenStr)"
        fetchDataForKey(urltokenString, completion:completion, errorHandler:error)
    }
    
    func fetchTrending(_ completion:@escaping DidGetResultClosure, error:@escaping ErrorClosure){
        let urlTrending = "https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&regionCode=vn&maxResults=25&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go"
        fetchDataForKey(urlTrending, completion:completion, errorHandler:error)
    }
        
    func fetchDataForKey(_ urlString:String, completion:@escaping DidGetResultClosure, errorHandler:@escaping ErrorClosure){
        
        let url = URL(string: urlString)
        var videosSearch = [SearchModel]()
        
        var arrTemp = [AnyObject]()
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                if let items = json["items"] as? [[String:AnyObject]] {
                    
                    for item in items {
                        let searchModel = SearchModel()
                        if let videoId = item["id"] as? String {
                            searchModel.videoId = videoId
                            print("Id is \(videoId)")
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
                                        //print(url)
                                    }
                                }
                            }
                        }
                        arrTemp.append(searchModel)
                    }
                    videosSearch = arrTemp as! [SearchModel]
                }
                DispatchQueue.main.async(execute: {
                    completion(videosSearch as AnyObject, "errorCode")
                })
            } catch let jsonError{
                errorHandler(jsonError)
            }
            }) .resume()
    }
}

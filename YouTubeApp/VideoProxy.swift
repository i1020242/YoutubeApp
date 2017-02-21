//
//  VideoProxy.swift
//  YouTubeApp
//
//  Created by BDAFshare on 9/16/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit
typealias DidGetResultClosure = (result:AnyObject, errCode:String)->()
typealias ErrorClosure = (errorClosure:ErrorType)->()


class VideoProxy: NSObject {
    
    let baseURL = "https://s3-us-west-2.amazonaws.com/youtubeassets"
    private let youtubeURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=vatvo&type=video&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go"

    func fetchVideos(tokenStr:String,completion:DidGetResultClosure, error:ErrorClosure){
        let urltokenString = "https://www.googleapis.com/youtube/v3/activities?part=snippet&home=true&maxResults=15&access_token=\(tokenStr)"
        fetchDataForKey(urltokenString, completion:completion, errorHandler:error)
    }
    
    func fetchTrending(completion:DidGetResultClosure, error:ErrorClosure){
        let urlTrending = "https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&regionCode=vn&maxResults=25&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go"
        fetchDataForKey(urlTrending, completion:completion, errorHandler:error)
    }
        
    func fetchDataForKey(urlString:String, completion:DidGetResultClosure, errorHandler:ErrorClosure){
        
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
                dispatch_async(dispatch_get_main_queue(), {
                    completion(result: videosSearch, errCode: "errorCode")
                })
            } catch let jsonError{
                errorHandler(errorClosure: jsonError)
            }
            }.resume()
    }
}

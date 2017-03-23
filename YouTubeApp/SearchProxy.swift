//
//  SearchProxy.swift
//  YouTubeApp
//
//  Created by BDAFshare on 12/1/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

class SearchProxy: NSObject {
    
    
    func fetchVideosSearch(_ strSearch:String, completion:@escaping DidGetResultClosure, error:@escaping ErrorClosure){
        let newStr = strSearch .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        let youtubeURL = String(format: "https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&maxResults=10&type=video&key=AIzaSyC9doiHcYM5QMhEEwtnyLaIKsHs2UyR0Go", newStr!)
        fetchDataForStringYT("\(youtubeURL)", completion:completion, errorHandler:error)
    }
    
    func fetchDataForStringYT(_ urlString:String, completion:@escaping DidGetResultClosure, errorHandler:@escaping ErrorClosure){
        let url = URL(string: urlString)
        var videosSearch = [SearchModel]()
        
        var arrTemp = [AnyObject]()
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
                if let items = json?["items"] as? [[String:Any]] {
                    
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
                DispatchQueue.main.async(execute: {
                    completion(videosSearch as AnyObject, "errorCode")
                })
            } catch let jsonError{
                errorHandler(jsonError)
            }
        }) .resume()
    }
    
    func fetchMP3Link(_ urlString:String, completion:@escaping DidGetResultClosure, errorHandler:@escaping ErrorClosure) {
        
        if let url = URL(string: urlString) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                if let link = json["link"] as? String {
                    completion(link as AnyObject, "")
                }
            } catch let jsonError{
                errorHandler(jsonError)
                }
            }) .resume()
        }
    }
}
    
    
    



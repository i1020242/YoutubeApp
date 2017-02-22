    //
//  DownloadViewController.swift
//  YouTubeApp
//
//  Created by BDAFshare on 12/16/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

let CELL_ID_DOWNLOAD = "cellID"

class DownloadViewController: UIViewController {
    enum ErrorEncryption:ErrorType {
        case Empty
        case Short
    }
    @IBOutlet weak var tblDownload: UITableView!
    var activeDownloads = [String: DownloadTask]()
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("bgSessionConfiguration")
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var people = [NSManagedObject]()
    var player: AVAudioPlayer?
    
    var entries:[SearchModel] = []
    var arrDownload:[SearchModel] = []
    var test:SearchModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCell()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Playlist")
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            people = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
    func setupCell() {
        let nibName = UINib(nibName: "DownloadTableViewCell", bundle: nil)
        tblDownload.registerNib(nibName, forCellReuseIdentifier: CELL_ID_DOWNLOAD)
        tblDownload.dataSource = self
        tblDownload.delegate = self
    }
    
    //append at head and download at tail
    func addDataDownloadArray(video:SearchModel)->Void{
        arrDownload.insert(video, atIndex: 0)
        print("Array download \(arrDownload.count)")
        if arrDownload.count == 1 {
            startDownloadFromArr(arrDownload.last!)
        }
    }
    
    func startDownloadFromArr(video:SearchModel){
        
        if let urlString = video.linkDownload, url =  NSURL(string: urlString) {
            let download = DownloadTask(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            download.isDownloading = false
            activeDownloads[download.urlDownload!] = download
        }

    }
    
    func localFilePathForUrl(previewUrl: String) -> NSURL? {
        let newStr = previewUrl .stringByTrimmingCharactersInSet(NSCharacterSet .whitespaceCharacterSet()) + ".mp3"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let fullPath = documentsPath.stringByAppendingPathComponent(newStr)
        return NSURL(fileURLWithPath:fullPath)
    }
    
    
    func localFileExistsForTrack(track: SearchModel) -> Bool {
        if let urlString = track.title, localUrl = localFilePathForUrl(urlString) {
            print(localUrl)
            var isDir : ObjCBool = false
            if let path = localUrl.path {
                return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
            }
        }
        return false
    }

    // This method attempts to play the local file (if it exists) when the cell is tapped
    func playDownload(track: NSManagedObject) {
        let urlStringTemp = track.valueForKey("title") as? String
        //let urlString = urlStringTemp
        if let urlTemp = localFilePathForUrl(urlStringTemp!) {
            do {
                player = try AVAudioPlayer(contentsOfURL: urlTemp)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error)
            }
        }
    }
    
    func saveName(title: String, linkDownload: NSString) {
    
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Playlist",
                                                        inManagedObjectContext:managedContext)
        let person = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)
        
        person.setValue(title, forKey: "title")
        person.setValue(linkDownload, forKey: "linkDownload")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
}

extension DownloadViewController:UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tblDownload.dequeueReusableCellWithIdentifier(CELL_ID_DOWNLOAD, forIndexPath: indexPath) as! DownloadTableViewCell
        let arrModel = people[indexPath.row]
        cell.lblName.text = arrModel.valueForKey("title") as? String
        
        return cell
    }
}

extension DownloadViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number row is \(arrDownload.count)")
        return people.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = people[indexPath.row]
        playDownload(track)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.deleteObject(people[indexPath.row] as NSManagedObject)
            people.removeAtIndex(indexPath.row)
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
    
// MARK: - NSURLSessionDelegate

extension SearchViewController: NSURLSessionDelegate {
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                dispatch_async(dispatch_get_main_queue(), {
                    completionHandler()
                })
            }
        }
    }
}

extension DownloadViewController:NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString
        let download = activeDownloads[downloadUrl!]
        
        if download?.isDownloading == true {
            print("Ahihi, download finish")
            download?.isDownloading = false
            
            if let originalURL = arrDownload.last?.title,
                destinationURL = localFilePathForUrl(originalURL) {
                
                let fileManager = NSFileManager.defaultManager()
                do {
                    try fileManager.removeItemAtURL(destinationURL)
                } catch {
        
                }
                do {
                    try fileManager.copyItemAtURL(location, toURL: destinationURL)
                    let strURL = String(destinationURL)
                    
                    saveName((arrDownload.last?.title)!, linkDownload: strURL)
                    if self.tblDownload != nil {
                        self.tblDownload .reloadData()
                    }
                    
                } catch let error as NSError {
                    print("Could not copy file to disk: \(error.localizedDescription)")
                }
            }
            
            arrDownload.removeLast()
            if arrDownload.count > 0 {
    
                let temp = arrDownload
                startDownloadFromArr(temp.last!)
            }
        } else {
            let alertController = UIAlertController(title: "Warning", message:
                "Can't download this file", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            arrDownload.removeLast()
        }
        
        if let url = test?.linkDownload {
            activeDownloads[url] = nil
        }
        
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.URL?.absoluteString,
            download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let totalSize = NSByteCountFormatter.stringFromByteCount(totalBytesExpectedToWrite, countStyle: NSByteCountFormatterCountStyle.Binary)
            print(totalSize)
            if download.progress == 1 {
               download.isDownloading = true
            } else {
                download.isDownloading = false
            }
        }
    }
}

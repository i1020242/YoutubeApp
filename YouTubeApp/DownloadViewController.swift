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
    enum ErrorEncryption:Error {
        case empty
        case short
    }
    @IBOutlet weak var tblDownload: UITableView!
    var activeDownloads = [String: DownloadTask]()
    lazy var downloadsSession: Foundation.URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Playlist")
        
        do {
            let results =
                try managedContext.fetch(fetchRequest)
            people = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        player?.stop()
    }
    
    func setupCell() {
        let nibName = UINib(nibName: "DownloadTableViewCell", bundle: nil)
        tblDownload.register(nibName, forCellReuseIdentifier: CELL_ID_DOWNLOAD)
        tblDownload.dataSource = self
        tblDownload.delegate = self
    }
    
    //append at head and download at tail
    func addDataDownloadArray(_ video:SearchModel)->Void{
        arrDownload.insert(video, at: 0)
        print("Array download \(arrDownload.count)")
        if arrDownload.count == 1 {
            startDownloadFromArr(arrDownload.last!)
        }
    }
    
    func startDownloadFromArr(_ video:SearchModel){
        
        if let urlString = video.linkDownload, let url =  URL(string: urlString) {
            let download = DownloadTask(url: urlString)
            download.downloadTask = downloadsSession.downloadTask(with: url)
            download.downloadTask!.resume()
            download.isDownloading = false
            activeDownloads[download.urlDownload!] = download
        }

    }
    
    func localFilePathForUrl(_ previewUrl: String) -> URL? {
        let newStr = previewUrl .trimmingCharacters(in: CharacterSet.whitespaces) + ".mp3"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fullPath = documentsPath.appendingPathComponent(newStr)
        return URL(fileURLWithPath:fullPath)
    }
    
    func localFileExistsForTrack(_ track: SearchModel) -> Bool {
        if let urlString = track.title, let localUrl = localFilePathForUrl(urlString) {
            print(localUrl)
            var isDir : ObjCBool = false
            return FileManager.default.fileExists(atPath: localUrl.path, isDirectory: &isDir)
        }
        return false
    }

    // This method attempts to play the local file (if it exists) when the cell is tapped
    func playDownload(_ track: NSManagedObject) {
        let urlStringTemp = track.value(forKey: "title") as? String
        //let urlString = urlStringTemp
        if let urlTemp = localFilePathForUrl(urlStringTemp!) {
            do {
                player = try AVAudioPlayer(contentsOf: urlTemp)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error {
                print(error)
            }
        }
    }
    
    func saveName(_ title: String, linkDownload: NSString) {
    
        let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Playlist",
                                                        in:managedContext)
        let person = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblDownload.dequeueReusableCell(withIdentifier: CELL_ID_DOWNLOAD, for: indexPath) as! DownloadTableViewCell
        let arrModel = people[indexPath.row]
        cell.lblName.text = arrModel.value(forKey: "title") as? String
        
        return cell
    }
}

extension DownloadViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number row is \(arrDownload.count)")
        return people.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = people[indexPath.row]
        playDownload(track)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let appDel:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext
            context.delete(people[indexPath.row] as NSManagedObject)
            people.remove(at: indexPath.row)
            do {
                try context.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
    
// MARK: - NSURLSessionDelegate

extension SearchViewController: URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
        }
    }
}

extension DownloadViewController:URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let downloadUrl = downloadTask.originalRequest?.url?.absoluteString
        let download = activeDownloads[downloadUrl!]
        
        if download?.isDownloading == true {
            print("Ahihi, download finish")
            download?.isDownloading = false
            
            if let originalURL = arrDownload.last?.title,
                let destinationURL = localFilePathForUrl(originalURL) {
                
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(at: destinationURL)
                } catch {
        
                }
                do {
                    try fileManager.copyItem(at: location, to: destinationURL)
                    let strURL = String(describing: destinationURL)
                    
                    saveName((arrDownload.last?.title)!, linkDownload: strURL as NSString)
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
                "Can't download this file", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            arrDownload.removeLast()
        }
        
        if let url = test?.linkDownload {
            activeDownloads[url] = nil
        }
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        if let downloadUrl = downloadTask.originalRequest?.url?.absoluteString,
            let download = activeDownloads[downloadUrl] {
            download.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: ByteCountFormatter.CountStyle.binary)
            print(totalSize)
            if download.progress == 1 {
               download.isDownloading = true
            } else {
                download.isDownloading = false
            }
        }
    }
}

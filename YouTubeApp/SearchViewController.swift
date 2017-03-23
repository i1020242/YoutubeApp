//
//  SearchViewController.swift
//  YouTubeApp
//
//  Created by BDAFshare on 11/8/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit
protocol SearchViewControllerDelegate {
    func sendDataToDownload(_ searchModel:SearchModel)
}


let CELL_ID = "cellID"
let DOMAIN_MP3 = "http://www.youtubeinmp3.com/fetch/?format=JSON&video=http://www.youtube.com/watch?v="

class SearchViewController: UIViewController {
    
    var delegate:SearchViewControllerDelegate?
    var activeDownloads:[String:AnyObject]?
    var arrDownload:[SearchModel]?
    
    var abc:[SearchModel] = []
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topsearchContraint: NSLayoutConstraint!
    var searchModel:[SearchModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableCell()
        setupTxtSearch()
        //loadData()
        
    }
    
    func setupTxtSearch() {
        topsearchContraint.constant = 80;
        self.txtSearch.delegate = self
        self.txtSearch.returnKeyType = UIReturnKeyType .go
    }
    
    fileprivate func setupTableCell() {
        let nibName = UINib(nibName: "SearchTableViewCell", bundle: nil)
        self.tblView .register(nibName, forCellReuseIdentifier: CELL_ID)
        self.tblView .backgroundColor = UIColor.clear
        self.tblView.delegate = self
        self.tblView.dataSource = self
    }
    
    @IBAction func searchData(_ sender: AnyObject) {
        let strSearch = txtSearch.text
        loadDataSearch(strSearch!)
        //loadData()
    }
    
    func loadDataSearch(_ strSearch:String){
        //SwiftLoading().showLoading()
        ShareData.shareInstance.videoSearch .fetchVideosSearch(strSearch, completion: { (result, errCode) in
            self.searchModel = result as? [SearchModel]
                if self.searchModel != nil {
                    //SwiftLoading().hideLoading()
                    self.tblView .reloadData()
                }
            }) { (errorClosure) in
                
        }
    }
}

extension SearchViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchModel == nil {
            return 0
        }
        return searchModel!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblView .dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! SearchTableViewCell
        
        cell.delegate = self
        let videoSearch:SearchModel = self.searchModel![indexPath.row]
        
        //title
        cell.lblName.numberOfLines = 0
        cell.lblName.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.lblName.text = videoSearch.title
        
        //title
        cell.lblChannel.numberOfLines = 0
        cell.lblChannel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.lblChannel.text = videoSearch.channelTitle
        
        //img
        _ = videoSearch.profileImage
        return cell
    }
}

extension SearchViewController:UITableViewDelegate, UIApplicationDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let abc:SearchModel = self.searchModel![indexPath.row]
        let videoID:String = abc.videoId!
        
        let youtubeURL = "https://www.youtube.com/embed/\(videoID)"

        let playVideoVC:PlayVideoViewController = PlayVideoViewController(nibName: "PlayVideoViewController", bundle: nil)
        playVideoVC.videoID = youtubeURL
        self.navigationController! .pushViewController(playVideoVC, animated: true)
    }
}

extension SearchViewController:SearchTableViewCellDelegate {
    
    func downloadTapped(_ sender: AnyObject) {
        
        let cell = sender as! SearchTableViewCell
        //cell.btnDownload.hidden = true
        if let indexPath = tblView.indexPath(for: cell) {
            
            let video = searchModel?[indexPath.row]
            
            
            let videodownloadLink = DOMAIN_MP3 + (video?.videoId)!
            ShareData.shareInstance.videoSearch .fetchMP3Link(videodownloadLink, completion: {(result, errCode) in
                let linkDown = result as! String
                video?.linkDownload = linkDown
                self.delegate?.sendDataToDownload(video!)
                }, errorHandler: { (errorClosure) in
                    let alert = UIAlertController(title: "Alert", message: "Error get API", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("Error get API")
            })
        }
    }
}

extension SearchViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtSearch {
            textField.resignFirstResponder()
            let strSearch = txtSearch.text
            loadDataSearch(strSearch!)
        }
        return true
    }
}







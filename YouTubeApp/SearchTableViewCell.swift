//
//  SearchTableViewCell.swift
//  YouTubeApp
//
//  Created by BDAFshare on 11/9/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate {
    func downloadTapped(_ sender: AnyObject)
}

class SearchTableViewCell: UITableViewCell {
    
    var delegate:SearchTableViewCellDelegate?

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblChannel: UILabel!
    @IBOutlet weak var imgSearch: UIImageView!
    @IBOutlet weak var btnDownload: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func downloadTapped(_ sender: AnyObject) {
        
        delegate?.downloadTapped(self)
    }
}

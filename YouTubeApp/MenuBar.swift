//
//  MenuBar.swift
//  YouTubeApp
//
//  Created by BDAFshare on 9/6/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

public protocol MenuBarDelegate : NSObjectProtocol {
    func scrollToMenuIndex(_ index:Int)
    
}

let cellMenu = "cellMenu"
class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate:MenuBarDelegate?
    lazy var horizontalBarView:UIView = {
            let horizontalBarView = UIView()
            var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
            horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        
            horizontalBarView.frame = CGRect(x: 0, y: 47, width: screenSize.width/3, height: 5)
            horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
            return horizontalBarView
        }()
    
    lazy var collectionView : UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let collectionMenu = CGRect(x: 0, y: 0, width: screenSize.width, height: 50)
        let cv = UICollectionView(frame: collectionMenu, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    
    let cells:[String] = ["home", "trending", "subscriptions"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let nibName = UINib(nibName: "MenuBarCellCollectionViewCell", bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: cellMenu)
        collectionView.backgroundColor = UIColor.red
        addSubview(collectionView)
        addSubview(horizontalBarView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellMenu, for: indexPath)
        as! MenuBarCellCollectionViewCell
        cell.img.image = UIImage(named: cells[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: screenSize.width/3, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.item {
        case 0: setCellWhenScrollMenuBar(0)
        break;
        case 1: setCellWhenScrollMenuBar(1)
        break;
        case 2: setCellWhenScrollMenuBar(2)
        break;
        default: break
    }
        
        UIView.animate(withDuration: 0.75, delay: 0.75, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
            }, completion: nil)
        
        delegate?.scrollToMenuIndex(indexPath.item)
        
    }
    
    func setCellWhenScrollMenuBar(_ value:CGFloat) {
        
        horizontalBarView.frame = CGRect(x: value * CGFloat(screenSize.width/3), y: 47, width: screenSize.width/3, height: 5)
    }
    
}

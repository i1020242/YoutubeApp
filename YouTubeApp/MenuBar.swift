//
//  MenuBar.swift
//  YouTubeApp
//
//  Created by BDAFshare on 9/6/16.
//  Copyright © 2016 TEST. All rights reserved.
//

import UIKit

public protocol MenuBarDelegate : NSObjectProtocol {
    func scrollToMenuIndex(index:Int)
    
}

let cellMenu = "cellMenu"
class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate:MenuBarDelegate?
    lazy var horizontalBarView:UIView = {
            let horizontalBarView = UIView()
            var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
            horizontalBarView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        
            horizontalBarView.frame = CGRectMake(0, 47, screenSize.width/3, 5)
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
        collectionView.registerNib(nibName, forCellWithReuseIdentifier: cellMenu)
        collectionView.backgroundColor = UIColor .redColor()
        addSubview(collectionView)
        addSubview(horizontalBarView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellMenu, forIndexPath: indexPath)
        as! MenuBarCellCollectionViewCell
        cell.img.image = UIImage(named: cells[indexPath.item])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSizeMake(screenSize.width/3, 50)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.item {
        case 0: setCellWhenScrollMenuBar(0)
        break;
        case 1: setCellWhenScrollMenuBar(1)
        break;
        case 2: setCellWhenScrollMenuBar(2)
        break;
        default: break
        }
        
        UIView.animateWithDuration(0.75, delay: 0.75, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: {
            self.layoutIfNeeded()
            }, completion: nil)
        
        delegate?.scrollToMenuIndex(indexPath.item)
        
    }
    
    func setCellWhenScrollMenuBar(value:CGFloat) {
        
        horizontalBarView.frame = CGRectMake(value * CGFloat(screenSize.width/3), 47, screenSize.width/3, 5)
    }
    
}

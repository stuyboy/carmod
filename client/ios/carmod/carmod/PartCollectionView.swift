//
//  PartCollectionView.swift
//  carmod
//
//  Created by Thad Hwang on 1/11/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol PartCollectionViewDelegate: class {
  func tappedPart(image: UIImage, isSelected: Bool)
}

class PartCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
  var partObjects: [PartObject]! {
    didSet {
      self.reloadData()
    }
  }
  var selectedIndexPath: NSIndexPath!
  
  private var thumbnailSize: CGFloat = 0.0
  
  weak var partCollectionViewDelegate: PartCollectionViewDelegate?
  
  init(frame: CGRect) {
    let OFFSET: CGFloat = 4.0
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = OFFSET/2
    layout.minimumLineSpacing = OFFSET
    self.thumbnailSize = (frame.width-OFFSET*4)/3
    layout.itemSize = CGSize(width: self.thumbnailSize, height: self.thumbnailSize+THUMBNAIL_LABEL_HEIGHT)
    
    super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height), collectionViewLayout: layout)
    
    self.delegate = self
    self.dataSource = self
    self.registerClass(PartCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "PartCollectionViewCell")
    
    self.contentInset = UIEdgeInsets(top: OFFSET, left: OFFSET/2, bottom: OFFSET, right: OFFSET/2)
    self.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
  }
  
  // MARK: - Private methods
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    var count = 0
    
    if let partObjects = self.partObjects {
      count =  partObjects.count
    }
    
    if count == 0 {
      MBProgressHUD.showHUDAddedTo(self, animated: true)
    } else {
      MBProgressHUD.hideHUDForView(self, animated: true)
    }
    
    return count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PartCollectionViewCell", forIndexPath: indexPath) as! PartCollectionViewCell
    
    if self.selectedIndexPath != nil && self.selectedIndexPath == indexPath {
      cell.selectCell()
      
      let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
      scaleAnimation.duration = TRANSITION_TIME_NORMAL
      scaleAnimation.fromValue = 1.0
      scaleAnimation.toValue = 1.04
      scaleAnimation.repeatCount = 1
      scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
      cell.layer.addAnimation(scaleAnimation, forKey: "scale")
    } else {
      cell.deselectCell()
    }
    
    let partObject = self.partObjects[indexPath.row]
    cell.setThumbnailImageFromURL(NSURL(string: partObject.imageURL)!)
    cell.setPartName(PartManager.sharedInstance.generateDisplayName(partObject))
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let shouldDeselect = self.selectedIndexPath != nil && self.selectedIndexPath == indexPath
    
    if shouldDeselect {
      self.selectedIndexPath = nil
    } else {
      self.selectedIndexPath = indexPath
    }
    
    collectionView.reloadData()
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    
  }


}

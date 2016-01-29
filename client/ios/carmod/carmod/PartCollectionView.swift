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
  func tappedPart(partObject: PartObject, isSelected: Bool)
}

class PartCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
  var partObjects: [PartObject]! {
    didSet {
      self.reloadData()
    }
  }
  var selectedIndexPath: NSIndexPath!
  var isSelectable: Bool = true
  
  private var thumbnailSize: CGFloat = 0.0
  private var emptyView: UIView!
  
  weak var partCollectionViewDelegate: PartCollectionViewDelegate?
  
  init(frame: CGRect, isSelectable: Bool) {
    let OFFSET: CGFloat = 4.0
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = OFFSET/2
    layout.minimumLineSpacing = OFFSET
    self.thumbnailSize = (frame.width-OFFSET*4)/3
    layout.itemSize = CGSize(width: self.thumbnailSize, height: self.thumbnailSize+THUMBNAIL_LABEL_HEIGHT)
    
    super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height), collectionViewLayout: layout)
    
    self.isSelectable = isSelectable
    
    self.delegate = self
    self.dataSource = self
    self.registerClass(PartCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "PartCollectionViewCell")
    
    self.contentInset = UIEdgeInsets(top: OFFSET, left: OFFSET/2, bottom: OFFSET, right: OFFSET/2)
    self.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    
    self.emptyView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
    self.emptyView.backgroundColor = UIColor.whiteColor()
    self.emptyView.hidden = true
    self.addSubview(self.emptyView)
    
    let emptyLabel = UILabel()
    emptyLabel.font = UIFont(name: FONT_BOLD, size: FONTSIZE_LARGE)
    emptyLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    emptyLabel.textAlignment = .Center
    emptyLabel.text = "No matching parts found."
    emptyLabel.sizeToFit()
    emptyLabel.frame.origin = CGPoint(x: self.emptyView.frame.width/2-emptyLabel.frame.width/2, y: OFFSET_XLARGE*4)
    self.emptyView.addSubview(emptyLabel)
  }
  
  // MARK: - Private methods
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    var count = 0
    
    if let partObjects = self.partObjects {
      count = partObjects.count
    }
    
    self.emptyView.hidden = count > 0
    
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
    
    if let imageURL = partObject.imageURL {
      cell.setThumbnailImageFromURL(NSURL(string: imageURL)!)
    }
    cell.setPartName(PartManager.sharedInstance.generateDisplayName(partObject))
    
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if self.isSelectable {
      let shouldDeselect = self.selectedIndexPath != nil && self.selectedIndexPath == indexPath
      var indexPaths: [NSIndexPath] = []
      indexPaths.append(indexPath)
      
      if shouldDeselect {
        self.selectedIndexPath = nil
      } else {
        if self.selectedIndexPath != nil {
          indexPaths.append(self.selectedIndexPath)
        }
        self.selectedIndexPath = indexPath
      }
      
      let partObject = self.partObjects[indexPath.row]
      if let delegate = self.partCollectionViewDelegate {
        delegate.tappedPart(partObject, isSelected: !shouldDeselect)
      }
      
      self.reloadItemsAtIndexPaths(indexPaths)
    }
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    
  }
}

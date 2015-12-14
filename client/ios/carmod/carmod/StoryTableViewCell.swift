//
//  StoryTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class StoryTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
  private var photoTable: UITableView!
  
  var tags: Array<Array<TagObject>>!
  var photos: [PFObject]! {
    didSet {
      self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
    
      self.tags = Array(count:self.photos.count, repeatedValue:[TagObject]())
      
      for var i = 0; i < self.tags.count; i++ {
        self.loadTags(self.photos[i], atIndex: i)
      }
      
      self.photoTable.reloadData()
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.whiteColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.photoTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: gPhotoSize, height: gPhotoSize))
    self.photoTable.registerClass(PhotoTableViewCell.classForCoder(), forCellReuseIdentifier: "PhotoTableViewCell")
    self.photoTable.clipsToBounds = true
    self.photoTable.backgroundColor = UIColor.whiteColor()
    self.photoTable.separatorColor = UIColor.clearColor()
    self.photoTable.rowHeight = gPhotoSize
    self.photoTable.delegate = self
    self.photoTable.dataSource = self
    self.photoTable.bounces = false
    self.photoTable.pagingEnabled = true
    self.photoTable.allowsSelection = false
    if self.photoTable.respondsToSelector("separatorInset") {
      self.photoTable.separatorInset = UIEdgeInsetsZero
    }
    self.photoTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI * 0.5))
    self.addSubview(self.photoTable)
  }
  
  // MARK:- UITableViewDelegate  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.photos.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
    cell.isInteractionEnabled = false
    
    let photoObject = self.photos[indexPath.row]
    cell.photo.file = photoObject.objectForKey(kPhotoImageKey) as? PFFile
    cell.tags = self.tags[indexPath.row]
    cell.loadPhoto()
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  // 
  func loadTags(photo: PFObject, atIndex: Int) {
    let query: PFQuery = PAPUtility.queryForAnnotationsOnPhoto(photo, cachePolicy: PFCachePolicy.NetworkOnly)
    if let annotations = query.findObjects() {
      for annotation in annotations {
        let tagObject: TagObject = TagObject()
        
        let partObject: PartObject = PartObject()
        partObject.brand = annotation.objectForKey(kAnnotationBrandKey) as! String
        partObject.model = annotation.objectForKey(kAnnotationModelKey) as! String
        partObject.partNumber = annotation.objectForKey(kAnnotationPartNumberKey) as! String

        tagObject.partObject = partObject
        let coordinates = annotation.objectForKey(kAnnotationCoordinatesKey) as! [CGFloat]
        tagObject.coordinates = CGPoint(x: coordinates[0], y: coordinates[1])
        
        self.tags[atIndex].append(tagObject)
      }
    }
  }

  override func prepareForReuse() {
    self.photos.removeAll()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

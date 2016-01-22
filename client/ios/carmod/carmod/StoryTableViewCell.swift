//
//  StoryTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

protocol StoryTableViewCellDelegate: class {
  func tappedPhoto(indexPath: NSIndexPath)
}

class StoryTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
  weak var delegate: StoryTableViewCellDelegate?
  var indexPath: NSIndexPath!
  private var photoTable: UITableView!
  private var pageControl: UIPageControl!
  private var photoCount: UILabel!
  
  var tags: Array<Array<TagObject>>!
  var photos: [PFObject]! {
    didSet {
      self.pageControl.hidden = self.photos.count == 1
      self.photoCount.hidden = self.photos.count == 1
      
      self.pageControl.numberOfPages = self.photos.count
      self.photoCount.text = self.photos.count == 2 ? "+1 more photo" : self.photos.count > 2 ? "+\(self.photos.count-1) more photos" : ""
      
      self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
    
      self.tags = Array(count:self.photos.count, repeatedValue:[TagObject]())
      
      for var i = 0; i < self.tags.count; i++ {
        self.loadPhotoAttributes(self.photos[i], atIndex: i)
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
    if self.photoTable.respondsToSelector("separatorInset") {
      self.photoTable.separatorInset = UIEdgeInsetsZero
    }
    self.photoTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI * 0.5))
    self.addSubview(self.photoTable)
    
    self.pageControl = UIPageControl()
    self.pageControl.currentPage = 0
    self.pageControl.pageIndicatorTintColor = UIColor.whiteColor()
    self.pageControl.currentPageIndicatorTintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.pageControl.userInteractionEnabled = true
    self.pageControl.addTarget(self, action: "onPageControlChange:", forControlEvents: UIControlEvents.ValueChanged)
    self.addSubview(self.pageControl)
    
    self.photoCount = UILabel()
    self.photoCount.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.photoCount.textAlignment = .Center
    self.photoCount.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.photoCount.alpha = 0.8
    self.photoCount.layer.cornerRadius = 8.0
    self.photoCount.clipsToBounds = true
    self.photoCount.backgroundColor = UIColor.whiteColor()
    self.addSubview(self.photoCount)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let CONTROL_WIDTH: CGFloat = 200.0
    let CONTROL_HEIGHT: CGFloat = 40.0
    self.pageControl.frame = CGRect(x: self.bounds.width/2-CONTROL_WIDTH/2, y: self.bounds.height-CONTROL_HEIGHT-OFFSET_SMALL, width: CONTROL_WIDTH, height: CONTROL_HEIGHT)
    
    let LABEL_WIDTH: CGFloat = 120.0
    let LABEL_HEIGHT: CGFloat = 30.0
    self.photoCount.frame = CGRect(x: self.bounds.width/2-LABEL_WIDTH/2, y: self.pageControl.frame.origin.y-LABEL_HEIGHT, width: LABEL_WIDTH, height: LABEL_HEIGHT)
  }
  
  // MARK:- UITableViewDelegate  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.photos.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
    cell.selectionStyle = .None
    cell.isInteractionEnabled = false
    
    let photoObject = self.photos[indexPath.row]
    cell.photo.file = photoObject.objectForKey(kPhotoImageKey) as? PFFile
    cell.tags = self.tags[indexPath.row]
    cell.loadPhoto()
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let delegate = self.delegate {
      delegate.tappedPhoto(self.indexPath)
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
    for indexPath in indexPaths {
      self.pageControl.currentPage = indexPath.row
      if indexPath.row > 0 {
        UIView.animateWithDuration(TRANSITION_TIME_FAST, animations: { () -> Void in
          self.photoCount.alpha = 0.0
        })
      }

      break
    }
  }
  
  func loadPhotoAttributes(photo: PFObject, atIndex: Int) {
    var query: PFQuery = PAPUtility.queryForAnnotationsOnPhoto(photo, cachePolicy: PFCachePolicy.NetworkOnly)
    let annotationObjects = query.findObjects()
    for annotationObject in annotationObjects! {
      let tagObject: TagObject = TagObject()
      
      let partObject: PartObject = PartObject()
      partObject.brand = annotationObject.objectForKey(kAnnotationBrandKey) as! String
      partObject.model = annotationObject.objectForKey(kAnnotationModelKey) as! String
      partObject.partNumber = annotationObject.objectForKey(kAnnotationPartNumberKey) as! String
      
      tagObject.partObject = partObject
      let coordinates = annotationObject.objectForKey(kAnnotationCoordinatesKey) as! [CGFloat]
      tagObject.coordinates = CGPoint(x: coordinates[0], y: coordinates[1])
      
      self.tags[atIndex].append(tagObject)
      
      StoryCache.sharedCache.setAttributesForAnnotation(annotationObject as! PFObject, coordinateX: Double(coordinates[0]), coordinateY: Double(coordinates[1]), brand: partObject.brand, model: partObject.model, productCode: partObject.partNumber)
    }
    
    var description: String = ""
    var likers = [PFUser]()
    var commenters = [PFUser]()
    var isLikedByCurrentUser = false
    
    query = PAPUtility.queryForActivitiesOnPhoto(photo, cachePolicy: PFCachePolicy.NetworkOnly)
    let activityObjects = query.findObjects()
    for activity in activityObjects! {
      if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeDescription {
        description = activity.objectForKey(kPAPActivityContentKey) as! String
      } else if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike && activity.objectForKey(kPAPActivityFromUserKey) != nil {
        likers.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
      } else if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeComment && activity.objectForKey(kPAPActivityFromUserKey) != nil {
        commenters.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
      }
      
      if ((activity.objectForKey(kPAPActivityFromUserKey) as? PFObject)?.objectId) == PFUser.currentUser()!.objectId {
        if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike {
          isLikedByCurrentUser = true
        }
      }
    }
    
    StoryCache.sharedCache.setAttributesForPhoto(photo, annotations: annotationObjects as! [PFObject], description: description, likers: likers, commenters: commenters, likedByCurrentUser: isLikedByCurrentUser)

  }
  
  // MARK:- Callbacks
  func onPageControlChange(sender: UIPageControl) {
    let indexPath = NSIndexPath(forRow: sender.currentPage, inSection: 0)
    if indexPath.row > 0 {
      UIView.animateWithDuration(TRANSITION_TIME_FAST, animations: { () -> Void in
        self.photoCount.alpha = 0.0
      })
    }
    self.photoTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
  }

  override func prepareForReuse() {
    self.photos.removeAll()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

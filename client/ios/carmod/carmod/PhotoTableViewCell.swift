//
//  PhotoTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import ParseUI
import MRProgress

class TagObject: NSObject {
  var id: Int!
  var partObject: PartObject!
  var tagView: TagView!
  var removeButton: UIButton!
}

protocol PhotoTableViewCellDelegate: class {
  func changedTags(tagCount: Int)
  func tappedPhoto()
  func removedTag()
}

class PhotoTableViewCell: UITableViewCell {
  weak var delegate: PhotoTableViewCellDelegate?
  
  var photo: PFImageView!
  
  private var progressView: MRProgressOverlayView!
  private var currentTagView: TagView!
  private var tagID: Int = 0
  private var tags: [TagObject]! {
    didSet {
      if let delegate = self.delegate {
        delegate.changedTags(self.tags.count)
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    PartManager.sharedInstance.eventManager.listenTo(EVENT_PICKER_CANCELLED) { () -> () in
      self.currentTagView.alpha = 0.0
    }
    
    self.backgroundColor = UIColor.blackColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.tags = []
    
    self.photo = PFImageView()
    self.photo.contentMode = UIViewContentMode.ScaleAspectFit
    self.photo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapPhoto:"))
    self.photo.userInteractionEnabled = true
    self.addSubview(self.photo)
    
    self.currentTagView = TagView(frame: CGRect(x: 0.0, y: 0.0, width: TAG_WIDTH, height: TAG_FIELD_HEIGHT+TAG_ARROW_SIZE), arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
    self.currentTagView.alpha = 0.0
    self.currentTagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
    
    let removeButton = self.currentTagView.removeButton
    removeButton.tag = -1
    removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
    self.photo.addSubview(self.currentTagView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
    self.photo.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.height)
    self.photo.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  func loadPhoto() {
    self.progressView = MRProgressOverlayView.showOverlayAddedTo(self.photo, title: "Loading...", mode: MRProgressOverlayViewMode.DeterminateHorizontalBar, animated: true)
    self.progressView.titleLabel?.font = UIFont(name: FONT_BOLD, size: FONTSIZE_MEDIUM)
    self.progressView.titleLabel?.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    
    self.photo.loadInBackground({ (image, error) -> Void in
      if error != nil {
        return
      }
  
      self.progressView.dismiss(true)
      
      }) { (percentDone) -> Void in
        self.progressView.setProgress(Float(percentDone/100), animated: true)
    }
  }
  
  func addTag(partObject: PartObject) {
    print("self.currentTagView.alpha = \(self.currentTagView.alpha)")
    if self.currentTagView.alpha != 0.0 {
      print("ADDING!")
      self.currentTagView.alpha = 0.0
      
      let tagObject = TagObject()
      tagObject.id = tagID++
      
      let tagView = TagView(frame: self.currentTagView.frame, arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
      tagView.alpha = 0.8
      tagView.tagLabel.text = PartManager.sharedInstance.generateDisplayName(partObject)
      tagView.toggleRemoveVisibility(true)
      tagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapTagView:"))
      tagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
      
      tagObject.removeButton = tagView.removeButton
      tagObject.removeButton.tag = tagObject.id
      tagObject.removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
      
      self.photo.addSubview(tagView)
      
      tagObject.partObject = partObject
      tagObject.tagView = tagView
      
      self.tags.append(tagObject)
    }
  }
  
  // MARK:- Callbacks
  func onTapPhoto(sender: UITapGestureRecognizer) {
    let point = sender.locationInView(self.photo)
    self.currentTagView.frame.origin.x = point.x-TAG_WIDTH/2
    self.currentTagView.frame.origin.y = point.y
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.currentTagView.alpha = 0.8
    }
    
    for tagObject in self.tags {
      tagObject.tagView.toggleRemoveVisibility(true)
    }
    
    if let delegate = self.delegate {
      delegate.tappedPhoto()
    }
  }
  
  func onRemoveTag(sender: UIButton) {
    if sender.tag == -1 {
      self.currentTagView.alpha = 0.0
      if let delegate = self.delegate {
        delegate.removedTag()
      }
    } else {
      for var i = 0; i < self.tags.count; i++ {
        let tagObject = self.tags[i]
        if tagObject.id == sender.tag {
          self.tags.removeAtIndex(i)
          tagObject.tagView.alpha = 0.0
          
          break
        }
      }
    }
  }
  
  func onDragTag(sender: UIPanGestureRecognizer) {
    let translation = sender.translationInView(self.photo)
    
    if sender.state == UIGestureRecognizerState.Began {
    } else if sender.state == UIGestureRecognizerState.Changed {
      sender.view!.center.x = sender.view!.center.x+translation.x
      sender.view!.center.y = sender.view!.center.y+translation.y
      
      sender.setTranslation(CGPointZero, inView: self.photo)
    } else if sender.state == UIGestureRecognizerState.Ended {
      
    }
  }
  
  func onTapTagView(sender: UITapGestureRecognizer) {
    let tappedTagView: TagView = sender.view as! TagView
    tappedTagView.toggleRemoveVisibility(false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK:- Debug methods
  func printTags() {
    print("Number of tags = \(self.tags.count)")
    for var i = 0; i < self.tags.count; i++ {
      let tagObject: TagObject = self.tags[i]
      let partObject: PartObject = tagObject.partObject
      
      print("Part Object Brand = \(partObject.brand), Model = \(partObject.model)")
    }
  }

}

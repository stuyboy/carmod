//
//  PhotoTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import ParseUI
import MRProgress

protocol PhotoTableViewCellDelegate: class {
  func changedCoordinates(tagIndex: Int, coordinates: CGPoint)
  func tappedPhoto()
  func removedTag(tagIndex: Int)
}

class PhotoTableViewCell: UITableViewCell {
  weak var delegate: PhotoTableViewCellDelegate?
  
  var isInteractionEnabled: Bool = true {
    didSet {
      self.contentView.userInteractionEnabled = isInteractionEnabled
    }
  }
  var photo: PFImageView!
  var currentTagView: TagView!
  var tags: [TagObject]! {
    didSet {
      for var i = 0; i < tags.count; i++ {
        let tagView = TagView(frame: CGRect(x: tags[i].coordinates.x, y: tags[i].coordinates.y, width: TAG_WIDTH, height: TAG_FIELD_HEIGHT+TAG_ARROW_SIZE), arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
        tagView.alpha = 0.8
        tagView.tagLabel.text = PartManager.sharedInstance.generateDisplayName(tags[i].partObject)
        tagView.toggleRemoveVisibility(true)
        
        if self.isInteractionEnabled {
          tagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapTagView:"))
          tagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
        }
        
        tagView.removeButton.tag = i
        tagView.removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
        
        self.contentView.addSubview(tagView)
      }
    }
  }
  private var progressView: MRProgressOverlayView!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    PartManager.sharedInstance.eventManager.listenTo(EVENT_PICKER_CANCELLED) { () -> () in
      self.currentTagView.alpha = 0.0
    }
    
    self.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    
    self.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
    self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapPhoto:"))
    self.contentView.userInteractionEnabled = true
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.tags = []
    
    self.photo = PFImageView()
    self.photo.contentMode = UIViewContentMode.ScaleAspectFit
    self.contentView.addSubview(self.photo)
    
    self.currentTagView = TagView(frame: CGRect(x: 0.0, y: 0.0, width: TAG_WIDTH, height: TAG_FIELD_HEIGHT+TAG_ARROW_SIZE), arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
    self.currentTagView.alpha = 0.0
    self.currentTagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
    
    self.currentTagView.removeButton.tag = -1
    self.currentTagView.removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
    self.contentView.addSubview(self.currentTagView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
   
    self.photo.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.height)
  }
  
  override func prepareForReuse() {
    for view in self.contentView.subviews {
      if view.isKindOfClass(TagView) && view != self.currentTagView {
        view.removeFromSuperview()
      }
    }
  }
  
  func loadPhoto() {
//    self.progressView = MRProgressOverlayView.showOverlayAddedTo(self.photo, title: "Loading...", mode: MRProgressOverlayViewMode.DeterminateHorizontalBar, animated: true)
//    self.progressView.titleLabel?.font = UIFont(name: FONT_BOLD, size: FONTSIZE_MEDIUM)
//    self.progressView.titleLabel?.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    
    self.photo.loadInBackground({ (image, error) -> Void in
      if error != nil {
        return
      }
  
//      self.progressView.dismiss(true)
      
      }) { (percentDone) -> Void in
//        self.progressView.setProgress(Float(percentDone/100), animated: true)
    }
  }
    
  // MARK:- Callbacks
  func onTapPhoto(sender: UITapGestureRecognizer) {
    let point = sender.locationInView(self.contentView)
    self.currentTagView.frame.origin.x = point.x-TAG_WIDTH/2
    self.currentTagView.frame.origin.y = point.y
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.currentTagView.alpha = 0.8
    }
    
    if let delegate = self.delegate {
      delegate.tappedPhoto()
    }
  }
  
  func onRemoveTag(sender: UIButton) {
    if sender.tag == -1 {
      self.currentTagView.alpha = 0.0
    } else {
      for view in self.contentView.subviews {
        if view.isKindOfClass(TagView) {
          let tagView = view as! TagView
          if tagView.removeButton == sender {
            tagView.removeFromSuperview()
          }
        }
      }
    }
    
    if let delegate = self.delegate {
      delegate.removedTag(sender.tag)
    }
  }
  
  func onDragTag(sender: UIPanGestureRecognizer) {
    let translation = sender.translationInView(self.contentView)
    let tagView: TagView = sender.view! as! TagView
    
    if sender.state == UIGestureRecognizerState.Began {
    } else if sender.state == UIGestureRecognizerState.Changed {
      sender.view!.center.x = sender.view!.center.x+translation.x
      sender.view!.center.y = sender.view!.center.y+translation.y
      sender.setTranslation(CGPointZero, inView: self.contentView)
    } else if sender.state == UIGestureRecognizerState.Ended && tagView.removeButton.tag != -1 {
      if let delegate = self.delegate {
        delegate.changedCoordinates(tagView.removeButton.tag, coordinates: sender.view!.frame.origin)
      }
    }
  }
  
  func onTapTagView(sender: UITapGestureRecognizer) {
    let tappedTagView: TagView = sender.view as! TagView
    tappedTagView.toggleRemoveVisibility(false)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
//  // MARK:- Debug methods
//  func printTags() {
//    print("Number of tags = \(self.tags.count)")
//    for var i = 0; i < self.tags.count; i++ {
//      let tagObject: TagObject = self.tags[i]
//      let partObject: PartObject = tagObject.partObject
//      
//      print("Part Object Brand = \(partObject.brand), Model = \(partObject.model)")
//    }
//  }

}

//
//  PhotoTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import ParseUI
import MRProgress

class PhotoTableViewCell: UITableViewCell {
  var photo: PFImageView!
  private var progressView: MRProgressOverlayView!
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.blackColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.photo = PFImageView()
    self.addSubview(self.photo)
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
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}

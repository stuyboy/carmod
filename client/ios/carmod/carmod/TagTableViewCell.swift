//
//  TagTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 11/17/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import MGSwipeTableCell
import UIKit

class TagTableViewCell: MGSwipeTableCell {
  var tagImage: UIImageView = UIImageView()
  var tagLabel: UILabel = UILabel()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.clearColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
//    self.tagImage.image = UIImage(named: "ic_part_other")
    self.swipeContentView.addSubview(self.tagImage)
      
    self.tagLabel.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    self.tagLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagLabel.numberOfLines = 0
    self.tagLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    self.swipeContentView.addSubview(self.tagLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let X_OFFSET: CGFloat = 25.0
    let IMAGE_SIZE: CGFloat = self.bounds.height-13.0
    self.tagImage.frame = CGRect(x: X_OFFSET, y: self.bounds.height/2-IMAGE_SIZE/2, width: IMAGE_SIZE, height: IMAGE_SIZE)
    
    self.tagLabel.frame = CGRect(x: self.tagImage.frame.maxX+OFFSET_STANDARD, y: 0.0, width: self.bounds.width-IMAGE_SIZE-X_OFFSET-OFFSET_STANDARD, height: self.bounds.height)
  }
  
  // MARK: - Callbacks
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

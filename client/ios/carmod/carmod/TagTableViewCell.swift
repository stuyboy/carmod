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
    
    self.tagLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.tagLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagLabel.numberOfLines = 0
    self.tagLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    self.swipeContentView.addSubview(self.tagLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.tagLabel.frame = CGRect(x: OFFSET_SMALL, y: 0.0, width: self.bounds.width, height: self.bounds.height)
  }
  
  // MARK: - Callbacks
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

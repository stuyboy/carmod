//
//  TagView.swift
//  carmod
//
//  Created by Thad Hwang on 11/25/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class TagView: UIView {
  var removeButton: UIButton!
  var tagLabel: UILabel!
  private var fullWidth: CGFloat!
  private var shortenedWidth: CGFloat!

  init(frame: CGRect, arrowSize: CGFloat, fieldHeight: CGFloat) {
    super.init(frame: frame)
    
    let triangleTop = UIImageView(image: UIImage(named: "ic_triangle"))
    triangleTop.frame = CGRect(x: self.frame.width/2-arrowSize/2, y: 0.0, width: arrowSize, height: arrowSize)
    self.addSubview(triangleTop)
    
    let tagBox = UIView(frame: CGRect(x: 0.0, y: arrowSize, width: self.frame.width, height: fieldHeight))
    tagBox.backgroundColor = UIColor.blackColor()
    tagBox.layer.cornerRadius = 4.0
    tagBox.clipsToBounds = true
    self.addSubview(tagBox)
    
    self.removeButton = UIButton(frame: CGRect(x: tagBox.frame.width-arrowSize-5.0, y: arrowSize+tagBox.frame.height/2-arrowSize/2, width: arrowSize, height: arrowSize))
    self.removeButton.setImage(UIImage(named: "ic_remove"), forState: .Normal)
    self.addSubview(self.removeButton)
    
    self.fullWidth = tagBox.frame.width-OFFSET_SMALL*2
    self.shortenedWidth = tagBox.frame.width-OFFSET_SMALL-arrowSize-5.0
    
    self.tagLabel = UILabel(frame: CGRect(x: OFFSET_SMALL, y: arrowSize, width: self.shortenedWidth, height: fieldHeight))
    self.tagLabel.textColor = UIColor.whiteColor()
    self.tagLabel.font = UIFont(name: FONT_BOLD, size: FONTSIZE_SMALL)
    self.tagLabel.textAlignment = .Left
    self.tagLabel.text = "What part is this?"
    self.addSubview(self.tagLabel)
    
    self.bringSubviewToFront(self.removeButton)
  }
  
  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func toggleRemoveVisibility(isHidden: Bool) {
    self.removeButton.hidden = isHidden
    
    self.tagLabel.frame = CGRect(x: self.tagLabel.frame.origin.x, y: self.tagLabel.frame.origin.y, width: isHidden ? self.fullWidth : self.shortenedWidth, height: self.tagLabel.frame.height)
  }
  
}

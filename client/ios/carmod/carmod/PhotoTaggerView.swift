//
//  PhotoTaggerView.swift
//  carmod
//
//  Created by Thad Hwang on 11/17/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class PhotoTaggerView: UIView {
  private var mainView: UIView!
  var tagField: UITextField!
  var hideDropShadow: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clearColor()
    
    self.mainView = UIView(frame: CGRectMake(0.0, 0.0, self.frame.width, 51.0))
    self.mainView.backgroundColor = UIColor.whiteColor()
    self.addSubview(self.mainView)
    
    let BOX_WIDTH: CGFloat = self.frame.width-75.0
    let BOX_HEIGHT: CGFloat = 34.0
    let tagBox = UIView(frame: CGRect(x: 55.0, y: 8.0, width: BOX_WIDTH, height: BOX_HEIGHT))
    tagBox.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
    tagBox.layer.borderWidth = 1.0
    tagBox.layer.cornerRadius = 16.0
    self.mainView.addSubview(tagBox)
    
    let IMAGE_SIZE: CGFloat = 22.0
    let messageIcon = UIImageView(image: UIImage(named: "ic_tag"))
    messageIcon.frame = CGRectMake(18.0, OFFSET_STANDARD, IMAGE_SIZE, IMAGE_SIZE)
    self.mainView.addSubview(messageIcon)
    
    self.tagField = UITextField(frame: CGRectMake(68.0, 8.0, BOX_WIDTH, BOX_HEIGHT))
    self.tagField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagField.placeholder = "Add a part"
    self.tagField.returnKeyType = UIReturnKeyType.Done
    self.tagField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.tagField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.tagField.setValue(UIColor.fromRGB(COLOR_DARK_GRAY), forKeyPath: "_placeholderLabel.textColor") // Are we allowed to modify private properties like this? -Héctor
    self.mainView.addSubview(self.tagField)
  }
  
  class func rectForView() -> CGRect {
    return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, 50.0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

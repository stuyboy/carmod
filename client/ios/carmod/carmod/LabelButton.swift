//
//  LabelButton.swift
//  CarMod
//
//  Created by Thad Hwang on 1/14/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class LabelButton: UIView {
  var labelButton: UIButton = UIButton()
  var labelText: UILabel = UILabel()
  
  init(frame: CGRect, buttonSize: CGFloat, buttonInset: CGFloat, buttonImage: UIImage, buttonText: String) {
    super.init(frame: frame)
    
    self.labelButton.frame = CGRect(x: 0.0, y: 0.0, width: buttonSize, height: buttonSize)
    self.labelButton.setImage(buttonImage, forState: .Normal)
    self.labelButton.backgroundColor = UIColor.blackColor()
    self.labelButton.contentEdgeInsets = UIEdgeInsets(top: buttonInset, left: buttonInset, bottom: buttonInset, right: buttonInset)
    self.addSubview(self.labelButton)
    
    self.labelText.text = buttonText
    self.labelText.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_SMALL)
    self.labelText.textAlignment = .Center
    self.labelText.textColor = UIColor.whiteColor()
    self.labelText.sizeToFit()
    self.labelText.frame.origin = CGPoint(x: self.labelButton.center.x-self.labelText.frame.width/2, y: self.labelButton.frame.maxY-7.0)
    self.addSubview(self.labelText)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

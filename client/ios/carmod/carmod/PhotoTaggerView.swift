//
//  PhotoTaggerView.swift
//  carmod
//
//  Created by Thad Hwang on 11/17/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class PhotoTaggerView: UIView {
  let BOX_OFFSET: CGFloat = 8.0
  let BUTTON_WIDTH: CGFloat = 65.0
  
  private var tagFieldWidth: CGFloat = 0.0
  var partTypeButton: UIButton!
  var cancelButton: UIButton!
  var partType: PartType = PartType.Other {
    didSet {
      self.partTypeButton.setImage(changeImageColor(partTypeToImage(partType)!, tintColor: UIColor.whiteColor()), forState: .Normal)
    }
  }
  private var tagBox: UIView!
  var tagField: UITextField!
  var hideDropShadow: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clearColor()
    
    let BOX_WIDTH: CGFloat = self.frame.width-OFFSET_SMALL*2-self.BUTTON_WIDTH
    let BOX_HEIGHT: CGFloat = self.frame.height-BOX_OFFSET*2
    self.tagBox = UIView(frame: CGRect(x: OFFSET_SMALL, y: BOX_OFFSET, width: BOX_WIDTH, height: BOX_HEIGHT))
    self.tagBox.layer.borderColor = UIColor.whiteColor().CGColor
    self.tagBox.layer.borderWidth = 1.0
    self.tagBox.layer.cornerRadius = 16.0
    self.addSubview(tagBox)

    let BUTTON_SIZE: CGFloat = BOX_HEIGHT
    let BUTTON_INSET: CGFloat = 6.0
    let image = changeImageColor(UIImage(named: "ic_part_other")!, tintColor: UIColor.fromRGB(COLOR_MEDIUM_GRAY))
    self.partTypeButton = UIButton(frame: CGRectMake(tagBox.frame.origin.x+OFFSET_SMALL, self.frame.height/2-BUTTON_SIZE/2, BUTTON_SIZE, BUTTON_SIZE))
    self.partTypeButton.contentEdgeInsets = UIEdgeInsets(top: BUTTON_INSET, left: BUTTON_INSET, bottom: BUTTON_INSET, right: BUTTON_INSET)
    self.partTypeButton.setImage(image, forState: UIControlState.Normal)
    self.partTypeButton.backgroundColor = UIColor.clearColor()
    self.addSubview(self.partTypeButton)
    
    self.cancelButton = UIButton(frame: CGRect(x: self.frame.width-self.BUTTON_WIDTH, y: 0.0, width: BUTTON_WIDTH, height: self.frame.height))
    self.cancelButton.setTitle("Cancel", forState: .Normal)
    self.cancelButton.titleLabel?.textAlignment = NSTextAlignment.Center
    self.cancelButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.addSubview(self.cancelButton)
    
    self.tagFieldWidth = tagBox.frame.width-BUTTON_SIZE-OFFSET_SMALL*3
    self.tagField = UITextField(frame: CGRectMake(self.partTypeButton.frame.maxX+OFFSET_SMALL, 0.0, self.cancelButton.frame.origin.x-5.0, self.frame.height))
    self.tagField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagField.placeholder = "Search for a part"
    self.tagField.returnKeyType = .Default
    self.tagField.autocorrectionType = .No
    self.tagField.textColor = UIColor.whiteColor()
    self.tagField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.tagField.setValue(UIColor.fromRGB(COLOR_LIGHT_GRAY), forKeyPath: "_placeholderLabel.textColor") // Are we allowed to modify private properties like this? -Héctor
    self.addSubview(self.tagField)
    
    self.bringSubviewToFront(self.cancelButton)
  }
  
  func reset() {
    self.tagField.text = ""
    self.partType = PartType.Other
    self.partTypeButton.setImage(changeImageColor(UIImage(named: "ic_part_other")!, tintColor: UIColor.fromRGB(COLOR_MEDIUM_GRAY)), forState: .Normal)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

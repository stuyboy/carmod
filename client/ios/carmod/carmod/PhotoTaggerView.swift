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
  let ADD_BUTTON_WIDTH: CGFloat = 60.0
  
  private var tagFieldWidth: CGFloat = 0.0
  var partTypeButton: UIButton!
  var addButton: UIButton!
  var partType: PartType = PartType.Other {
    didSet {
      self.partTypeButton.setImage(changeImageColor(partTypeToImage(partType)!, tintColor: UIColor.fromRGB(COLOR_ORANGE)), forState: .Normal)
    }
  }
  private var tagBox: UIView!
  var tagField: UITextField!
  var hideDropShadow: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clearColor()
    
    let BOX_WIDTH: CGFloat = self.frame.width-OFFSET_SMALL*2
    let BOX_HEIGHT: CGFloat = self.frame.height-BOX_OFFSET*2
    self.tagBox = UIView(frame: CGRect(x: OFFSET_SMALL, y: BOX_OFFSET, width: BOX_WIDTH, height: BOX_HEIGHT))
    self.tagBox.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
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
    
    self.tagFieldWidth = tagBox.frame.width-BUTTON_SIZE-OFFSET_SMALL*3
    self.tagField = UITextField(frame: CGRectMake(self.partTypeButton.frame.maxX+OFFSET_SMALL, 0.0, self.tagFieldWidth, self.frame.height))
    self.tagField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagField.placeholder = "Add a part"
    self.tagField.returnKeyType = .Default
    self.tagField.autocorrectionType = .No
    self.tagField.textColor = UIColor.whiteColor()
    self.tagField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.tagField.setValue(UIColor.fromRGB(COLOR_LIGHT_GRAY), forKeyPath: "_placeholderLabel.textColor") // Are we allowed to modify private properties like this? -Héctor
    self.tagField.addTarget(self, action: "onChangeText:", forControlEvents: UIControlEvents.EditingChanged)
    self.addSubview(self.tagField)
    
    self.addButton = UIButton(frame: CGRect(x: self.frame.width-self.ADD_BUTTON_WIDTH-OFFSET_SMALL, y: self.frame.height/2-BOX_HEIGHT/2, width: ADD_BUTTON_WIDTH, height: BOX_HEIGHT))
    self.addButton.setTitle("Add", forState: .Normal)
    self.addButton.titleLabel?.textAlignment = NSTextAlignment.Center
    self.addButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.addButton.setTitleColor(UIColor.fromRGB(COLOR_ORANGE), forState: .Normal)
    self.addButton.alpha = 0.0
    self.addSubview(self.addButton)
  }
  
  func toggleAddVisiblity(isHidden: Bool) {
    let BOX_WIDTH: CGFloat = isHidden ? self.frame.width-OFFSET_SMALL*2 : self.frame.width-OFFSET_SMALL*2-ADD_BUTTON_WIDTH
    let BOX_HEIGHT: CGFloat = self.frame.height-BOX_OFFSET*2
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.tagBox.frame = CGRect(x: OFFSET_SMALL, y: self.BOX_OFFSET, width: BOX_WIDTH, height: BOX_HEIGHT)
      self.tagField.frame = CGRectMake(self.partTypeButton.frame.maxX+OFFSET_SMALL, 0.0, isHidden ? self.tagFieldWidth : self.addButton.frame.origin.x-OFFSET_SMALL, self.frame.height)
      self.addButton.alpha = isHidden ? 0.0 : 1.0
    }
  }
  
  func reset() {
    self.tagField.text = ""
    self.toggleAddVisiblity(true)
    self.partType = PartType.Other
    self.partTypeButton.setImage(changeImageColor(UIImage(named: "ic_part_other")!, tintColor: UIColor.fromRGB(COLOR_MEDIUM_GRAY)), forState: .Normal)
  }
  
  // MARK:- Callbacks
  func onChangeText(sender: UITextField) {
    toggleAddVisiblity(sender.text! == "")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

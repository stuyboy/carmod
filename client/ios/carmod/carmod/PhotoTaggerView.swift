//
//  PhotoTaggerView.swift
//  carmod
//
//  Created by Thad Hwang on 11/17/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

protocol PhotoTaggerViewDelegate: class {
  func onSelectPart()
}

class PhotoTaggerView: UIView {
  private var mainView: UIView!
  private var partImageButton: UIButton!
  var partType: PartType = PartType.Other {
    didSet {
      print("got here \(partType)")
      var image: UIImage!
      
      switch partType {
      case .Audio:
        image = UIImage(named: "ic_part_audio")
        break
      case .Brakes:
        image = UIImage(named: "ic_part_brakes")
        break
      case .Lighting:
        image = UIImage(named: "ic_part_lighting")
        break
      case .Rims:
        image = UIImage(named: "ic_part_rims")
        break
      case .Tires:
        image = UIImage(named: "ic_part_tires")
        break
      default:
        image = UIImage(named: "ic_part_other")
        break
      }
      
      self.partImageButton.setImage(image, forState: .Normal)
    }
  }
  var tagField: UITextField!
  var hideDropShadow: Bool = false
  weak var delegate: PhotoTaggerViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clearColor()
    
    self.mainView = UIView(frame: CGRectMake(0.0, 0.0, self.frame.width, 51.0))
    self.mainView.backgroundColor = UIColor.whiteColor()
    self.addSubview(self.mainView)
    
    let BOX_OFFSET: CGFloat = 8.0
    let BOX_WIDTH: CGFloat = self.frame.width-OFFSET_SMALL*2
    let BOX_HEIGHT: CGFloat = self.frame.height-BOX_OFFSET*2
    let tagBox = UIView(frame: CGRect(x: OFFSET_SMALL, y: 8.0, width: BOX_WIDTH, height: BOX_HEIGHT))
    tagBox.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
    tagBox.layer.borderWidth = 1.0
    tagBox.layer.cornerRadius = 16.0
    self.mainView.addSubview(tagBox)

    let BUTTON_SIZE: CGFloat = BOX_HEIGHT
    let BUTTON_INSET: CGFloat = 6.0
    let image = changeImageColor(UIImage(named: "ic_part_other")!, tintColor: UIColor.fromRGB(COLOR_DARK_GRAY))
    self.partImageButton = UIButton(frame: CGRectMake(tagBox.frame.maxX-BUTTON_SIZE-OFFSET_SMALL, self.frame.height/2-BUTTON_SIZE/2, BUTTON_SIZE, BUTTON_SIZE))
    self.partImageButton.contentEdgeInsets = UIEdgeInsets(top: BUTTON_INSET, left: BUTTON_INSET, bottom: BUTTON_INSET, right: BUTTON_INSET)
    self.partImageButton.setImage(image, forState: UIControlState.Normal)
    self.partImageButton.backgroundColor = UIColor.clearColor()
    self.partImageButton.addTarget(self, action: "onTapPartType:", forControlEvents: .TouchUpInside)
    self.mainView.addSubview(self.partImageButton)
    
    let TAG_WIDTH: CGFloat = tagBox.frame.width-BUTTON_SIZE-OFFSET_SMALL*3
    self.tagField = UITextField(frame: CGRectMake(tagBox.frame.origin.x+OFFSET_SMALL, 0.0, TAG_WIDTH, self.frame.height))
    self.tagField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagField.placeholder = "Add a part"
    self.tagField.returnKeyType = UIReturnKeyType.Done
    self.tagField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.tagField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.tagField.setValue(UIColor.fromRGB(COLOR_DARK_GRAY), forKeyPath: "_placeholderLabel.textColor") // Are we allowed to modify private properties like this? -Héctor
    self.mainView.addSubview(self.tagField)
  }
  
  // MARK:- Callbacks
  func onTapPartType(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.onSelectPart()
    }
  }
  
  class func rectForView() -> CGRect {
    return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, 50.0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

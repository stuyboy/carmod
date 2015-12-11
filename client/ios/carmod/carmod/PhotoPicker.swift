//
//  ProfilePickerView.swift
//  face off prototype
//
//  Created by Thad Hwang on 12/12/14.
//  Copyright (c) 2014 Kuduro, Inc. All rights reserved.
//

import UIKit

protocol PhotoPickerDelegate: class {
  func takePhoto()
  func choosePhoto()
  func dismissPicker()
}

class PhotoPicker: UIView {
  weak var delegate: PhotoPickerDelegate?
  var cameraButton: UIButton!
  var galleryButton: UIButton!
  var cancelButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let BUTTON_1_POS: CGFloat = 25.0
    let BUTTON_2_POS: CGFloat = 25.0+STANDARD_BUTTON_HEIGHT+5.0
    let BUTTON_3_POS: CGFloat = 25.0+STANDARD_BUTTON_HEIGHT*2+15.0
    
    self.cameraButton = UIButton(frame: CGRect(x: self.frame.width/2-STANDARD_BUTTON_WIDTH/2, y: BUTTON_1_POS, width: STANDARD_BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.cameraButton.setTitle("TAKE A PHOTO", forState: UIControlState.Normal)
    self.cameraButton.titleLabel!.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.cameraButton.enabled = true
    self.cameraButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.cameraButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    self.cameraButton.backgroundColor = UIColor.fromRGB(COLOR_ORANGE)
    self.cameraButton.layer.cornerRadius = 4.0
    self.cameraButton.addTarget(self, action: "onTakeAPhoto:", forControlEvents: UIControlEvents.TouchUpInside)
    self.addSubview(self.cameraButton)
    
    self.galleryButton = UIButton(frame: CGRect(x: self.frame.width/2-STANDARD_BUTTON_WIDTH/2, y: BUTTON_2_POS, width: STANDARD_BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.galleryButton.setTitle("PICK FROM GALLERY", forState: UIControlState.Normal)
    self.galleryButton.titleLabel!.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.galleryButton.enabled = true
    self.galleryButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.galleryButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    self.galleryButton.backgroundColor = UIColor.fromRGB(COLOR_BLUE)
    self.galleryButton.layer.cornerRadius = 4.0
    self.galleryButton.addTarget(self, action: "onPickAPhoto:", forControlEvents: UIControlEvents.TouchUpInside)
    self.addSubview(self.galleryButton)
    
    self.cancelButton = UIButton(frame: CGRect(x: self.frame.width/2-STANDARD_BUTTON_WIDTH/2, y: BUTTON_3_POS, width: STANDARD_BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.cancelButton.setTitle("NEVERMIND", forState: UIControlState.Normal)
    self.cancelButton.titleLabel!.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.cancelButton.enabled = true
    self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Disabled)
    self.cancelButton.backgroundColor = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    self.cancelButton.layer.cornerRadius = 4.0
    self.cancelButton.addTarget(self, action: "onTapCancel:", forControlEvents: UIControlEvents.TouchUpInside)
    self.addSubview(self.cancelButton)
  }
  
  func onTakeAPhoto(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.takePhoto()
    }
  }
  
  func onPickAPhoto(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.choosePhoto()
    }
  }
  
  func onTapCancel(sender: UIButton) {
    if let delegate = self.delegate {
      delegate.dismissPicker()
    }
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

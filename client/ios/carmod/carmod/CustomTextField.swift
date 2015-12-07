//
//  CustomTextField.swift
//  carmod
//
//  Created by Thad Hwang on 12/4/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
  let padding = UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0);
  
  override func textRectForBounds(bounds: CGRect) -> CGRect {
    return self.newBounds(bounds)
  }
  
  override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
    return self.newBounds(bounds)
  }
  
  override func editingRectForBounds(bounds: CGRect) -> CGRect {
    return self.newBounds(bounds)
  }
  
  private func newBounds(bounds: CGRect) -> CGRect {
    var newBounds = bounds
    newBounds.origin.x += padding.left
    newBounds.origin.y += padding.top
    newBounds.size.height -= padding.top + padding.bottom
    newBounds.size.width -= padding.left + padding.right
    return newBounds
  }
}

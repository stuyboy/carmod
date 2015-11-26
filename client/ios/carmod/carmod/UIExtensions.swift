//
//  UIExtensions.swift
//  VeggieBase
//
//  Created by Thad Hwang on 8/19/15.
//  Copyright (c) 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

extension UIColor {
  class func fromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  func RGBValue() -> UInt {
    var redDecimal: CGFloat = 0
    var greenDecimal: CGFloat = 0
    var blueDecimal: CGFloat = 0
    var alphaDecimal: CGFloat = 0
    self.getRed(&redDecimal, green: &greenDecimal, blue: &blueDecimal, alpha: &alphaDecimal)
    
    let red = UInt(redDecimal * 255)
    let green = UInt(greenDecimal * 255)
    let blue = UInt(blueDecimal * 255)
    
    return (red << 16) + (green << 8) + blue
  }
}

extension UILabel {
  func requiredHeight() -> CGFloat {
    let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    label.font = self.font
    label.text = self.text
    
    label.sizeToFit()
    
    return label.frame.height
  }
}

extension UIImage {
  func resizeImage(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContext(size)
    self.drawInRect(CGRect(origin: CGPoint.zero, size: size))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
  }
}

extension Array {
  subscript (safe index: Int) -> Element? {
    return indices ~= index ? self[index] : nil
  }
}



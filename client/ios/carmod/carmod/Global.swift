//
//  Global.swift
//  SwiftAnyPic
//
//  Created by Thad Hwang on 11/16/15.
//  Copyright © 2015 parse. All rights reserved.
//

//
//  Global.swift
//  VeggieBase
//
//  Created by Thad Hwang on 8/21/15.
//  Copyright (c) 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import Foundation
import UIKit

func changeImageColor(image: UIImage, tintColor: UIColor) -> UIImage {
  let rect: CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
  let scale: CGFloat = image.scale
  let imageRef: CGImageRef = image.CGImage!
  
  UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
  let context: CGContextRef = UIGraphicsGetCurrentContext()!
  CGContextTranslateCTM(context, 0, rect.size.height)
  CGContextScaleCTM(context, 1.0, -1.0);
  tintColor.setFill()
  
  CGContextClipToMask(context, rect, imageRef)
  CGContextAddRect(context, rect);
  CGContextDrawPath(context, CGPathDrawingMode.Fill);
  
  let resultImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
  
  UIGraphicsEndImageContext();
  
  return resultImage;
}

func invertImageColor(image: UIImage) -> UIImage {
  let ciContext = CIContext(options: nil)
  let filter = CIFilter(name: "CIColorInvert")
  let coreImage = CIImage(image: image)
  
  filter!.setValue(coreImage, forKey: kCIInputImageKey)
  let filteredImageData = filter!.valueForKey(kCIOutputImageKey) as! CIImage
  let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent)
  let newImage = UIImage(CGImage: filteredImageRef)
  
  return newImage
}

func scaleImageToSize(image: UIImage, newSize: CGSize) -> UIImage {
  UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
  image.drawInRect(CGRectMake(0.0, 0.0, newSize.width, newSize.height))
  let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  
  return newImage
}

func degreesToRadians(degrees: Double) -> Double {
  return degrees * (M_PI / 180)
}

func radiansToDegrees(radians: Double) -> Double {
  return radians * (180 / M_PI)
}

func bundleID() -> String {
  return NSBundle.mainBundle().bundleIdentifier!
}

func dbStore() -> String {
  return "\(bundleID()).sqlite"
}


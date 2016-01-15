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

var gPhotoSize: CGFloat = 320.0

func partTypeToImage(partType: PartType) -> UIImage? {
  switch partType {
  case .Audio:
    return UIImage(named: "ic_part_audio")
  case .Accessories:
    return UIImage(named: "ic_part_accessories")
  case .Brakes:
    return UIImage(named: "ic_part_brakes")
  case .Exhaust:
    return UIImage(named: "ic_part_exhaust")
  case .Exterior:
    return UIImage(named: "ic_part_exterior")
  case .Lighting:
    return UIImage(named: "ic_part_lighting")
  case .Rims:
    return UIImage(named: "ic_part_rims")
  case .Suspension:
    return UIImage(named: "ic_part_suspension")
  case .Tires:
    return  UIImage(named: "ic_part_tires")
  default:
    return UIImage(named: "ic_part_other")
  }
}

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

func cropToSquare(image originalImage: UIImage) -> UIImage {
  let contextSize: CGSize = originalImage.size
  
  var posX: CGFloat!
  var posY: CGFloat!
  var width: CGFloat!
  var height: CGFloat!
  
  // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
//  print("contextSize.width = \(contextSize.width), contextSize.height = \(contextSize.height)")
  if contextSize.width == contextSize.height {
    // already a square, no need to do any further computations
    return originalImage
  } else if contextSize.width > contextSize.height {
    posX = ((contextSize.width - contextSize.height) / 2)
    posY = 0
    width = contextSize.height
    height = contextSize.height
  } else {
    posX = 0
    posY = ((contextSize.height - contextSize.width) / 2)
    width = contextSize.width
    height = contextSize.width
  }
  
  let rect: CGRect = CGRectMake(posX, posY, width, height)
  
  // Create bitmap image from context using the rect
  let imageRef: CGImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, rect)!
  
  // Create a new image based on the imageRef and rotate back to the original orientation
  let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
  
  return image
}

func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
  NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
    completion(data: data, response: response, error: error)
    }.resume()
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


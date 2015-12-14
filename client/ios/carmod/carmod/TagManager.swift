//
//  TagManager.swift
//  carmod
//
//  Created by Thad Hwang on 12/12/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class TagObject: NSObject {
  var partObject: PartObject!
  var coordinates: CGPoint!
}

class TagManager: NSObject {
  class var sharedInstance: TagManager {
    struct Static {
      static let instance: TagManager = TagManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
  }
}

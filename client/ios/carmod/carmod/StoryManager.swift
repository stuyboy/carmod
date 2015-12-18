//
//  StoryManager.swift
//  carmod
//
//  Created by Thad Hwang on 12/16/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class StoryObject: NSObject {
  var title: String!
  var photos: [PFObject]!
}

class StoryManager: NSObject {
  var eventManager: EventManager!
  
  class var sharedInstance: StoryManager {
    struct Static {
      static let instance: StoryManager = StoryManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.eventManager = EventManager()
  }
}


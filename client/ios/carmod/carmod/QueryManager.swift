//
//  QueryManager.swift
//  carmod
//
//  Created by Thad Hwang on 1/22/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class QueryManager: NSObject {
  var eventManager: EventManager!
  
  class var sharedInstance: QueryManager {
    struct Static {
      static let instance: QueryManager = QueryManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.eventManager = EventManager()
  }
}

//
//  PartManager.swift
//  carmod
//
//  Created by Thad Hwang on 11/20/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class PartObject: NSObject {
  var brand: String!
  var model: String!
  var partNumber: String!
  var partType: String! // classification
}

enum PartType: String {
  case Accessories = "Accessories"
  case Audio = "Audio"
  case Brakes = "Brakes"
  case Exhaust = "Exhaust"
  case Exterior = "Exterior"
  case Lighting = "Lighting"
  case Rims = "Rims"
  case Suspension = "Suspension"
  case Tires = "Tires"
  case Other = "Other"
}

class PartManager: NSObject {
  var bytes: NSMutableData?
  var searchResults: [PartObject] = []
  var eventManager: EventManager!
  
  class var sharedInstance: PartManager {
    struct Static {
      static let instance: PartManager = PartManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.eventManager = EventManager()
  }
  
  func searchPart(query: String) {
//    print("PartManager::searchPart = \(query)")
    self.clearSearchResults()
    
    let SEARCH_URL = "http://kursor.co:8000/search/\(query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"
    print("The SEARCH URL = \(SEARCH_URL)")
    let request = NSURLRequest(URL: NSURL(string: SEARCH_URL)!)
    _ = NSURLConnection(request: request, delegate: self, startImmediately: true)
  }
  
  func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
    self.bytes = NSMutableData()
  }
  
  func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
    self.bytes?.appendData(conData)
  }
  
  /*
    { Classification: "Tires", Brand: "Kumho", Model: "Solus", ProductCode: "KR21" },
  */
  func connectionDidFinishLoading(connection: NSURLConnection!) {
    // we serialize our bytes back to the original JSON structure
    let json = JSON(data: self.bytes!)
    
    if let mods = json["Mods"].array {
      for mod in mods {
        let partObject = PartObject()
        
        if let classification = mod["Classification"].string {
          partObject.partType = classification
        }
        if let brand = mod["Brand"].string {
          partObject.brand = brand
        }
        if let model = mod["Model"].string {
          partObject.model = model
        }
        if let productCode = mod["ProductCode"].string {
          partObject.partNumber = productCode
        }
        
        self.searchResults.append(partObject)
      }
      
      if self.searchResults.count == 0 {
        let emptyPartObject = PartObject()
        emptyPartObject.partNumber = "EMPTY"
        self.searchResults.append(emptyPartObject)
      }
      
      self.eventManager.trigger(EVENT_SEARCH_RESULTS_COMPLETE)
    }
  }
  
  func clearSearchResults() {
    self.searchResults.removeAll()
  }
}

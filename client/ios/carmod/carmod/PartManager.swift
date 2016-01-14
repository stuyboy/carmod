//
//  PartManager.swift
//  carmod
//
//  Created by Thad Hwang on 11/20/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class PartObject: NSObject {
  var id: String!
  var brand: String!
  var model: String!
  var partNumber: String!
  var partType: String! // classification
  var imageURL: String!
}

enum PartType: String {
  case Accessories  = "Accessories"
  case Audio        = "Audio"
  case Brakes       = "Brakes"
  case Exhaust      = "Exhaust"
  case Exterior     = "Exterior"
  case Lighting     = "Lighting"
  case Rims         = "Rims"
  case Suspension   = "Suspension"
  case Tires        = "Tires"
  case Other        = "Other"
}

class PartManager: NSObject {
  var bytes: NSMutableData?
  var searchResults: [PartObject] = []
  var garageParts: [PartObject] = []
  var eventManager: EventManager!
  let PART_CATEGORIES: [String] = [
    "Accessories",
    "Audio",
    "Brakes",
    "Exhaust",
    "Exterior",
    "Lighting",
    "Rims",
    "Suspension",
    "Tires",
    "Other",
  ]
  
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
  
  func generateDisplayName(partObject: PartObject) -> String {
    return "\(partObject.brand) \(partObject.model) \(partObject.partNumber)"
  }
  
  func getPartsForCurrentUser() {
    self.garageParts.removeAll()
    
    let query = PFQuery(className: kAnnotationClassKey)
    query.whereKey(kAnnotationUserKey, equalTo: PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, error: NSError?) -> Void in
      for object in objects! {
        let partObject = PartObject()
        partObject.id = object.objectForKey(kAnnotationPartIDKey) as! String
        partObject.brand = object.objectForKey(kAnnotationBrandKey) as! String
        partObject.model = object.objectForKey(kAnnotationModelKey) as! String
        partObject.partNumber = object.objectForKey(kAnnotationPartNumberKey) as! String
        partObject.imageURL = object.objectForKey(kAnnotationImageURLKey) as! String
        
        self.garageParts.append(partObject)
      }
      
      self.eventManager.trigger(EVENT_PART_SEARCH_COMPLETE)
    }
  }
  
  func searchPart(query: String) {
//    print("PartManager::searchPart = \(query)")
    self.clearSearchResults()
    
    let SEARCH_URL = "http://carmod.xyz:8000/search/\(query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"
//    print("The SEARCH URL = \(SEARCH_URL)")
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
    
    if let results = json[kJSONArrayKey].array {
      for result in results {
        let partObject = PartObject()
        
        if let id = result[kPartJSONIDKey].string {
          partObject.id = id
        }
        if let classification = result[kPartJSONClassificationKey].string {
          partObject.partType = classification
        }
        if let brand = result[kPartJSONBrandKey].string {
          partObject.brand = brand
        }
        if let model = result[kPartJSONModelKey].string {
          partObject.model = model
        }
        if let productCode = result[kPartJSONProductCodeKey].string {
          partObject.partNumber = productCode
        }
        if let imageURL = result[kPartJSONImageURLKey].string {
          partObject.imageURL = imageURL
        }
        
        self.searchResults.append(partObject)
      }
      
      if self.searchResults.count == 0 {
        let emptyPartObject = PartObject()
        emptyPartObject.partNumber = kPartJSONEmptyKey
        self.searchResults.append(emptyPartObject)
      }
      
      self.eventManager.trigger(EVENT_SEARCH_RESULTS_COMPLETE)
    }
  }
  
  func clearSearchResults() {
    self.searchResults.removeAll()
  }
}

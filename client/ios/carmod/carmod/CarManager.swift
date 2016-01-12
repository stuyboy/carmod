//
//  CarManager.swift
//  carmod
//
//  Created by Thad Hwang on 12/7/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class CarObject: NSObject {
  var objectID: String!
  var id: String!
  var year: Int!
  var make: String!
  var model: String!
}

class CarManager: NSObject {
  var bytes: NSMutableData?
  var searchResults: [CarObject] = []
  var eventManager: EventManager!
  
  class var sharedInstance: CarManager {
    struct Static {
      static let instance: CarManager = CarManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.eventManager = EventManager()
  }
  
  func searchCar(query: String) {
    self.clearSearchResults()
    
    let SEARCH_URL = "http://carmod.xyz:8000/auto/\(query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)"
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
  {
  Id: 3,
  Year: 2016,
  Make: "Aston Martin",
  Model: "DB9",
  Type: "Car",
  Horsepower: 510,
  Cylinders: 12,
  Drive: "R"
  },
  */
  func connectionDidFinishLoading(connection: NSURLConnection!) {
    // we serialize our bytes back to the original JSON structure
    let json = JSON(data: self.bytes!)
    
    if let results = json[kJSONArrayKey].array {
      for result in results {
        let carObject = CarObject()
        
        if let id = result[kCarJSONIDKey].string {
          carObject.id = id
        } else {
          carObject.id = "0"
        }
        if let year = result[kCarJSONYearKey].int {
          carObject.year = year
        }
        if let make = result[kCarJSONMakeKey].string {
          carObject.make = make
        }
        if let model = result[kCarJSONModelKey].string {
          carObject.model = model
        }
        
        self.searchResults.append(carObject)
      }
      
      if self.searchResults.count == 0 {
        let emptyCarObject = CarObject()
        emptyCarObject.id = kCarJSONEmptyKey
        self.searchResults.append(emptyCarObject)
      }
      
      self.eventManager.trigger(EVENT_CAR_RESULTS_COMPLETE)
    }
  }
  
  func clearSearchResults() {
    self.searchResults.removeAll()
  }

}

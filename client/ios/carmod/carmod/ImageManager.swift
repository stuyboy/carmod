//
//  GoogleManager.swift
//  carmod
//
//  Created by Thad Hwang on 1/15/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class ImageManager: NSObject {
  var bytes: NSMutableData?
  var eventManager: EventManager!
  var image: UIImage?
  
  class var sharedInstance: ImageManager {
    struct Static {
      static let instance: ImageManager = ImageManager()
    }
    return Static.instance
  }
  
  override init() {
    super.init()
    self.eventManager = EventManager()
  }
  
  func searchImage(query: String) {
//    print("PartManager::searchPart = \(query)")
    self.image = nil
    
    let SEARCH_URL = "https://www.googleapis.com/customsearch/v1?key=\(GOOGLE_API_KEY)&cx=\(GOOGLE_SEARCH_ENGINE_KEY)&q=\(query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!)&searchType=image&imgSize=large&alt=json"
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
  
  func connectionDidFinishLoading(connection: NSURLConnection!) {
    // we serialize our bytes back to the original JSON structure
    let json = JSON(data: self.bytes!)
    
    if let results = json["items"].array {
      for result in results {
        if let imageURL = result["link"].string {
          getDataFromUrl(NSURL(string: imageURL)!) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
              guard let data = data where error == nil else { return }
              self.image = UIImage(data: data)
              self.eventManager.trigger(EVENT_IMAGE_SEARCH_COMPLETE)
            }
          }
          
          break
        }
      }
    }
  }
}

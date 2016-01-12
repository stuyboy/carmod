//
//  PartCollectionViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 1/11/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class PartCollectionViewCell: UICollectionViewCell {
  private var partImage: UIImageView!
  private var partLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.contentView.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    
    self.contentView.layer.cornerRadius = 4.0
    self.contentView.layer.masksToBounds = true
    
    self.partImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height-THUMBNAIL_LABEL_HEIGHT))
    self.partImage.contentMode = .ScaleAspectFill
    self.contentView.addSubview(self.partImage)
    
    let OFFSET: CGFloat = 5.0
    self.partLabel = UILabel(frame: CGRect(x: OFFSET, y: self.frame.height-THUMBNAIL_LABEL_HEIGHT-OFFSET*2, width: self.frame.width, height: THUMBNAIL_LABEL_HEIGHT))
    self.partLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_TINY)
    self.partLabel.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.partLabel.text = ""
    self.partLabel.numberOfLines = 0
    self.partLabel.lineBreakMode = .ByWordWrapping
    self.partLabel.textAlignment = .Center
    self.partLabel.textColor = UIColor.whiteColor()
    self.contentView.addSubview(self.partLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    self.partImage.image = nil
  }
  
  // MARK:- Public methods
  func selectCell() {
    self.partImage.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
    self.partImage.layer.borderWidth = 3.0
  }
  
  func deselectCell() {
    self.partImage.layer.borderColor = UIColor.clearColor().CGColor
    self.partImage.layer.borderWidth = 0.0
  }
  
  func setPartName(partName: String) {
    self.partLabel.text = partName
  }
  
  func setThumbnailImage(image: UIImage) {
    self.partImage.image = image
  }
  
  func setThumbnailImageFromURL(url: NSURL){
    getDataFromUrl(url) { (data, response, error)  in
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        guard let data = data where error == nil else { return }
        self.partImage.image = UIImage(data: data)
      }
    }
  }
  
  func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
      completion(data: data, response: response, error: error)
      }.resume()
  }
}

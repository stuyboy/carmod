//
//  SearchResultsTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 11/20/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
  private var partImage: UIImageView = UIImageView()
  private var partLabel: UILabel = UILabel()
  private var partTypeLabel: UILabel = UILabel()
  private var emptyLabel: UILabel = UILabel()
  
  var searchKeywords: String! {
    didSet {
      if let partObject = self.partObject {
        let baseText = "\(partObject.brand) \(partObject.model) \(partObject.partNumber)"
        let name = baseText.lowercaseString
        let newText = NSMutableAttributedString(string: baseText)
        if let range: Range<String.Index> = name.rangeOfString(searchKeywords.lowercaseString) {
          let index: Int = name.startIndex.distanceTo(range.startIndex)
          
          if index >= 0 {
            let selectedRange: NSRange = NSMakeRange(index, searchKeywords.characters.count)
            
            newText.beginEditing()
            newText.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)!, range: selectedRange)
            newText.addAttribute(NSForegroundColorAttributeName, value: UIColor.fromRGB(COLOR_ORANGE), range: selectedRange)
            newText.endEditing()
          }
        }
        
        self.partLabel.attributedText = newText
      }
    }
  }
  
  var partObject: PartObject! {
    didSet {
      if let partObject = self.partObject {
        self.toggleEmpty(false)
        self.partLabel.text = "\(partObject.brand) \(partObject.model) \(partObject.partNumber)"
        self.partTypeLabel.text = partObject.partType
        self.partImage.image = changeImageColor(partTypeToImage(PartType(rawValue: partObject.partType)!)!, tintColor: UIColor.whiteColor())
      } else {
        self.toggleEmpty(true)
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.blackColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.addSubview(self.partImage)
    
    self.partLabel.textColor = UIColor.whiteColor()
    self.partLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.addSubview(self.partLabel)
    
    self.partTypeLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_XSMALL)
    self.partTypeLabel.textColor = UIColor.whiteColor()
    self.partTypeLabel.textAlignment = .Right
    self.addSubview(self.partTypeLabel)
    
    self.emptyLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.emptyLabel.textColor = UIColor.whiteColor()
    self.emptyLabel.text = "NO RESULTS FOUND"
    self.emptyLabel.hidden = true
    self.addSubview(self.emptyLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let IMAGE_SIZE: CGFloat = SEARCH_RESULTS_ROW_HEIGHT-25.0
    let SUBLABEL_WIDTH: CGFloat = 50.0
    let LABEL_WIDTH: CGFloat = self.bounds.width-SUBLABEL_WIDTH-IMAGE_SIZE-OFFSET_STANDARD*3
    
    self.partImage.frame = CGRect(x: OFFSET_STANDARD, y: self.bounds.height/2-IMAGE_SIZE/2, width: IMAGE_SIZE, height: IMAGE_SIZE)
    self.partLabel.frame = CGRect(x: IMAGE_SIZE+OFFSET_XLARGE, y: 0.0, width: LABEL_WIDTH, height: SEARCH_RESULTS_ROW_HEIGHT)
    self.partTypeLabel.frame = CGRect(x: self.bounds.width-OFFSET_STANDARD-SUBLABEL_WIDTH, y: 0.0, width: SUBLABEL_WIDTH, height: SEARCH_RESULTS_ROW_HEIGHT)
    
    self.emptyLabel.frame = CGRect(x: OFFSET_STANDARD, y: 0.0, width: self.bounds.width, height: SEARCH_RESULTS_ROW_HEIGHT)
  }
  
  // MARK: - Callbacks
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  private func toggleEmpty(isEmpty: Bool) {
    self.emptyLabel.hidden = !isEmpty
    self.partLabel.hidden = isEmpty
    self.partImage.hidden = isEmpty
    self.partTypeLabel.hidden = isEmpty
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

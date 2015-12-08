//
//  CarTableViewCell
//  carmod
//
//  Created by Thad Hwang on 12/7/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {
  private var carLabel: UILabel = UILabel()
  private var emptyLabel: UILabel = UILabel()
  
  var searchKeywords: String! {
    didSet {
      if let carObject = self.carObject {
        let baseText = "\(carObject.make) \(carObject.model)"
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
        
        self.carLabel.attributedText = newText
      } else {
        let preText = "No matches found. Add '"
        let newText = NSMutableAttributedString(string: preText+searchKeywords+"'")
        let selectedRange: NSRange = NSMakeRange(preText.characters.count, searchKeywords.characters.count)
        
        newText.beginEditing()
        newText.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)!, range: selectedRange)
        newText.addAttribute(NSForegroundColorAttributeName, value: UIColor.fromRGB(COLOR_ORANGE), range: selectedRange)
        newText.endEditing()
        
        self.emptyLabel.attributedText = newText
      }
    }
  }
  
  var carObject: CarObject! {
    didSet {
      if let carObject = self.carObject {
        self.toggleEmpty(false)
        self.carLabel.text = "\(carObject.make) \(carObject.model)"
      } else {
        self.toggleEmpty(true)
      }
    }
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.whiteColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.carLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.carLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.addSubview(self.carLabel)
    
    self.emptyLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.emptyLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.emptyLabel.text = ""
    self.emptyLabel.hidden = true
    self.addSubview(self.emptyLabel)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let LABEL_WIDTH: CGFloat = self.bounds.width-OFFSET_STANDARD*2

    self.carLabel.frame = CGRect(x: OFFSET_STANDARD, y: 0.0, width: LABEL_WIDTH, height: SEARCH_RESULTS_ROW_HEIGHT)
    self.emptyLabel.frame = CGRect(x: OFFSET_STANDARD, y: 0.0, width: self.bounds.width, height: SEARCH_RESULTS_ROW_HEIGHT)
  }
  
  // MARK: - Callbacks
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  private func toggleEmpty(isEmpty: Bool) {
    self.emptyLabel.hidden = !isEmpty
    self.carLabel.hidden = isEmpty
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

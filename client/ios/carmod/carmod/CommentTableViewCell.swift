//
//  CommentTableViewCell.swift
//  carmod
//
//  Created by Thad Hwang on 12/18/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell, UITextViewDelegate {
  var user: PFUser! {
    didSet {
      let userName = user.objectForKey(kPAPUserDisplayNameKey) as! String
      let combinedText = "\(userName) \(comment)"
      
      let newText: NSMutableAttributedString = NSMutableAttributedString(string: combinedText)
      let userNameRange: NSRange = NSMakeRange(0, userName.characters.count)
      let commentRange: NSRange = NSMakeRange(userName.characters.count+1, comment.characters.count)
      newText.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_BOLD, size: FONTSIZE_MEDIUM)!, range: userNameRange)
      newText.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)!, range: commentRange)
      newText.addAttribute(NSForegroundColorAttributeName, value: UIColor.fromRGB(COLOR_DARK_GRAY), range: commentRange)
      newText.addAttribute(NSLinkAttributeName, value: "foo", range: userNameRange)
      newText.endEditing()
      
      self.commentField.attributedText = newText
    }
  }
  
  var comment: String! {
    didSet {
      self.commentField.text = comment
    }
  }
  
  private var commentField: UITextView = UITextView()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor.clearColor()
    
    if self.respondsToSelector("layoutMargins") {
      self.layoutMargins = UIEdgeInsetsZero
    }
    if self.respondsToSelector("preservesSuperviewLayoutMargins") {
      self.preservesSuperviewLayoutMargins = false
    }
    
    self.commentField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.commentField.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    self.commentField.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.fromRGB(COLOR_BLUE)]
    self.commentField.delegate = self
    self.contentView.addSubview(self.commentField)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.commentField.frame = CGRect(x: OFFSET_SMALL, y: 0.0, width: self.bounds.width-OFFSET_SMALL*2, height: 35.0)
  }
  
  func textViewShouldBeginEditing(textView: UITextView) -> Bool {
    return false
  }
  
  func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
    print("BOOM")
    
    return true
  }
  
  // MARK: - Callbacks
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  class func heightForCell() -> CGFloat {
    return 35.0
  }
}

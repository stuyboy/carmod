//
//  StoryHeaderView.swift
//  carmod
//
//  Created by Thad Hwang on 12/14/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import FormatterKit
import ParseUI

@objc protocol StoryHeaderViewDelegate: NSObjectProtocol {
  optional func photoHeaderView(photoHeaderView: StoryHeaderView, didTapUserButton button: UIButton, user: PFUser)
}

class StoryHeaderView: UITableViewCell {
  var delegate: StoryHeaderViewDelegate?
  var containerView: UIView?
  var avatarImageView: PAPProfileImageView?
  var userButton: UIButton?
  var timestampLabel: UILabel?
  var timeIntervalFormatter: TTTTimeIntervalFormatter?
  var story: PFObject? {
    didSet {
      // user's avatar
      print("setting story...")
      if let user: PFUser = story!.objectForKey(kStoryAuthorKey) as? PFUser {
        user.fetchIfNeeded()
        print("user name = \(user.objectForKey(kPAPUserDisplayNameKey)!)")
        if PAPUtility.userHasProfilePictures(user) {
          let profilePictureSmall: PFFile = user.objectForKey(kPAPUserProfilePicSmallKey) as! PFFile
          self.avatarImageView!.setFile(profilePictureSmall)
        } else {
          self.avatarImageView!.setImage(PAPUtility.defaultProfilePicture()!)
        }
        
        self.avatarImageView!.contentMode = UIViewContentMode.ScaleAspectFill
        self.avatarImageView!.layer.cornerRadius = 17.5
        self.avatarImageView!.layer.masksToBounds = true
        
        let authorName: String = user.objectForKey(kPAPUserDisplayNameKey) as! String
        self.userButton!.setTitle(authorName, forState: UIControlState.Normal)
        
        var constrainWidth: CGFloat = containerView!.bounds.size.width
        
        // we resize the button to fit the user's name to avoid having a huge touch area
        let userButtonPoint: CGPoint = CGPointMake(50.0, 6.0)
        constrainWidth -= userButtonPoint.x
        let constrainSize: CGSize = CGSizeMake(constrainWidth, containerView!.bounds.size.height - userButtonPoint.y*2.0)
        
        let userButtonSize: CGSize = self.userButton!.titleLabel!.text!.boundingRectWithSize(constrainSize,
          options: [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin],
          attributes: [NSFontAttributeName: self.userButton!.titleLabel!.font],
          context: nil).size
        
        let userButtonFrame: CGRect = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height)
        self.userButton!.frame = userButtonFrame
        
        let timeInterval: NSTimeInterval = self.story!.createdAt!.timeIntervalSinceNow
        let timestamp: String = self.timeIntervalFormatter!.stringForTimeInterval(timeInterval)
        self.timestampLabel!.text = timestamp
        
        self.setNeedsDisplay()
      }
    }
  }
  
  // MARK:- Initialization
  init(frame: CGRect) {
    super.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
    self.frame = frame
    
    self.clipsToBounds = false
    self.backgroundColor = UIColor.whiteColor()
    
    // translucent portion
    self.containerView = UIView(frame: CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height))
    self.containerView!.clipsToBounds = false
    self.addSubview(self.containerView!)
    self.containerView!.backgroundColor = UIColor.whiteColor()
    
    self.avatarImageView = PAPProfileImageView()
    self.avatarImageView!.frame = CGRectMake(4.0, 4.0, 35.0, 35.0)
    self.avatarImageView!.profileButton!.addTarget(self, action: Selector("didTapUserButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
    self.containerView!.addSubview(self.avatarImageView!)
    
    // This is the user's display name, on a button so that we can tap on it
    self.userButton = UIButton(type: UIButtonType.Custom)
    containerView!.addSubview(self.userButton!)
    self.userButton!.backgroundColor = UIColor.clearColor()
    self.userButton!.titleLabel!.font = UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)
    self.userButton!.setTitleColor(UIColor.fromRGB(COLOR_NEAR_BLACK), forState: UIControlState.Normal)
    self.userButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
    self.userButton!.titleLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
    
    self.timeIntervalFormatter = TTTTimeIntervalFormatter()
    
    // timestamp
    self.timestampLabel = UILabel(frame: CGRectMake(50.0, 24.0, containerView!.bounds.size.width - 50.0 - 72.0, 18.0))
    containerView!.addSubview(self.timestampLabel!)
    self.timestampLabel!.textColor = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    self.timestampLabel!.font = UIFont.systemFontOfSize(11.0)
    self.timestampLabel!.backgroundColor = UIColor.clearColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK:- Callbacks
  func didTapUserButtonAction(sender: UIButton) {
    if delegate != nil && delegate!.respondsToSelector(Selector("photoHeaderView:didTapUserButton:user:")) {
      delegate!.photoHeaderView!(self, didTapUserButton: sender, user: self.story![kStoryAuthorKey] as! PFUser)
    }
  }
}





//
//  StoryViewController.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import ODRefreshControl

class StoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  private var user: PFUser!
  private var storyTable: UITableView!
  private var refreshControl: ODRefreshControl!
  private var stories = Array<Array<PFObject>>()
  private var emptyView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    gPhotoSize = self.view.frame.width
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.rightBarButtonItem = PAPSettingsButtonItem(target: self, action: Selector("settingsButtonAction:"))
    
    if self.user == nil {
      self.user = PFUser.currentUser()!
      PFUser.currentUser()!.fetchIfNeeded()
    }
    
    self.initStoryTable()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // Load stories
    let query = PFQuery(className: kStoryClassKey)
    query.whereKey(kStoryAuthorKey, equalTo: self.user!)
    query.findObjectsInBackgroundWithBlock {
      (objects: [AnyObject]?, error: NSError?) -> Void in
      if error != nil {
        return
      }
      
      for object in objects! {
        let relation = object.relationForKey(kStoryPhotosKey)
        let q = relation.query()
        let photos: [PFObject] = q?.findObjects() as! [PFObject]
        self.stories.append(photos)
      }
      
      self.refreshStories()
    }
  }
  
  // MARK:- Initializers
  private func initStoryTable() {
    let TABLE_HEIGHT: CGFloat = self.view.frame.height-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!
    self.storyTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: gPhotoSize, height: TABLE_HEIGHT))
    self.storyTable.registerClass(StoryTableViewCell.classForCoder(), forCellReuseIdentifier: "StoryTableViewCell")
    self.storyTable.clipsToBounds = true
    self.storyTable.backgroundColor = UIColor.blackColor()
    self.storyTable.rowHeight = gPhotoSize
    self.storyTable.delegate = self
    self.storyTable.dataSource = self
    if self.storyTable.respondsToSelector("separatorInset") {
      self.storyTable.separatorInset = UIEdgeInsetsZero
    }
    self.view.addSubview(self.storyTable)
    
    self.refreshControl = ODRefreshControl(inScrollView: self.storyTable)
    self.refreshControl.tintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.refreshControl.addTarget(self, action: "refreshStories", forControlEvents:UIControlEvents.ValueChanged)
    self.storyTable.addSubview(self.refreshControl)
    
    self.emptyView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: TABLE_HEIGHT))
    self.emptyView.backgroundColor = UIColor.whiteColor()
    self.emptyView.hidden = true
    self.view.addSubview(self.emptyView)
    
    let IMAGE_RATIO: CGFloat = 1358.0/1000.0
    let introImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.emptyView.frame.width, height: self.emptyView.frame.width/IMAGE_RATIO))
    introImage.image = UIImage(named: "img_intro")
    self.emptyView.addSubview(introImage)
    
    let TEXT_WIDTH: CGFloat = self.emptyView.frame.width-OFFSET_LARGE*2
    let emptyText = UILabel(frame: CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: introImage.frame.maxY+OFFSET_LARGE*2, width: TEXT_WIDTH, height: 20.0))
    emptyText.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    emptyText.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    emptyText.textAlignment = .Center
    emptyText.numberOfLines = 0
    emptyText.lineBreakMode = .ByWordWrapping
    emptyText.text = "No stories to show. Try adding your first story or find people to follow."
    let requiredHeight = emptyText.requiredHeight()
    emptyText.frame = CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: emptyText.frame.origin.y, width: TEXT_WIDTH, height: requiredHeight)
    self.emptyView.addSubview(emptyText)
    
    let findFriendsButton = UIButton(frame: CGRect(x: self.emptyView.frame.width/2-STANDARD_BUTTON_WIDTH/2, y: emptyText.frame.maxY+OFFSET_LARGE, width: STANDARD_BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    findFriendsButton.setTitle("FIND FRIENDS TO FOLLOW", forState: .Normal)
    findFriendsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    findFriendsButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    findFriendsButton.backgroundColor = UIColor.fromRGB(COLOR_ORANGE)
    findFriendsButton.layer.cornerRadius = 4.0
    findFriendsButton.addTarget(self, action: "onFindFriends:", forControlEvents: .TouchUpInside)
    self.emptyView.addSubview(findFriendsButton)
    
    let IMAGE_SIZE: CGFloat = 70.0
    let sketchArrowImage = UIImageView(image: changeImageColor(UIImage(named: "ic_arrow_sketch")!, tintColor: UIColor.fromRGB(COLOR_ORANGE)))
    sketchArrowImage.frame = CGRect(x: self.emptyView.frame.width/2-IMAGE_SIZE, y: self.emptyView.frame.height-IMAGE_SIZE-50.0, width: IMAGE_SIZE, height: IMAGE_SIZE)
    self.emptyView.addSubview(sketchArrowImage)
  }
  
  // MARK:- UITableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = self.stories.count
    
    self.emptyView.hidden = count > 0
    
    return count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("StoryTableViewCell") as! StoryTableViewCell
    cell.photos = self.stories[indexPath.row]
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  func refreshStories() {
    self.storyTable.contentSize = CGSize(width: self.storyTable.frame.width, height: gPhotoSize*CGFloat(self.stories.count))
    self.storyTable.reloadData()
    
    if self.refreshControl.refreshing {
      self.refreshControl.endRefreshing()
    }
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  // MARK:- Callbacks
  func onFindFriends(sender: UIButton) {
    let detailViewController = PAPFindFriendsViewController(style: UITableViewStyle.Plain)
    self.navigationController!.pushViewController(detailViewController, animated: true)
  }
  
  func settingsButtonAction(sender: AnyObject) {
    let actionController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let myProfileAction = UIAlertAction(title: NSLocalizedString("My Profile", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
      self.navigationController!.pushViewController(PAPAccountViewController(user: PFUser.currentUser()!), animated: true)
    })
    let findFriendsAction = UIAlertAction(title: NSLocalizedString("Find Friends", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
      self.navigationController!.pushViewController(PAPFindFriendsViewController(style: UITableViewStyle.Plain), animated: true)
    })
    let logOutAction = UIAlertAction(title: NSLocalizedString("Log Out", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
      // Log out user and present the login view controller
      (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
    
    actionController.addAction(myProfileAction)
    actionController.addAction(findFriendsAction)
    actionController.addAction(logOutAction)
    actionController.addAction(cancelAction)
    
    self.presentViewController(actionController, animated: true, completion: nil)
  }
}

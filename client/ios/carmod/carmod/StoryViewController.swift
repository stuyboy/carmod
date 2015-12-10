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
    self.storyTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: gPhotoSize, height: self.view.frame.height-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!))
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
  }
  
  // MARK:- UITableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.stories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("StoryTableViewCell") as! StoryTableViewCell
    cell.photos = self.stories[indexPath.row]
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  func refreshStories() {
    print("StoryViewController::refreshStories")
    print("self.stories.count = \(self.stories.count)")
    
    self.storyTable.contentSize = CGSize(width: self.storyTable.frame.width, height: gPhotoSize*CGFloat(self.stories.count))
    print("self.storyTable.contentSize = \(self.storyTable.contentSize)")
    self.storyTable.reloadData()
    
    if self.refreshControl.refreshing {
      self.refreshControl.endRefreshing()
    }
  }

  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  // MARK:- Callbacks
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

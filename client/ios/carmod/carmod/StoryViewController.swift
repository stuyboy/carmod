//
//  StoryViewController.swift
//  carmod
//
//  Created by Thad Hwang on 12/8/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import ODRefreshControl
import MBProgressHUD
import Synchronized

class StoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, StoryHeaderViewDelegate, StoryTableViewCellDelegate {
  var shouldReloadOnAppear: Bool = true
  private var user: PFUser!
  private var storyTable: UITableView!
  private var refreshControl: ODRefreshControl!
  private var stories: [PFObject] = []                // Feed of story objects
  private var storyPhotos = Array<Array<PFObject>>()  // Array of photos in each story object
  private var emptyView: UIView!
  private var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    CarManager.sharedInstance.eventManager.listenTo(EVENT_STORY_PUBLISHED) { () -> () in
      let progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      progressHUD.labelText = "Publishing..."
      progressHUD.labelFont = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
      self.loadStories({ (error) -> Void in
        progressHUD.hide(true)
      })
    }
    
    self.view.backgroundColor = UIColor.blackColor()
    
    let INDICATOR_SIZE: CGFloat = 100.0
    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2-INDICATOR_SIZE/2, y: self.view.frame.height/2-INDICATOR_SIZE/2-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!, width: INDICATOR_SIZE, height: INDICATOR_SIZE))
    self.activityIndicator.hidesWhenStopped = true
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    self.view.addSubview(self.activityIndicator)
    self.activityIndicator.startAnimating()
    
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
    
    if self.shouldReloadOnAppear {
      self.shouldReloadOnAppear = false
      self.loadStories({ (error) -> Void in
        self.activityIndicator.stopAnimating()
      })
    }
  }
  
  // MARK:- Initializers
  private func loadStories(completion: ((NSError?) -> Void)) {
    let followingActivitiesQuery = PFQuery(className: kPAPActivityClassKey)
    followingActivitiesQuery.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeFollow)
    followingActivitiesQuery.whereKey(kPAPActivityFromUserKey, equalTo: PFUser.currentUser()!)
    followingActivitiesQuery.cachePolicy = PFCachePolicy.NetworkOnly
    followingActivitiesQuery.limit = 1000
    
    let storiesFromFollowedUsersQuery = PFQuery(className: kStoryClassKey)
    storiesFromFollowedUsersQuery.whereKey(kStoryAuthorKey, matchesKey: kPAPActivityToUserKey, inQuery: followingActivitiesQuery)
    
    let storiesFromCurrentUserQuery = PFQuery(className: kStoryClassKey)
    storiesFromCurrentUserQuery.whereKey(kStoryAuthorKey, equalTo: PFUser.currentUser()!)
    
    let storyQuery = PFQuery.orQueryWithSubqueries([storiesFromFollowedUsersQuery, storiesFromCurrentUserQuery])
    storyQuery.limit = 100
    storyQuery.includeKey(kStoryAuthorKey)
    storyQuery.orderByDescending("createdAt")
    storyQuery.findObjectsInBackgroundWithBlock {
      (storyObjects: [AnyObject]?, error: NSError?) -> Void in
      if error != nil {
        return
      }
      
      self.stories.removeAll()
      self.storyPhotos.removeAll()
      
      for storyObject in storyObjects! {
        self.stories.append(storyObject as! PFObject)
        
        let relation = storyObject.relationForKey(kStoryPhotosKey)
        if let relationQuery = relation.query() {
          relationQuery.orderByAscending("createdAt")
          let photos: [PFObject] = relationQuery.findObjects() as! [PFObject]
          self.storyPhotos.append(photos)
          
          let title = storyObject.objectForKey(kStoryAttributesTitleKey) as! String
          StoryCache.sharedCache.setAttributesForStory(storyObject as! PFObject, title: title, photos: photos)
        }
      }
      
      self.emptyView.hidden = self.stories.count > 0
      self.refreshStories()
      
      completion(nil)
    }
  }
  
  private func initStoryTable() {
    let TABLE_HEIGHT: CGFloat = self.view.frame.height-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!-50.0
    self.storyTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: gPhotoSize, height: TABLE_HEIGHT), style: UITableViewStyle.Grouped)
    self.storyTable.registerClass(StoryTableViewCell.classForCoder(), forCellReuseIdentifier: "StoryTableViewCell")
    self.storyTable.clipsToBounds = true
    self.storyTable.backgroundColor = UIColor.clearColor()
    self.storyTable.separatorColor = UIColor.clearColor()
    self.storyTable.delegate = self
    self.storyTable.dataSource = self
    if self.storyTable.respondsToSelector("separatorInset") {
      self.storyTable.separatorInset = UIEdgeInsetsZero
    }
    self.view.addSubview(self.storyTable)
    
    self.refreshControl = ODRefreshControl(inScrollView: self.storyTable)
    self.refreshControl.activityIndicatorViewStyle = .WhiteLarge
    self.refreshControl.tintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.refreshControl.addTarget(self, action: "forceRefresh", forControlEvents:UIControlEvents.ValueChanged)
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
    let emptyText = UILabel(frame: CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: introImage.frame.maxY+OFFSET_XLARGE, width: TEXT_WIDTH, height: 20.0))
    emptyText.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    emptyText.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    emptyText.textAlignment = .Center
    emptyText.numberOfLines = 0
    emptyText.lineBreakMode = .ByWordWrapping
    emptyText.text = "No stories to show. Find friends to follow."
    var requiredHeight = emptyText.requiredHeight()
    emptyText.frame = CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: emptyText.frame.origin.y, width: TEXT_WIDTH, height: requiredHeight)
    self.emptyView.addSubview(emptyText)
    
    let findFriendsButton = UIButton(frame: CGRect(x: self.emptyView.frame.width/2-STANDARD_BUTTON_WIDTH/2, y: emptyText.frame.maxY+OFFSET_STANDARD, width: STANDARD_BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    findFriendsButton.setTitle("FIND FRIENDS TO FOLLOW", forState: .Normal)
    findFriendsButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    findFriendsButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    findFriendsButton.backgroundColor = UIColor.fromRGB(COLOR_ORANGE)
    findFriendsButton.layer.cornerRadius = 4.0
    findFriendsButton.addTarget(self, action: "onFindFriends:", forControlEvents: .TouchUpInside)
    self.emptyView.addSubview(findFriendsButton)
    
    let IMAGE_SIZE: CGFloat = 70.0
    let sketchArrowImage = UIImageView(image: changeImageColor(UIImage(named: "ic_arrow_sketch")!, tintColor: UIColor.fromRGB(COLOR_ORANGE)))
    sketchArrowImage.frame = CGRect(x: self.emptyView.frame.width/2-IMAGE_SIZE, y: self.emptyView.frame.height-IMAGE_SIZE-OFFSET_LARGE, width: IMAGE_SIZE, height: IMAGE_SIZE)
    self.emptyView.addSubview(sketchArrowImage)
    
    let emptyText2 = UILabel(frame: CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: sketchArrowImage.frame.origin.y-OFFSET_LARGE, width: TEXT_WIDTH, height: 20.0))
    emptyText2.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    emptyText2.textColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    emptyText2.textAlignment = .Center
    emptyText2.numberOfLines = 0
    emptyText2.lineBreakMode = .ByWordWrapping
    emptyText2.text = "Or try adding your first story."
    requiredHeight = emptyText2.requiredHeight()
    emptyText2.frame = CGRect(x: self.emptyView.frame.width/2-TEXT_WIDTH/2, y: sketchArrowImage.frame.origin.y-requiredHeight-OFFSET_SMALL, width: TEXT_WIDTH, height: requiredHeight)
    self.emptyView.addSubview(emptyText2)
  }
  
  // MARK:- StoryTableViewCellDelegate
  func tappedPhoto(indexPath: NSIndexPath) {
    let detailViewController = StoryDetailsViewController(story: self.stories[indexPath.section])
    self.navigationController!.pushViewController(detailViewController, animated: true)
  }
  
  // MARK:- UITableViewDelegate
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.stories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("StoryTableViewCell") as! StoryTableViewCell
    cell.delegate = self
    cell.indexPath = indexPath
    cell.selectionStyle = .None
    cell.photos = self.storyPhotos[indexPath.section]
    
    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let detailViewController = StoryDetailsViewController(story: self.stories[indexPath.section])
    self.navigationController!.pushViewController(detailViewController, animated: true)
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    var headerView: StoryHeaderView? = tableView.dequeueReusableCellWithIdentifier("StoryHeaderView") as? StoryHeaderView
    if headerView == nil {
      headerView = StoryHeaderView(frame: CGRectMake(0.0, 0.0, self.view.bounds.size.width, HEADER_HEIGHT))
      headerView!.delegate = self
      headerView!.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    headerView!.story = self.stories[section]
    headerView!.tag = section
    
    return headerView
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return HEADER_HEIGHT
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.0000000000001
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return gPhotoSize
  }
  
  // MARK:- Public methods
  func forceRefresh() {
    self.loadStories({ (error) -> Void in

    })
  }
  
  func refreshStories() {
    self.storyTable.contentSize = CGSize(width: self.storyTable.frame.width, height: gPhotoSize*CGFloat(self.storyPhotos.count))
    self.storyTable.reloadData()
    
    if self.refreshControl.refreshing {
      self.refreshControl.endRefreshing()
    }
  }
  
  // MARK:- Callbacks
  func onFindFriends(sender: UIButton) {
    let detailViewController = PAPFindFriendsViewController(style: UITableViewStyle.Plain)
    self.navigationController!.pushViewController(detailViewController, animated: true)
  }
  
  func settingsButtonAction(sender: AnyObject) {
    let alertController = DOAlertController(title: nil, message: nil, preferredStyle: DOAlertControllerStyle.ActionSheet)
    alertController.overlayColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
    alertController.cornerRadius = 8.0
    alertController.alertViewBgColor = UIColor.whiteColor()
    alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
    alertController.buttonBgColorHighlighted[.Default] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    alertController.buttonFont[.Destructive] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    alertController.buttonBgColor[.Destructive] = UIColor.fromRGB(COLOR_DARK_GRAY)
    alertController.buttonBgColorHighlighted[.Destructive] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    alertController.buttonBgColorHighlighted[.Cancel] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    
    let myProfileAction = DOAlertAction(title: NSLocalizedString("MY PROFILE", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.navigationController!.pushViewController(PAPAccountViewController(user: PFUser.currentUser()!), animated: true) })
    let findFriendsAction = DOAlertAction(title: NSLocalizedString("FIND FRIENDS", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.navigationController!.pushViewController(PAPFindFriendsViewController(style: UITableViewStyle.Plain), animated: true) })
    let logOutAction = DOAlertAction(title: NSLocalizedString("LOG OUT", comment: ""), style: DOAlertActionStyle.Destructive, handler: { _ in (UIApplication.sharedApplication().delegate as! AppDelegate).logOut() })
    let cancelAction = DOAlertAction(title: "CANCEL", style: DOAlertActionStyle.Cancel, handler: nil)
    
    alertController.addAction(myProfileAction)
    alertController.addAction(findFriendsAction)
    alertController.addAction(logOutAction)
    alertController.addAction(cancelAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func didTapOnPhotoAction(sender: UIButton) {
//    let photo: PFObject? = self.objects![sender.tag] as? PFObject
//    if photo != nil {
//      let photoDetailsVC = PAPPhotoDetailsViewController(photo: photo!)
//      self.navigationController!.pushViewController(photoDetailsVC, animated: true)
//    }
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
}

//
//  StoryDetailsViewController.swift
//  carmod
//
//  Created by Thad Hwang on 12/15/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import QuartzCore
import MobileCoreServices
import ParseUI
import MBProgressHUD

class CommentObject: NSObject {
  var user: PFUser!
  var comment: String!
}

class StoryDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
  let LABEL_HEIGHT: CGFloat = 40.0
  private var keyboardHeight: CGFloat = 0.0
  
  private var story: PFObject!
  private var photos: [PFObject] = []
  private var pageControl: UIPageControl!
  private var tagID: Int = 0
  private var tags = Array<Array<TagObject>>()
  
  private var scrollView: UIScrollView!
  private var headerView: StoryHeaderView!
  private var photoTable: UITableView!
  private var footerView: PAPPhotoDetailsFooterView!
  private var commentTextField: UITextField!
  private var comments: [CommentObject] = []
  private var commentsTable: UITableView!
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  init(story: PFObject) {
    super.init(nibName: nil, bundle: nil)
    self.story = story
    
    self.photos = StoryCache.sharedCache.photosForStory(story)
    self.tags = Array(count: self.photos.count, repeatedValue: [TagObject]())
    
    for var i = 0; i < self.photos.count; i++ {
      let annotationObjects = StoryCache.sharedCache.annotationsForPhoto(self.photos[i])
      for annotationObject in annotationObjects {
        let tagObject: TagObject = TagObject()
        
        let partObject: PartObject = PartObject()
        partObject.brand = annotationObject.objectForKey(kAnnotationBrandKey) as! String
        partObject.model = annotationObject.objectForKey(kAnnotationModelKey) as! String
        partObject.partNumber = annotationObject.objectForKey(kAnnotationPartNumberKey) as! String
        
        tagObject.partObject = partObject
        let coordinates = annotationObject.objectForKey(kAnnotationCoordinatesKey) as! [CGFloat]
        tagObject.coordinates = CGPoint(x: coordinates[0], y: coordinates[1])
        
        self.tags[i].append(tagObject)
      }
    }

    var likers = [PFUser]()
    var commenters = [PFUser]()
    var isLikedByCurrentUser = false
    
    let query: PFQuery = PAPUtility.queryForActivitiesOnStory(story, cachePolicy: PFCachePolicy.NetworkOnly)
    query.findObjectsInBackgroundWithBlock { (activityObjects, error) in
      if error != nil {
        return
      }
      
      for activity in activityObjects! {
        if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike && activity.objectForKey(kPAPActivityFromUserKey) != nil {
          likers.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
        } else if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeComment && activity.objectForKey(kPAPActivityFromUserKey) != nil {
          let commenter = activity.objectForKey(kPAPActivityFromUserKey) as! PFUser
          let comment = activity.objectForKey(kPAPActivityContentKey) as! String
          let commentObject = CommentObject()
          commentObject.user = commenter
          commentObject.comment = comment
          self.comments.append(commentObject)
          
          commenters.append(commenter)
        }

        if ((activity.objectForKey(kPAPActivityFromUserKey) as? PFObject)?.objectId) == PFUser.currentUser()!.objectId {
          if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike {
            isLikedByCurrentUser = true
          }
        }
      }
    
      self.refreshComments(false)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.whiteColor()
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.initBody()
    self.initFooter()
    
    self.view.bringSubviewToFront(self.headerView)
  }
  
  override func viewWillAppear(animated: Bool) {
    self.photoTable.reloadData()
  }
  
  private func initBody() {
    self.scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!-self.tabBarController!.tabBar.frame.height))
    self.scrollView.backgroundColor = UIColor.whiteColor()
    self.scrollView.delegate = self
    self.scrollView.scrollEnabled = true
    self.scrollView.bounces = true
    self.view.addSubview(self.scrollView)
    
    self.headerView = StoryHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: HEADER_HEIGHT))
    self.headerView.story = self.story
    self.view.addSubview(self.headerView)
    
    self.photoTable = UITableView(frame: CGRect(x: 0.0, y: self.headerView.frame.maxY, width: gPhotoSize, height: gPhotoSize))
    self.photoTable.registerClass(PhotoTableViewCell.classForCoder(), forCellReuseIdentifier: "PhotoTableViewCell")
    self.photoTable.clipsToBounds = true
    self.photoTable.backgroundColor = UIColor.blackColor()
    self.photoTable.separatorColor = UIColor.blackColor()
    self.photoTable.rowHeight = gPhotoSize
    self.photoTable.delegate = self
    self.photoTable.dataSource = self
    self.photoTable.bounces = false
    self.photoTable.pagingEnabled = true
    self.photoTable.allowsSelection = false
    self.photoTable.showsHorizontalScrollIndicator = false
    self.photoTable.showsVerticalScrollIndicator = false
    if self.photoTable.respondsToSelector("separatorInset") {
      self.photoTable.separatorInset = UIEdgeInsetsZero
    }
    self.photoTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI * 0.5))
    self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
    self.scrollView.addSubview(self.photoTable)
    
    let CONTROL_WIDTH: CGFloat = 200.0
    self.pageControl = UIPageControl(frame: CGRect(x: self.photoTable.frame.width/2-CONTROL_WIDTH/2, y: self.photoTable.frame.maxY-LABEL_HEIGHT-OFFSET_SMALL, width: CONTROL_WIDTH, height: LABEL_HEIGHT))
    self.pageControl.currentPage = 0
    self.pageControl.pageIndicatorTintColor = UIColor.whiteColor()
    self.pageControl.currentPageIndicatorTintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.pageControl.userInteractionEnabled = true
    self.pageControl.addTarget(self, action: "onPageControlChange:", forControlEvents: UIControlEvents.ValueChanged)
    self.pageControl.hidden = self.photos.count == 1
    self.pageControl.numberOfPages = self.photos.count
    self.scrollView.addSubview(self.pageControl)
  }
  
  private func initFooter() {
    self.footerView = PAPPhotoDetailsFooterView(frame: CGRect(x: 0.0, y: self.photoTable.frame.maxY, width: self.view.frame.width, height: PAPPhotoDetailsFooterView.heightForView()))
    self.scrollView.addSubview(self.footerView)
    
    self.commentTextField = self.footerView.commentField
    self.commentTextField!.delegate = self
    
    self.commentsTable = UITableView(frame: CGRect(x: 0.0, y: self.photoTable.frame.maxY, width: self.view.frame.width, height: 0.0))
    self.commentsTable.registerClass(CommentTableViewCell.classForCoder(), forCellReuseIdentifier: "CommentTableViewCell")
    self.commentsTable.clipsToBounds = true
    self.commentsTable.backgroundColor = UIColor.whiteColor()
    self.commentsTable.separatorColor = UIColor.whiteColor()
    self.commentsTable.rowHeight = CommentTableViewCell.heightForCell()
    self.commentsTable.delegate = self
    self.commentsTable.dataSource = self
    self.commentsTable.bounces = false
    self.commentsTable.allowsSelection = false
    self.commentsTable.scrollEnabled = false
    if self.commentsTable.respondsToSelector("separatorInset") {
      self.commentsTable.separatorInset = UIEdgeInsetsZero
    }
    self.scrollView.addSubview(self.commentsTable)
  }
  
  // MARK:- UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let trimmedComment = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    if trimmedComment.length != 0 {
      let comment = PFObject(className: kPAPActivityClassKey)
      comment.setObject(trimmedComment, forKey: kPAPActivityContentKey) // Set comment text
      comment.setObject(self.story.objectForKey(kStoryAuthorKey)!, forKey: kPAPActivityToUserKey) // Set toUser
      comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey) // Set fromUser
      comment.setObject(kPAPActivityTypeComment, forKey:kPAPActivityTypeKey)
      comment.setObject(self.story, forKey: kPAPActivityStoryKey)

      let ACL = PFACL(user: PFUser.currentUser()!)
      ACL.setPublicReadAccess(true)
      ACL.setWriteAccess(true, forUser: self.story.objectForKey(kStoryAuthorKey) as! PFUser)
      comment.ACL = ACL

      StoryCache.sharedCache.incrementCommentCountForStory(self.story)

      // Show HUD view
      MBProgressHUD.showHUDAddedTo(self.view.superview, animated: true)

      // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
      let timer: NSTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("handleCommentTimeout:"), userInfo: ["comment": comment], repeats: false)

      comment.saveEventually { (succeeded, error) in
        let commentObject = CommentObject()
        commentObject.user = PFUser.currentUser()
        commentObject.comment = trimmedComment
        self.comments.append(commentObject)
        
        timer.invalidate()

        if error != nil && error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
          StoryCache.sharedCache.decrementCommentCountForStory(self.story)

          let alertController = UIAlertController(title: NSLocalizedString("Could not post comment", comment: ""), message: NSLocalizedString("This story is no longer available", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
          let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
          alertController.addAction(alertAction)
          self.presentViewController(alertController, animated: true, completion: nil)

          self.navigationController!.popViewControllerAnimated(true)
        }

//        NSNotificationCenter.defaultCenter().postNotificationName(PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification, object: self.photo!, userInfo: ["comments": self.objects!.count + 1])

        self.refreshComments(true)
        
        MBProgressHUD.hideHUDForView(self.view.superview, animated: true)
      }
    }
    
    textField.text = ""
    return textField.resignFirstResponder()
  }
  
  // MARK:- UIScrollViewDelegate
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if self.commentTextField.isFirstResponder() {
      self.commentTextField.resignFirstResponder()
    }
    
    if scrollView == self.scrollView {
      if self.scrollView.contentOffset.y == 0 {
        self.headerView.alpha = 1.0
      } else {
        self.headerView.alpha = 0.9
      }
    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView == self.photoTable {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.pageControl.currentPage = indexPath.row
        
        break
      }
    }
  }
  
  func keyboardWillShow(sender: NSNotification) {
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
        self.keyboardHeight = keyboardHeight
        
        UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
          self.footerView.frame.origin.y = self.view.frame.height-self.keyboardHeight-PAPPhotoDetailsFooterView.heightForView()
        })
      }
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
      self.footerView.frame.origin.y = self.photoTable.frame.maxY
    })
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == self.photoTable {
      return self.photos.count
    } else {
      return self.comments.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.photoTable {
      let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
      
      cell.isInteractionEnabled = false
      let photoObject = self.photos[indexPath.row]
      cell.photo.file = photoObject.objectForKey(kPhotoImageKey) as? PFFile
      cell.tags = self.tags[indexPath.row]
      cell.loadPhoto()
    
      return cell
    } else if tableView == self.commentsTable {
      let cell = tableView.dequeueReusableCellWithIdentifier("CommentTableViewCell") as! CommentTableViewCell

      let commentObject = self.comments[indexPath.row]
      cell.comment = commentObject.comment
      cell.user = commentObject.user
      
      return cell
    }
    
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  // MARK:- Callbacks
  func onPageControlChange(sender: UIPageControl) {
    let indexPath = NSIndexPath(forRow: sender.currentPage, inSection: 0)
    self.photoTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
  }

  func onChangeText(sender: UITextField) {

  }
  
  func onDeletePhoto() {
    if self.photos.count == 1 {
      self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
      self.photos.removeAll()
    } else {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.photos.removeAtIndex(indexPath.row)
        
        break
      }
    }
  }
  
  func refreshComments(scrollToBottom: Bool) {
    self.commentsTable.frame = CGRect(x: 0.0, y: self.photoTable.frame.maxY+PAPPhotoDetailsFooterView.heightForView(), width: self.view.frame.width, height: CommentTableViewCell.heightForCell()*CGFloat(self.comments.count))
    self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.commentsTable.frame.maxY)
    self.commentsTable.reloadData()
    
    if scrollToBottom {
      let bottomOffset = CGPoint(x: 0.0, y: self.scrollView.contentSize.height-self.scrollView.bounds.size.height)
      self.scrollView.setContentOffset(bottomOffset, animated: true)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory warning on Edit")
  }
}


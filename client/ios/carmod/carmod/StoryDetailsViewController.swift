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

class StoryDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UINavigationControllerDelegate {
  let LABEL_HEIGHT: CGFloat = 40.0
  private var keyboardHeight: CGFloat = 0.0
  
  private var story: PFObject!
  private var photos: [PFObject] = []
  private var pageControl: UIPageControl!
  private var tagID: Int = 0
  private var tags = Array<Array<TagObject>>()
  
  private var headerView: StoryHeaderView!
  private var photoTable: UITableView!
  private var footerView: PAPPhotoDetailsFooterView!
  
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
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.blackColor()
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.initHeader()
    self.initBody()
    self.initFooter()
  }
  
  override func viewWillAppear(animated: Bool) {
    self.photoTable.reloadData()
  }
  
  // MARK:- Initializers
  private func initHeader() {
    self.headerView = StoryHeaderView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: HEADER_HEIGHT))
    self.headerView.story = self.story
    self.view.addSubview(self.headerView)    
  }
  
  private func initBody() {
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
    if self.photoTable.respondsToSelector("separatorInset") {
      self.photoTable.separatorInset = UIEdgeInsetsZero
    }
    self.photoTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI * 0.5))
    self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
    self.view.addSubview(self.photoTable)
    
    let CONTROL_WIDTH: CGFloat = 200.0
    self.pageControl = UIPageControl(frame: CGRect(x: self.photoTable.frame.width/2-CONTROL_WIDTH/2, y: self.photoTable.frame.maxY-LABEL_HEIGHT-OFFSET_SMALL, width: CONTROL_WIDTH, height: LABEL_HEIGHT))
    self.pageControl.currentPage = 0
    self.pageControl.pageIndicatorTintColor = UIColor.whiteColor()
    self.pageControl.currentPageIndicatorTintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.pageControl.userInteractionEnabled = true
    self.pageControl.addTarget(self, action: "onPageControlChange:", forControlEvents: UIControlEvents.ValueChanged)
    self.pageControl.hidden = self.photos.count == 1
    self.pageControl.numberOfPages = self.photos.count
    self.view.addSubview(self.pageControl)
  }
  
  private func initFooter() {
    self.footerView = PAPPhotoDetailsFooterView(frame: CGRect(x: 0.0, y: self.photoTable.frame.maxY, width: self.view.frame.width, height: HEADER_HEIGHT))
    self.view.addSubview(self.footerView)
  }
  
  // MARK:- UITextFieldDelegate
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
  
  // MARK:- UIScrollViewDelegate
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {

  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {

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
      }
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {
    
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.photos.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
    
    cell.isInteractionEnabled = false
    let photoObject = self.photos[indexPath.row]
    cell.photo.file = photoObject.objectForKey(kPhotoImageKey) as? PFFile
    cell.tags = self.tags[indexPath.row]
    cell.loadPhoto()
    
    return cell
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory warning on Edit")
  }
}


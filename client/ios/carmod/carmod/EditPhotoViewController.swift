import UIKit
import QuartzCore
import MobileCoreServices
import ParseUI

class EditPhotoViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoTableViewCellDelegate {
  let LABEL_HEIGHT: CGFloat = 40.0
  
  private var navBarHeight: CGFloat = 0.0
  private var alertController: DOAlertController!
  private var keyboardHeight: CGFloat = 0.0
  
  private var photoTable: UITableView!
  var photos: [UIImage] = [] {
    didSet {
      self.pageControl.hidden = self.photos.count == 1
      self.pageControl.numberOfPages = self.photos.count
      
      self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
      self.photoTable.reloadData()
    }
  }
  private var pageControl: UIPageControl!
  
  private var tagID: Int = 0
  private var tags = Array<Array<TagObject>>()
  private var tagHelp: UILabel!
  
  private var descriptions: [String] = [""]
  private var descriptionView: UIView!
  private var descriptionField: UITextView!
  private var descriptionPlaceholder: UILabel!

  private var actionButtons: UIView!
  private var deleteButton: UIButton!
  private var addTagButton: UIButton!
  private var addTitleButton: UIButton!
  private var addPhotoButton: UIButton!
  
  private var titleView: UIView!
  private var titleField: UITextField = UITextField()
  private var titleLabel: UILabel!
  
  private var selectedPart: String!
  
  var photoFiles: [PFFile] = []
  var thumbnailFiles: [PFFile] = []
  var fileUploadBackgroundTaskId: UIBackgroundTaskIdentifier!
  var photoPostBackgroundTaskId: UIBackgroundTaskIdentifier!
  
  // MARK:- NSObject
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  init(image aImage: UIImage) {
    super.init(nibName: nil, bundle: nil)
    
    self.photos.append(aImage)
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid
    
    let tagArray: [TagObject] = []
    self.tags.append(tagArray) // Add empty Tag Array as init
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonAction:"))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: Selector("publishStory:"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.shouldUploadImage(self.photos[0])
    
    self.navBarHeight = (self.navigationController?.navigationBar.frame.height)!
    
    self.initBody()
    self.initActionButtons()
  }
  
  // MARK:- Initializers
  private func initBody() {
    self.photoTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: gPhotoSize, height: gPhotoSize))
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
    self.view.addSubview(self.photoTable)
    
    let IMAGE_SIZE: CGFloat = LABEL_HEIGHT-OFFSET_STANDARD
    
    self.titleView = UIView(frame: CGRect(x: 0.0, y: -LABEL_HEIGHT, width: self.view.frame.width, height: LABEL_HEIGHT))
    self.titleView.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.titleView.alpha = 0.8
    self.titleView.userInteractionEnabled = true
    self.titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapTitle:"))
    self.view.addSubview(self.titleView)
    
    self.titleLabel = UILabel(frame: CGRect(x: OFFSET_SMALL, y: 0.0, width: self.titleView.frame.width-OFFSET_SMALL*2-IMAGE_SIZE-5.0, height: LABEL_HEIGHT))
    self.titleLabel.textColor = UIColor.whiteColor()
    self.titleLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.titleLabel.text = ""
    self.titleView.addSubview(self.titleLabel)
    
    let closeImage = changeImageColor(UIImage(named: "ic_delete")!, tintColor: UIColor.fromRGB(COLOR_NEAR_BLACK))
    let closeButton = UIButton(frame: CGRect(x: self.titleView.frame.width-IMAGE_SIZE-2.5, y: self.titleView.frame.height/2-IMAGE_SIZE/2, width: IMAGE_SIZE, height: IMAGE_SIZE))
    closeButton.layer.cornerRadius = IMAGE_SIZE/2
    closeButton.clipsToBounds = true
    closeButton.backgroundColor = UIColor.whiteColor()
    closeButton.setImage(closeImage, forState: UIControlState.Normal)
    let INSET: CGFloat = 9.0
    closeButton.contentEdgeInsets = UIEdgeInsets(top: INSET, left: INSET, bottom: INSET, right: INSET)
    closeButton.addTarget(self, action: "onDeleteTitle:", forControlEvents: UIControlEvents.TouchUpInside)
    self.titleView.addSubview(closeButton)
    
    let CONTROL_WIDTH: CGFloat = 200.0
    self.pageControl = UIPageControl(frame: CGRect(x: self.photoTable.frame.width/2-CONTROL_WIDTH/2, y: self.photoTable.frame.maxY-LABEL_HEIGHT-OFFSET_SMALL, width: CONTROL_WIDTH, height: LABEL_HEIGHT))
    self.pageControl.currentPage = 0
    self.pageControl.pageIndicatorTintColor = UIColor.whiteColor()
    self.pageControl.currentPageIndicatorTintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.pageControl.userInteractionEnabled = true
    self.pageControl.addTarget(self, action: "onPageControlChange:", forControlEvents: UIControlEvents.ValueChanged)
    self.view.addSubview(self.pageControl)
    
    let FIELD_WIDTH: CGFloat = 175
    let FIELD_HEIGHT: CGFloat = 35.0
    
    self.tagHelp = UILabel(frame: CGRect(x: self.view.frame.width/2-FIELD_WIDTH/2, y: self.photoTable.frame.maxY-FIELD_HEIGHT-OFFSET_SMALL, width: FIELD_WIDTH, height: FIELD_HEIGHT))
    self.tagHelp.layer.cornerRadius = 4.0
    self.tagHelp.clipsToBounds = true
    self.tagHelp.backgroundColor = UIColor.blackColor()
    self.tagHelp.textColor = UIColor.whiteColor()
    self.tagHelp.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.tagHelp.textAlignment = .Center
    self.tagHelp.text = "Tap photo to tag parts"
    self.tagHelp.alpha = 0.7
    self.view.addSubview(self.tagHelp)
    
    let FIELD_HEIGHT_2 = self.view.frame.height-self.photoTable.frame.maxY-STATUS_BAR_HEIGHT-self.navBarHeight-LARGE_BUTTON_SIZE-OFFSET_SMALL
    
    self.descriptionView = UIView(frame: CGRect(x: 0.0, y: self.photoTable.frame.maxY, width: self.view.frame.width, height: FIELD_HEIGHT_2))
    self.descriptionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.descriptionView)
    
    let TEXT_WIDTH: CGFloat = self.descriptionView.frame.width-OFFSET_SMALL*2
    let TEXT_HEIGHT: CGFloat = self.descriptionView.frame.height-OFFSET_SMALL*2
    self.descriptionField = UITextView(frame: CGRect(x: self.descriptionView.frame.width/2-TEXT_WIDTH/2, y: self.descriptionView.frame.height/2-TEXT_HEIGHT/2, width: TEXT_WIDTH, height: TEXT_HEIGHT))
    self.descriptionField.backgroundColor = UIColor.clearColor()
    self.descriptionField.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
    self.descriptionField.layer.borderWidth = 1.0
    self.descriptionField.layer.cornerRadius = 4.0
    self.descriptionField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.descriptionField.tintColor = UIColor.fromRGB(COLOR_ORANGE)
    self.descriptionField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.descriptionField.textContainer.maximumNumberOfLines = 7
    self.descriptionField.textContainer.lineBreakMode = .ByTruncatingTail
    self.descriptionField.delegate = self
    self.descriptionView.addSubview(self.descriptionField)
    
    self.descriptionPlaceholder = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.descriptionView.frame.width, height: self.descriptionView.frame.height))
    self.descriptionPlaceholder.text = "Add a description for this photo"
    self.descriptionPlaceholder.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.descriptionPlaceholder.textColor = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    self.descriptionPlaceholder.textAlignment = .Center
    self.descriptionPlaceholder.alpha = 1.0
    self.descriptionPlaceholder.userInteractionEnabled = true
    self.descriptionPlaceholder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapPlaceholder:"))
    self.descriptionView.addSubview(self.descriptionPlaceholder)
  }
  
  private func initActionButtons() {
    let BUTTON_SIZE: CGFloat = SMALL_BUTTON_SIZE
    self.deleteButton = UIButton(frame: CGRect(x: OFFSET_SMALL, y: OFFSET_SMALL, width: BUTTON_SIZE, height: BUTTON_SIZE))
    self.deleteButton.backgroundColor = UIColor.blackColor()
    self.deleteButton.layer.cornerRadius = SMALL_BUTTON_SIZE/2
    let closeImage = changeImageColor(UIImage(named: "ic_close")!, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY))
    self.deleteButton.setImage(closeImage, forState: .Normal)
    let INSET_OFFSET: CGFloat = 8.0
    self.deleteButton.contentEdgeInsets = UIEdgeInsets(top: INSET_OFFSET, left: INSET_OFFSET, bottom: INSET_OFFSET, right: INSET_OFFSET)
    self.deleteButton.alpha = 0.6
    self.deleteButton.addTarget(self, action: "onDeletePhoto", forControlEvents: .TouchUpInside)
    self.view.addSubview(self.deleteButton)
    
    self.actionButtons = UIView(frame: CGRect(x: 0.0, y: self.view.frame.height-LARGE_BUTTON_SIZE-OFFSET_SMALL-STATUS_BAR_HEIGHT-self.navBarHeight, width: self.view.frame.width, height: LARGE_BUTTON_SIZE))
    self.actionButtons.backgroundColor = UIColor.blackColor()
    self.view.addSubview(self.actionButtons)
    
    let titleImage = changeImageColor(UIImage(named: "ic_t")!, tintColor: UIColor.whiteColor())
    let addTitleView = LabelButton(frame: CGRect(x: self.view.frame.width/4-LARGE_BUTTON_SIZE/2-OFFSET_LARGE, y: 0.0, width: LARGE_BUTTON_SIZE, height: LARGE_BUTTON_SIZE), buttonSize: LARGE_BUTTON_SIZE, buttonInset: 14.0, buttonImage: titleImage, buttonText: "Add Title")
    self.actionButtons.addSubview(addTitleView)
    self.addTitleButton = addTitleView.labelButton
    self.addTitleButton.addTarget(self, action: "onAddTitle", forControlEvents: .TouchUpInside)
    
    let plusImage = changeImageColor(UIImage(named: "ic_plus")!, tintColor: UIColor.whiteColor())
    let addPhotoView = LabelButton(frame: CGRect(x: self.view.frame.width/2-LARGE_BUTTON_SIZE/2, y: 0.0, width: LARGE_BUTTON_SIZE, height: LARGE_BUTTON_SIZE), buttonSize: LARGE_BUTTON_SIZE, buttonInset: 9.0, buttonImage: plusImage, buttonText: "Add Photo")
    self.actionButtons.addSubview(addPhotoView)
    self.addPhotoButton = addPhotoView.labelButton
    self.addPhotoButton.addTarget(self, action: "onAddPhoto", forControlEvents: .TouchUpInside)
    
    let tagImage = changeImageColor(UIImage(named: "ic_tag_v2")!, tintColor: UIColor.whiteColor())
    let addTagView = LabelButton(frame: CGRect(x: (self.view.frame.width*3/4)-LARGE_BUTTON_SIZE/2+OFFSET_LARGE, y: 0.0, width: LARGE_BUTTON_SIZE, height: LARGE_BUTTON_SIZE), buttonSize: LARGE_BUTTON_SIZE, buttonInset: 9.0, buttonImage: tagImage, buttonText: "Add Tag")
    self.actionButtons.addSubview(addTagView)
    self.addTagButton = addTagView.labelButton
    self.addTagButton.addTarget(self, action: "tappedPhoto", forControlEvents: .TouchUpInside)
  }
  
  // MARK:- UITextFieldDelegate
  func textViewDidEndEditing(textView: UITextView) {
    if self.descriptionField.text == "" {
      self.descriptionPlaceholder.alpha = 1.0
    }
    
    if self.pageControl.currentPage >= self.descriptions.count {
      self.descriptions.append(self.descriptionField.text!)
    } else {
      self.descriptions[self.pageControl.currentPage] = self.descriptionField.text!
    }
  }
  
  // MARK:- UIScrollViewDelegate
  func scrollViewDidScroll(scrollView: UIScrollView) {
//    if scrollView == self.photoTable {
//      self.stopTagging()
//    }
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView == self.photoTable {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.pageControl.currentPage = indexPath.row
        
        if self.pageControl.currentPage < self.descriptions.count {
          self.descriptionField.text = self.descriptions[self.pageControl.currentPage]
          self.descriptionPlaceholder.alpha = self.descriptionField.text == "" ? 1.0 : 0.0
        }
        
        break
      }
    }
  }
  
  func shouldUploadImage(anImage: UIImage) -> Bool {
    let resizedImage: UIImage = anImage.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: CGSizeMake(560.0, 560.0), interpolationQuality: CGInterpolationQuality.High)
    let thumbnailImage: UIImage = anImage.thumbnailImage(86, transparentBorder: 0, cornerRadius: 10, interpolationQuality: CGInterpolationQuality.Default)
    
    // JPEG to decrease file size and enable faster uploads & downloads
    guard let imageData: NSData = UIImageJPEGRepresentation(resizedImage, 0.8) else { return false }
    guard let thumbnailImageData: NSData = UIImagePNGRepresentation(thumbnailImage) else { return false }
    
    let photoFile = PFFile(data: imageData)
    self.photoFiles.append(photoFile)
    
    let thumbnailFile = PFFile(data: thumbnailImageData)
    self.thumbnailFiles.append(thumbnailFile)
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
      UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
    }
    
    photoFile.saveInBackgroundWithBlock { (succeeded, error) in
      if (succeeded) {
//        print("Photo uploaded successfully")
        thumbnailFile.saveInBackgroundWithBlock { (succeeded, error) in
          if (succeeded) {
//            print("Thumbnail uploaded successfully")
          }
          UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
        }
      } else {
        UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
      }
    }
    
    return true
  }
  
  func keyboardWillShow(sender: NSNotification) {
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
        self.keyboardHeight = keyboardHeight
        UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
          self.descriptionView.frame.origin.y = self.view.frame.height-keyboardHeight-self.descriptionView.frame.height
          self.tagHelp.alpha = 0.0
        })
      }
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
      self.descriptionView.frame.origin.y = self.photoTable.frame.maxY
      self.tagHelp.alpha = 0.7
    })
  }
  
  func publishStory(sender: AnyObject) {
    if self.photos.count == 0 {
      let alertController = UIAlertController(title: NSLocalizedString("Couldn't post your photo", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
      let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
      alertController.addAction(alertAction)
      self.presentViewController(alertController, animated: true, completion: nil)
      return
    }
    
    // Create a story
    let story = PFObject(className: kStoryClassKey)
    story.setObject(PFUser.currentUser()!, forKey: kStoryAuthorKey)
    story.setObject(self.titleLabel.text!, forKey: kStoryTitleKey)
    let relation = story.relationForKey(kStoryPhotosKey)
    
//    print("Publishing \(self.photos.count) photos with \(self.tags.count) tags and \(self.photoFiles.count) photo files")
    var photoObjects: [PFObject] = []
    for var i = 0; i < self.photos.count; i++ {
      let photo = PFObject(className: kPAPPhotoClassKey)
      photo.setObject(PFUser.currentUser()!, forKey: kPAPPhotoUserKey)
      photo.setObject(self.photoFiles[i], forKey: kPAPPhotoPictureKey)
      photo.setObject(self.thumbnailFiles[i], forKey: kPAPPhotoThumbnailKey)
      // photos are public, but may only be modified by the user who uploaded them
      let photoACL = PFACL(user: PFUser.currentUser()!)
      photoACL.setPublicReadAccess(true)
      photo.ACL = photoACL
      
      photo.save()
      
      relation.addObject(photo)
      photoObjects.append(photo)
      
      // Handle descriptions
      let description = self.descriptions[i]
      
      // Allow blank description uploads
//      if description != "" {
        let activity = PFObject(className: kPAPActivityClassKey)
        activity.setObject(kPAPActivityTypeDescription, forKey: kPAPActivityTypeKey)
        activity.setObject(description, forKey: kPAPActivityContentKey)
        activity.setObject(photo, forKey: kPAPActivityPhotoKey)
        activity.setObject(story, forKey: kPAPActivityStoryKey)
        activity.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey)
        activity.setObject(PFUser.currentUser()!, forKey: kPAPActivityToUserKey)
        
        activity.save()
//      }
      
      // Handle annotations
      var annotations: [PFObject] = []
      
      let tags = self.tags[i]
      for tag in tags {
        let annotation = PFObject(className: kAnnotationClassKey)
        annotation.setObject(tag.partObject.id, forKey: kAnnotationPartIDKey)
        annotation.setObject(tag.partObject.partType, forKey: kAnnotationPartTypeKey)
        annotation.setObject(tag.partObject.brand, forKey: kAnnotationBrandKey)
        annotation.setObject(tag.partObject.model, forKey: kAnnotationModelKey)
        annotation.setObject(tag.partObject.partNumber, forKey: kAnnotationPartNumberKey)
        annotation.setObject(tag.partObject.imageURL, forKey: kAnnotationImageURLKey)
        annotation.setObject(PFUser.currentUser()!, forKey: kAnnotationUserKey)
        annotation.setObject(photo, forKey: kAnnotationPhotoKey)
        let coordinates = [tag.coordinates.x, tag.coordinates.y]
        annotation.addObjectsFromArray(coordinates, forKey: kAnnotationCoordinatesKey)
        
        let ACL = PFACL(user: PFUser.currentUser()!)
        ACL.setPublicReadAccess(true)
        annotation.ACL = ACL
        
        annotations.append(annotation)
        annotation.save()
      }
      
      let likers = [PFUser]()
      let commenters = [PFUser]()
      let isLikedByCurrentUser = false

      StoryCache.sharedCache.setAttributesForPhoto(photo, annotations: annotations, description: description, likers: likers, commenters: commenters, likedByCurrentUser: isLikedByCurrentUser)
    }
    
    story.save()
    
    StoryCache.sharedCache.setAttributesForStory(story, title: self.titleLabel.text!, photos: photoObjects)
    
    CarManager.sharedInstance.eventManager.trigger(EVENT_STORY_PUBLISHED)
    self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func cancelButtonAction(sender: AnyObject) {
    self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.photos.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell
    
    if let image = self.photos[safe: indexPath.row] {
      cell.delegate = self
      cell.isInteractionEnabled = true
      cell.photo.image = image
      cell.tags = self.tags[indexPath.row]
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  // MARK:- PhotoTableViewCellDelegate  
  func tappedPhoto() {    
    if self.descriptionView.frame.origin.y != self.photoTable.frame.maxY {
      self.descriptionField.resignFirstResponder()
    } else {
      let taggerViewController = TaggerViewController()
      taggerViewController.editPhotoViewController = self
      self.presentViewController(taggerViewController, animated: true, completion: nil)
    }
  }
  
  func removedTag(tagIndex: Int) {
    if tagIndex != -1 {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.tags[indexPath.row].removeAtIndex(tagIndex)
        
        break
      }
    }
  }
  
  func changedCoordinates(tagIndex: Int, coordinates: CGPoint) {
    let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
    for indexPath in indexPaths {
      let tagArray = self.tags[indexPath.row]
      let tagObject = tagArray[tagIndex]
      tagObject.coordinates = coordinates
      
      break
    }
  }
  
  // MARK:- UIImagePickerDelegate
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    self.dismissViewControllerAnimated(false, completion: nil)
    
    let image = cropToSquare(image: info[UIImagePickerControllerEditedImage] as! UIImage)
    self.photos.append(image)

    self.pageControl.currentPage = self.photos.count-1

    let tagArray: [TagObject] = []
    self.tags.append(tagArray) // Add empty Tag Array as init
    
    self.descriptionField.text = ""
    self.descriptions.append("")
    self.descriptionPlaceholder.alpha = 1.0
    
    self.shouldUploadImage(image)
    self.reloadPhotos()
  }
  
  // MARK:- Callbacks
  func onPageControlChange(sender: UIPageControl) {
    let indexPath = NSIndexPath(forRow: sender.currentPage, inSection: 0)
    self.photoTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
  }
  
  func onTapTitle(sender: UITapGestureRecognizer) {
    self.onAddTitle()
  }
  
  func onDeleteTitle(sender: UIButton) {
    self.titleLabel.text = ""
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.titleView.frame.origin.y = -self.LABEL_HEIGHT
      self.deleteButton.frame.origin.y = OFFSET_SMALL
    }
  }
  
  func onTapPlaceholder(sender: UITapGestureRecognizer) {
    self.descriptionPlaceholder.alpha = 0.0
    self.descriptionField.becomeFirstResponder()
  }
  
  func onAddTitle() {
    let message = self.titleLabel.text == "" ? "Add a title for your project" : "Edit title for your project"
    self.alertController = DOAlertController(title: "Story Title", message: message, preferredStyle: DOAlertControllerStyle.Alert)
    self.alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
      textField.text = self.titleLabel.text
      textField.placeholder = "e.g. Grillcraft How-To-Installation-Guide"
      textField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
      self.titleField = textField
    }
    self.alertController.overlayColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
    self.alertController.cornerRadius = 8.0
    self.alertController.alertViewBgColor = UIColor.whiteColor()
    self.alertController.titleFont = UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)
    self.alertController.titleTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.alertController.messageFont = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.alertController.messageTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
    self.alertController.buttonBgColorHighlighted[.Default] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    self.alertController.buttonBgColorHighlighted[.Cancel] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    
    let cancelAction = DOAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: DOAlertActionStyle.Cancel, handler: nil)
    let okAction = DOAlertAction(title: NSLocalizedString("OK", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.shouldAddTitle() })

    self.alertController.addAction(cancelAction)
    self.alertController.addAction(okAction)
    
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func onDeletePhoto() {
    self.alertController = DOAlertController(title: "Delete Photo?", message: "Are you sure you want to delete this photo?", preferredStyle: DOAlertControllerStyle.Alert)
    self.alertController.overlayColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
    self.alertController.cornerRadius = 8.0
    self.alertController.alertViewBgColor = UIColor.whiteColor()
    self.alertController.titleFont = UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)
    self.alertController.titleTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.alertController.messageFont = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.alertController.messageTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
    self.alertController.buttonBgColorHighlighted[.Default] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
    self.alertController.buttonBgColorHighlighted[.Cancel] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    
    let cancelAction = DOAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: DOAlertActionStyle.Cancel, handler: nil)
    let okAction = DOAlertAction(title: NSLocalizedString("OK", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.deletePhoto() })
    
    self.alertController.addAction(cancelAction)
    self.alertController.addAction(okAction)
    
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func onAddPhoto() {
    let cameraDeviceAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    let photoLibraryAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
    
    if cameraDeviceAvailable && photoLibraryAvailable {
      self.alertController = DOAlertController(title: nil, message: nil, preferredStyle: DOAlertControllerStyle.ActionSheet)
      self.alertController.overlayColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
      self.alertController.alertViewBgColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
      self.alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
      self.alertController.buttonBgColorHighlighted[.Default] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
      self.alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
      self.alertController.buttonBgColorHighlighted[.Cancel] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
      self.alertController.buttonFont[.Destructive] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Destructive] = UIColor.fromRGB(COLOR_BLUE)
      self.alertController.buttonBgColorHighlighted[.Destructive] = UIColor.fromRGB(COLOR_LIGHT_GRAY)
      
      let takePhotoAction = DOAlertAction(title: NSLocalizedString("TAKE PHOTO", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.shouldStartCameraController() })
      let choosePhotoAction = DOAlertAction(title: NSLocalizedString("CHOOSE PHOTO", comment: ""), style: DOAlertActionStyle.Destructive, handler: { _ in self.shouldStartPhotoLibraryPickerController() })
      let cancelAction = DOAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: DOAlertActionStyle.Cancel, handler: nil)
      
      self.alertController.addAction(takePhotoAction)
      self.alertController.addAction(choosePhotoAction)
      self.alertController.addAction(cancelAction)
      
      self.presentViewController(self.alertController, animated: true, completion: nil)
    } else {
      // if we don't have at least two options, we automatically show whichever is available (camera or roll)
      self.shouldPresentPhotoCaptureController()
    }
  }
  
  func shouldAddTitle() {
    self.titleLabel.text = self.titleField.text
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.titleView.frame.origin.y = 0.0
      self.deleteButton.frame.origin.y = self.titleView.frame.height+OFFSET_SMALL
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func shouldPresentPhotoCaptureController() -> Bool {
    var presentedPhotoCaptureController: Bool = self.shouldStartCameraController()
    
    if !presentedPhotoCaptureController {
      presentedPhotoCaptureController = self.shouldStartPhotoLibraryPickerController()
    }
    
    return presentedPhotoCaptureController
  }
  
  func shouldStartCameraController() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
      return false
    }
    
    let cameraUI = UIImagePickerController()
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
      && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!.contains(kUTTypeImage as String) {
        
        cameraUI.mediaTypes = [kUTTypeImage as String]
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
        
        if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) {
          cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
          cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Front
        }
    } else {
      return false
    }
    
    cameraUI.allowsEditing = true
    cameraUI.showsCameraControls = true
    cameraUI.delegate = self
    
    self.dismissViewControllerAnimated(true) { () -> Void in
      self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    
    return true
  }
  
  func shouldStartPhotoLibraryPickerController() -> Bool {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == false
      && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) == false {
        return false
    }
    
    let cameraUI = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
      && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)!.contains(kUTTypeImage as String) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        cameraUI.mediaTypes = [kUTTypeImage as String]
        
    } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
      && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum)!.contains(kUTTypeImage as String) {
        cameraUI.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        cameraUI.mediaTypes = [kUTTypeImage as String]
        
    } else {
      return false
    }
    
    cameraUI.allowsEditing = true
    cameraUI.delegate = self
    
    self.dismissViewControllerAnimated(true) { () -> Void in
      self.presentViewController(cameraUI, animated: true, completion: nil)
    }
    
    return true
  }
  
  // MARK:- Tag methods
  func addTag(partObject: PartObject) {
    let tagObject = TagObject()
    tagObject.partObject = partObject
    
    let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
    var cell: PhotoTableViewCell = PhotoTableViewCell()
    for indexPath in indexPaths {
      // Assume just one cell should be visible
      cell = self.photoTable.cellForRowAtIndexPath(indexPath) as! PhotoTableViewCell
      tagObject.coordinates = cell.currentTagView.frame.origin
      cell.currentTagView.alpha = 0.0
      self.tags[indexPath.row].append(tagObject)
      
      break
    }
    
    var fieldWidth: CGFloat = 175.0
    let fieldHeight: CGFloat = 35.0
    if self.tags.count > 0 {
      fieldWidth = 220.0
      self.tagHelp.text = "Drag to move, or tap to remove"
    } else {
      fieldWidth = 175.0
      self.tagHelp.text = "Tap photo to tag parts"
    }
    self.tagHelp.frame = CGRect(x: self.view.frame.width/2-fieldWidth/2, y: self.photoTable.frame.maxY-fieldHeight-OFFSET_SMALL, width: fieldWidth, height: fieldHeight)
    
    self.photoTable.reloadData()
  }
    
  // MARK: - Private methods
  private func deletePhoto() {
    if self.photos.count == 1 {
      self.dismissViewControllerAnimated(true) { () -> Void in
        self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
        self.photos.removeAll()
      }
    } else {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.photos.removeAtIndex(indexPath.row)
        
        break
      }
    }
  }
  
  private func reloadPhotos() {
    self.photoTable.reloadData()
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.photoTable.setContentOffset(CGPoint(x: 0.0, y: gPhotoSize*CGFloat(self.photos.count-1)), animated: true)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory warning on Edit")
  }
}

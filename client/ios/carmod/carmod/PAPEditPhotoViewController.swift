import MGSwipeTableCell
import UIKit

class PAPEditPhotoViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, MGSwipeTableCellDelegate, UIPickerViewDataSource,UIPickerViewDelegate {
  private var keyboardHeight: CGFloat = 0.0
  private var scrollView: UIScrollView!
  
  private var tagField: UITextField!
  private var partTypeButton: UIButton!
  private var addPartButton: UIButton!
  private var photoTaggerView: PhotoTaggerView!
  private var photoImageView: UIImageView!
  private var photoTaggerViewOrigin: CGPoint!
  
  private var tagsTable: UITableView!
  private var tags: [PartObject] = []
  
  private var pickerView: UIView!
  private var partPicker: UIPickerView!
  private var selectedPart: String!
  private var pickerData: [String] = [
    "Accessories",
    "Audio",
    "Brakes",
    "Exhaust",
    "Exterior",
    "Lighting",
    "Rims",
    "Suspension",
    "Tires",
    "Other",
  ]
  
  var image: UIImage!
  var photoFile: PFFile?
  var thumbnailFile: PFFile?
  var fileUploadBackgroundTaskId: UIBackgroundTaskIdentifier!
  var photoPostBackgroundTaskId: UIBackgroundTaskIdentifier!
  
  // MARK:- NSObject
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  init(image aImage: UIImage) {
    super.init(nibName: nil, bundle: nil)
    
    self.image = aImage
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app-logo"))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonAction:"))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: Selector("publishPhoto:"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.shouldUploadImage(self.image)
    
    self.initBody()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory warning on Edit")
  }
  
  // MARK:- Initializers
  private func initBody() {
    self.photoTaggerView = PhotoTaggerView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: TOPNAV_BAR_SIZE))
    self.photoTaggerView.backgroundColor = UIColor.blackColor()
    self.photoTaggerViewOrigin = self.photoTaggerView.frame.origin
    self.partTypeButton = self.photoTaggerView.partTypeButton
    self.partTypeButton.addTarget(self, action: "onTapPartType:", forControlEvents: .TouchUpInside)
    self.addPartButton = self.photoTaggerView.addButton
    self.addPartButton.addTarget(self, action: "onTapAddPart:", forControlEvents: .TouchUpInside)
    self.tagField = self.photoTaggerView.tagField
    self.tagField!.delegate = self
    self.view.addSubview(self.photoTaggerView)
    
    self.scrollView = UIScrollView(frame: CGRect(x: 0.0, y: self.photoTaggerView.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-self.photoTaggerView.frame.maxY))
    self.scrollView.delegate = self
    self.scrollView.backgroundColor = UIColor.blackColor()
    self.scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapPhoto:"))
    self.view.addSubview(self.scrollView)
    
    self.photoImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.width))
    self.photoImageView.backgroundColor = UIColor.whiteColor()
    self.photoImageView.image = self.image
    self.photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
    self.scrollView.addSubview(self.photoImageView)
    
    self.tagsTable = UITableView(frame: CGRect(x: 0.0, y: self.photoImageView.frame.maxY, width: self.view.frame.width, height: 0.0))
    self.tagsTable.registerClass(TagTableViewCell.classForCoder(), forCellReuseIdentifier: "TagTableViewCell")
    self.tagsTable.clipsToBounds = true
    self.tagsTable.backgroundColor = UIColor.whiteColor()
    self.tagsTable.separatorColor = UIColor.fromRGB(COLOR_ORANGE)
    self.tagsTable.rowHeight = TAG_ROW_HEIGHT
    self.tagsTable.delegate = self
    self.tagsTable.dataSource = self
    self.tagsTable.bounces = false
    if (self.tagsTable.respondsToSelector("separatorInset")) {
      self.tagsTable.separatorInset = UIEdgeInsetsZero
    }
    self.tagsTable.hidden = self.tags.count == 0
    self.scrollView.addSubview(self.tagsTable)
    
    self.scrollView!.contentSize = CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y+photoImageView.frame.size.height+self.photoTaggerView.frame.size.height+self.tagsTable.frame.height)
    
    let PICKER_Y: CGFloat = self.photoImageView.frame.height+self.photoTaggerView.frame.height
    self.pickerView = UIView(frame: CGRect(x: 0.0, y: PICKER_Y, width: self.view.frame.width, height: self.view.frame.height-PICKER_Y))
    self.pickerView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.pickerView)
    
    let actionBar = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.pickerView.frame.width, height: 44.0))
    
    self.partPicker = UIPickerView()
    self.partPicker.center = CGPoint(x: self.pickerView.frame.width/2, y: (self.pickerView.frame.height-actionBar.frame.height)/2)
    self.partPicker.showsSelectionIndicator = true
    self.partPicker.delegate = self
    self.partPicker.dataSource = self
    self.pickerView.addSubview(self.partPicker)
    
    self.pickerView.addSubview(actionBar)
    
    let BUTTON_WIDTH: CGFloat = 60.0
    let cancelButton = UIButton(frame: CGRect(x: 5.0, y: 0.0, width: BUTTON_WIDTH, height: actionBar.frame.height))
    cancelButton.setTitle("Cancel", forState: .Normal)
    cancelButton.titleLabel!.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    cancelButton.setTitleColor(UIColor.fromRGB(COLOR_ORANGE), forState: UIControlState.Normal)
    cancelButton.addTarget(self, action: "onCancelPicker:", forControlEvents: .TouchUpInside)
    self.pickerView.addSubview(cancelButton)
    
    let doneButton = UIButton(frame: CGRect(x: self.pickerView.frame.width-5.0-BUTTON_WIDTH, y: 0.0, width: BUTTON_WIDTH, height: actionBar.frame.height))
    doneButton.setTitle("Done", forState: .Normal)
    doneButton.titleLabel?.textAlignment = .Right
    doneButton.titleLabel!.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    doneButton.setTitleColor(UIColor.fromRGB(COLOR_ORANGE), forState: UIControlState.Normal)
    doneButton.addTarget(self, action: "onDonePicker:", forControlEvents: .TouchUpInside)
    self.pickerView.addSubview(doneButton)
    
    self.pickerView.hidden = true
  }
  
  // MARK:- UITextFieldDelegate  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
  
  // MARK:- UIScrollViewDelegate
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    self.tagField.resignFirstResponder()
  }
  
  // MARK:- UIPickerViewDelegate
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    pickerLabel.text = self.pickerData[row]
    pickerLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    pickerLabel.textAlignment = NSTextAlignment.Center
    return pickerLabel
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.pickerData[row]
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.pickerData.count
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selectedPart = self.pickerData[row]
  }
  
  // MARK:- Callbacks
  func onTapPartType(sender: UIButton) {
    if self.tagField.isFirstResponder() {
      self.tagField.resignFirstResponder()
    }
    self.pickerView.hidden = false
  }
  
  func onTapAddPart(sender: UIButton) {
    if self.tagField.text != "" {
      if self.tagField.isFirstResponder() {
        self.tagField.resignFirstResponder()
      }
      
      let partObject = PartObject()
      partObject.partName = self.tagField.text!
      partObject.partType = self.photoTaggerView.partType.rawValue
      self.tags.append(partObject)
      self.tagsTable.reloadData()
      self.tagField.text = ""
      self.photoTaggerView.reset()
      self.pickerView.hidden = true
    }
  }
  
  func onTapPhoto(sender: UIButton) {
    self.tagField.resignFirstResponder()
  }
  
  func onDonePicker(sender: UIButton) {
    self.photoTaggerView.partType = PartType(rawValue: self.selectedPart) as PartType!
    self.pickerView.hidden = true
  }
  
  func onCancelPicker(sender: UIButton) {
    self.pickerView.hidden = true
  }
  
  // MARK:- ()
  
  func shouldUploadImage(anImage: UIImage) -> Bool {
    let resizedImage: UIImage = anImage.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: CGSizeMake(560.0, 560.0), interpolationQuality: CGInterpolationQuality.High)
    let thumbnailImage: UIImage = anImage.thumbnailImage(86, transparentBorder: 0, cornerRadius: 10, interpolationQuality: CGInterpolationQuality.Default)
    
    // JPEG to decrease file size and enable faster uploads & downloads
    guard let imageData: NSData = UIImageJPEGRepresentation(resizedImage, 0.8) else { return false }
    guard let thumbnailImageData: NSData = UIImagePNGRepresentation(thumbnailImage) else { return false }
    
    self.photoFile = PFFile(data: imageData)
    self.thumbnailFile = PFFile(data: thumbnailImageData)
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
      UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
    }
    
    print("Requested background expiration task with id \(self.fileUploadBackgroundTaskId) for Anypic photo upload")
    self.photoFile!.saveInBackgroundWithBlock { (succeeded, error) in
      if (succeeded) {
        print("Photo uploaded successfully")
        self.thumbnailFile!.saveInBackgroundWithBlock { (succeeded, error) in
          if (succeeded) {
            print("Thumbnail uploaded successfully")
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

  }
  
  func keyboardWillHide(sender: NSNotification) {

  }
  
  func publishPhoto(sender: AnyObject) {
    var userInfo: [String: String]?
    let trimmedComment: String = self.tagField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    if (trimmedComment.length != 0) {
      userInfo = [kPAPEditPhotoViewControllerUserInfoCommentKey: trimmedComment]
    }
    
    if self.photoFile == nil || self.thumbnailFile == nil {
      let alertController = UIAlertController(title: NSLocalizedString("Couldn't post your photo", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
      let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
      alertController.addAction(alertAction)
      presentViewController(alertController, animated: true, completion: nil)
      return
    }
    
    // both files have finished uploading
    
    // create a photo object
    let photo = PFObject(className: kPAPPhotoClassKey)
    photo.setObject(PFUser.currentUser()!, forKey: kPAPPhotoUserKey)
    photo.setObject(self.photoFile!, forKey: kPAPPhotoPictureKey)
    photo.setObject(self.thumbnailFile!, forKey: kPAPPhotoThumbnailKey)
    
    // photos are public, but may only be modified by the user who uploaded them
    let photoACL = PFACL(user: PFUser.currentUser()!)
    photoACL.setPublicReadAccess(true)
    photo.ACL = photoACL
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.photoPostBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
      UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskId)
    }
    
    // save
    photo.saveInBackgroundWithBlock { (succeeded, error) in
      if succeeded {
        print("Photo uploaded")
        
        PAPCache.sharedCache.setAttributesForPhoto(photo, likers: [PFUser](), commenters: [PFUser](), likedByCurrentUser: false)
        
        // userInfo might contain any caption which might have been posted by the uploader
        if let userInfo = userInfo {
          let commentText = userInfo[kPAPEditPhotoViewControllerUserInfoCommentKey]
          
          if commentText != nil && commentText!.length != 0 {
            // create and save photo caption
            let comment = PFObject(className: kPAPActivityClassKey)
            comment.setObject(kPAPActivityTypeComment, forKey: kPAPActivityTypeKey)
            comment.setObject(photo, forKey:kPAPActivityPhotoKey)
            comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey)
            comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityToUserKey)
            comment.setObject(commentText!, forKey: kPAPActivityContentKey)
            
            let ACL = PFACL(user: PFUser.currentUser()!)
            ACL.setPublicReadAccess(true)
            comment.ACL = ACL
            
            comment.saveEventually()
            PAPCache.sharedCache.incrementCommentCountForPhoto(photo)
          }
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(PAPTabBarControllerDidFinishEditingPhotoNotification, object: photo)
      } else {
        print("Photo failed to save: \(error)")
        let alertController = UIAlertController(title: NSLocalizedString("Couldn't post your photo", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
      }
      UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskId)
    }
    
    self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func cancelButtonAction(sender: AnyObject) {
    self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let count = self.tags.count
    self.tagsTable.hidden = count == 0
    self.tagsTable.frame = CGRect(x: self.tagsTable.frame.origin.x, y: self.tagsTable.frame.origin.y, width: self.tagsTable.frame.width, height: TAG_ROW_HEIGHT*CGFloat(count))
    self.scrollView!.contentSize = CGSizeMake(self.scrollView.bounds.size.width, photoImageView.frame.origin.y+photoImageView.frame.size.height+self.photoTaggerView.frame.size.height+self.tagsTable.frame.height)
    
    return count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TagTableViewCell") as! TagTableViewCell
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    
    let partObject = self.tags[indexPath.row]
    
    cell.tagLabel.text = partObject.partName
    cell.tagImage.image = changeImageColor(partTypeToImage(PartType(rawValue: partObject.partType)!)!, tintColor: UIColor.fromRGB(COLOR_DARK_GRAY))
    cell.swipeBackgroundColor = UIColor.whiteColor()
    cell.rightButtons = self.rightButtons() as [AnyObject]
    cell.delegate = self
    
    let expansionSettings = MGSwipeExpansionSettings()
    expansionSettings.fillOnTrigger = true
    expansionSettings.threshold = 1.1
    expansionSettings.buttonIndex = NSInteger(0)
    cell.rightExpansion = expansionSettings
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

  }
  
  // MARK: - MGSwipeTableCellDelegate
  func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
    
    if direction == MGSwipeDirection.RightToLeft {
      let tagCell: TagTableViewCell = cell as! TagTableViewCell
      switch index {
      case 0: // delete
        self.removeTag(tagCell.tagLabel.text!)
        self.tagsTable.reloadData()
        return true
      default:
        return false
      }
    }
    
    return false
  }
  
  // MARK: - Private methods
  private func removeTag(name: String) {
    for var i = 0; i < self.tags.count; i++ {
      let tagName = self.tags[i]
      
      if tagName == name {
        self.tags.removeAtIndex(i)
        return
      }
    }
  }
  
  private func rightButtons() -> NSArray {
    let rightUtilityButtons: NSMutableArray = NSMutableArray()
    
    let deleteButton: MGSwipeButton = MGSwipeButton(title: "", icon: changeImageColor(UIImage(named: "ic_delete")!, tintColor: UIColor.whiteColor()), backgroundColor: UIColor.fromRGB(COLOR_RED), insets: UIEdgeInsetsMake(0.0, 15.0, 0.0, 15.0))
    
    rightUtilityButtons.addObject(deleteButton)
    
    return rightUtilityButtons
  }
}

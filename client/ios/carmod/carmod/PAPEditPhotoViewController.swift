import UIKit
import QuartzCore

class TagObject: NSObject {
  var id: Int!
  var partObject: PartObject!
  var tagView: TagView!
  var removeButton: UIButton!
}

class PAPEditPhotoViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
  private var keyboardHeight: CGFloat = 0.0
  private var searchTagField: UITextField!
  private var partTypeButton: UIButton!
  private var cancelButton: UIButton!
  private var photoTaggerView: PhotoTaggerView!
  private var photoImage: UIImageView!
  private var photoTaggerViewOrigin: CGPoint!
  
  private var tagHelp: UILabel!
  private var tags: [TagObject] = [] {
    didSet {
      if tags.count > 0 {
        self.tagHelp.text = "Tap photo to tag parts.\n\nDrag to move, or tap to remove."
      } else {
        self.tagHelp.text = "Tap photo to tag parts."
      }
    }
  }
  private var searchResultsTable: UITableView!

  private var currentTagView: TagView!
  private var tagID: Int = 0
  
  private var pickerView: UIView!
  private var partPicker: UIPickerView!
  private var selectedPart: String!
  
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
    
    PartManager.sharedInstance.eventManager.listenTo(EVENT_SEARCH_RESULTS_COMPLETE) { () -> () in
      self.refreshSearchResults(PartManager.sharedInstance.searchResults.count)
    }
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonAction:"))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: Selector("publishPhoto:"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.shouldUploadImage(self.image)
    
    self.initBody()
    self.initTagger()
    self.initPicker()
    self.initResultsTable()
  }
  
  // MARK:- Initializers
  private func initBody() {
    self.photoImage = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.width))
    self.photoImage.backgroundColor = UIColor.whiteColor()
    self.photoImage.image = self.image
    self.photoImage.contentMode = UIViewContentMode.ScaleAspectFit
    self.photoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapPhoto:"))
    self.photoImage.userInteractionEnabled = true
    self.view.addSubview(self.photoImage)
  
    self.currentTagView = TagView(frame: CGRect(x: 0.0, y: 0.0, width: TAG_WIDTH, height: TAG_FIELD_HEIGHT+TAG_ARROW_SIZE), arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
    self.currentTagView.alpha = 0.0
    self.currentTagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
    
    let removeButton = self.currentTagView.removeButton
    removeButton.tag = -1
    removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
    self.photoImage.addSubview(self.currentTagView)
    
    let LABEL_WIDTH: CGFloat = self.view.frame.width-OFFSET_XLARGE*2
    let LABEL_HEIGHT: CGFloat = self.view.frame.height-self.photoImage.frame.maxY-(self.navigationController?.navigationBar.frame.height)!-STATUS_BAR_HEIGHT-OFFSET_XLARGE*2
    self.tagHelp = UILabel(frame: CGRect(x: self.view.frame.width/2-LABEL_WIDTH/2, y: self.photoImage.frame.maxY+OFFSET_XLARGE, width: LABEL_WIDTH, height: LABEL_HEIGHT))
    self.tagHelp.textColor = UIColor.whiteColor()
    self.tagHelp.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.tagHelp.textAlignment = .Center
    self.tagHelp.lineBreakMode = .ByWordWrapping
    self.tagHelp.numberOfLines = 0
    self.tagHelp.text = "Tap photo to tag parts."
    self.view.addSubview(self.tagHelp)
  }
  
  private func initTagger() {
    self.photoTaggerView = PhotoTaggerView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: TOPNAV_BAR_SIZE))
    self.photoTaggerView.backgroundColor = UIColor.blackColor()
    self.photoTaggerViewOrigin = self.photoTaggerView.frame.origin
    self.photoTaggerView.alpha = 0.0
    self.navigationController?.navigationBar.addSubview(self.photoTaggerView)
    
    self.searchTagField = self.photoTaggerView.tagField
    self.searchTagField.addTarget(self, action: "onChangeText:", forControlEvents: UIControlEvents.EditingChanged)
    self.searchTagField!.delegate = self
    
    self.partTypeButton = self.photoTaggerView.partTypeButton
    self.partTypeButton.addTarget(self, action: "onTapPartType:", forControlEvents: .TouchUpInside)
    
    self.cancelButton = self.photoTaggerView.cancelButton
    self.cancelButton.addTarget(self, action: "onTapCancel:", forControlEvents: .TouchUpInside)
  }
  
  private func initPicker() {
    let PICKER_Y: CGFloat = self.photoImage.frame.height+self.photoTaggerView.frame.height
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
  
  private func initResultsTable() {
    self.searchResultsTable = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 0.0))
    self.searchResultsTable.registerClass(SearchResultsTableViewCell.classForCoder(), forCellReuseIdentifier: "SearchResultsTableViewCell")
    self.searchResultsTable.layer.borderColor = UIColor.fromRGB(COLOR_LIGHT_GRAY).CGColor
    self.searchResultsTable.layer.borderWidth = 1.0
    self.searchResultsTable.clipsToBounds = true
    self.searchResultsTable.backgroundColor = UIColor.blackColor()
    self.searchResultsTable.separatorColor = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.searchResultsTable.rowHeight = SEARCH_RESULTS_ROW_HEIGHT
    self.searchResultsTable.delegate = self
    self.searchResultsTable.dataSource = self
    self.searchResultsTable.bounces = false
    self.searchResultsTable.alpha = 0.0
    if (self.searchResultsTable.respondsToSelector("separatorInset")) {
      self.searchResultsTable.separatorInset = UIEdgeInsetsZero
    }
    self.view.addSubview(self.searchResultsTable)
  }
  
  // MARK:- UITextFieldDelegate  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
  
  // MARK:- UIScrollViewDelegate
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    if scrollView != self.searchResultsTable {
      self.searchTagField.resignFirstResponder()
    }
  }
  
  // MARK:- UIPickerViewDelegate
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    pickerLabel.text = PartManager.sharedInstance.PART_CATEGORIES[row]
    pickerLabel.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    pickerLabel.textAlignment = NSTextAlignment.Center
    return pickerLabel
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return PartManager.sharedInstance.PART_CATEGORIES[row]
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return PartManager.sharedInstance.PART_CATEGORIES.count
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selectedPart = PartManager.sharedInstance.PART_CATEGORIES[row]
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
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
        self.keyboardHeight = keyboardHeight
      }
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {

  }
  
  func publishPhoto(sender: AnyObject) {
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
        
        // userInfo might contain any caption which might have been posted by the uploader
        var annotations: [PFObject] = []
        
        if self.tags.count > 0 {
          for tag in self.tags {
            let annotation = PFObject(className: kAnnotationClassKey)
            print("Adding \(PartManager.sharedInstance.generateDisplayName(tag.partObject))")
            annotation.setObject(tag.partObject.id, forKey: kAnnotationPartIDKey)
            annotation.setObject(tag.partObject.brand, forKey: kAnnotationBrandKey)
            annotation.setObject(tag.partObject.model, forKey: kAnnotationModelKey)
            annotation.setObject(tag.partObject.partNumber, forKey: kAnnotationPartNumberKey)
            annotation.setObject(photo, forKey: kAnnotationPhotoKey)
            print("setting tag coordinates to be = \(tag.tagView.frame.origin)")
            let coordinates = [tag.tagView.frame.origin.x, tag.tagView.frame.origin.y]
            annotation.addObjectsFromArray(coordinates, forKey: kAnnotationCoordinatesKey)
        
            let ACL = PFACL(user: PFUser.currentUser()!)
            ACL.setPublicReadAccess(true)
            annotation.ACL = ACL
            
            annotations.append(annotation)
            var err: NSError?
            annotation.save(&err)
          }
        }
        
        PAPCache.sharedCache.setAttributesForPhoto(photo, likers: [PFUser](), commenters: [PFUser](), likedByCurrentUser: false, annotations: annotations)
        
//        if let userInfo = userInfo {
//          let commentText = userInfo[kPAPEditPhotoViewControllerUserInfoCommentKey]
//          
//          if commentText != nil && commentText!.length != 0 {
//            // create and save photo caption
//            let comment = PFObject(className: kPAPActivityClassKey)
//            comment.setObject(kPAPActivityTypeComment, forKey: kPAPActivityTypeKey)
//            comment.setObject(photo, forKey:kPAPActivityPhotoKey)
//            comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey)
//            comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityToUserKey)
//            comment.setObject(commentText!, forKey: kPAPActivityContentKey)
//            
//            let ACL = PFACL(user: PFUser.currentUser()!)
//            ACL.setPublicReadAccess(true)
//            comment.ACL = ACL
//            
//            comment.saveEventually()
//            PAPCache.sharedCache.incrementCommentCountForPhoto(photo)
//          }
//        }
        
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
    return PartManager.sharedInstance.searchResults.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultsTableViewCell") as! SearchResultsTableViewCell
    
    if let partObject = PartManager.sharedInstance.searchResults[safe: indexPath.row] {
      if partObject.partNumber == kPartJSONEmptyKey {
        cell.partObject = nil
      } else {
        cell.partObject = partObject
      }
      
      cell.searchKeywords = self.searchTagField.text
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let partObject = PartManager.sharedInstance.searchResults[indexPath.row]
    
    if partObject.partNumber == kPartJSONEmptyKey {
      partObject.partNumber = self.searchTagField.text
      partObject.brand = ""
      partObject.model = ""
    }
    
    let tagObject = TagObject()
    tagObject.id = tagID++
    
    let tagView = TagView(frame: self.currentTagView.frame, arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
    tagView.alpha = 0.8
    tagView.tagLabel.text = PartManager.sharedInstance.generateDisplayName(partObject)
    tagView.toggleRemoveVisibility(true)
    tagView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapTagView:"))
    tagView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDragTag:"))
    
    tagObject.removeButton = tagView.removeButton
    tagObject.removeButton.tag = tagObject.id
    tagObject.removeButton.addTarget(self, action: "onRemoveTag:", forControlEvents: .TouchUpInside)
    
    self.photoImage.addSubview(tagView)
    
    tagObject.partObject = partObject
    tagObject.tagView = tagView
    
    self.tags.append(tagObject)
    
    self.resetView()
  }
  
  // MARK:- Callbacks
  func onDragTag(sender: UIPanGestureRecognizer) {
    let location = sender.locationInView(self.view)
//    let velocity = sender.velocityInView(self.view)
    let translation = sender.translationInView(self.view)
    print(location)
    
    if sender.state == UIGestureRecognizerState.Began {
    } else if sender.state == UIGestureRecognizerState.Changed {
      sender.view!.center.x = sender.view!.center.x+translation.x
      sender.view!.center.y = sender.view!.center.y+translation.y
      
      sender.setTranslation(CGPointZero, inView: self.view)
    } else if sender.state == UIGestureRecognizerState.Ended {

    }
  }
  
  func onTapTagView(sender: UITapGestureRecognizer) {
    let tappedTagView: TagView = sender.view as! TagView
    tappedTagView.toggleRemoveVisibility(false)
  }
  
  func onRemoveTag(sender: UIButton) {
    if sender.tag == -1 {
      self.resetView()
    } else {
      for var i = 0; i < self.tags.count; i++ {
        let tagObject = self.tags[i]
        print("TAG ID at \(i) is \(tagObject.id) and sender tag = \(sender.tag)")
        if tagObject.id == sender.tag {
          self.tags.removeAtIndex(i)
          tagObject.tagView.alpha = 0.0
          
          break
        }
      }
    }
  }
  
  func onChangeText(sender: UITextField) {
    if sender.text != "" {
      PartManager.sharedInstance.searchPart(sender.text!)
    } else {
      PartManager.sharedInstance.clearSearchResults()
      self.searchResultsTable.alpha = 0.0
    }
  }
  
  func onTapPartType(sender: UIButton) {
    if self.searchTagField.isFirstResponder() {
      self.searchTagField.resignFirstResponder()
    }
    self.pickerView.hidden = false
  }
  
  func onTapCancel(sender: UIButton) {
    self.resetView()
  }
  
  func onTapPhoto(sender: UITapGestureRecognizer) {
    let point = sender.locationInView(self.view)
    self.currentTagView.frame.origin.x = point.x-TAG_WIDTH/2
    self.currentTagView.frame.origin.y = point.y
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.currentTagView.alpha = 0.8
      self.photoTaggerView.alpha = 1.0
    }
    
    for tagObject in self.tags {
      tagObject.tagView.toggleRemoveVisibility(true)
    }
    
    self.searchTagField.becomeFirstResponder()
  }
  
  func onDonePicker(sender: UIButton) {
    self.photoTaggerView.partType = PartType(rawValue: self.selectedPart) as PartType!
    self.pickerView.hidden = true
  }
  
  func onCancelPicker(sender: UIButton) {
    self.pickerView.hidden = true
  }
  
  // MARK: - Private methods
  func resetView() {
    if self.searchTagField.isFirstResponder() {
      self.searchTagField.resignFirstResponder()
    }
    self.currentTagView.alpha = 0.0
    self.searchTagField.text = ""
    self.searchResultsTable.alpha = 0.0
    self.photoTaggerView.reset()
    self.photoTaggerView.alpha = 0.0
    self.pickerView.hidden = true
  }
  
  func refreshSearchResults(numResults: Int) {
    if PartManager.sharedInstance.searchResults.count > 0 {
      let SEARCH_VIEWABLE_AREA: CGFloat = self.view.frame.height-self.keyboardHeight
      let SEARCH_HEIGHT: CGFloat = SEARCH_RESULTS_ROW_HEIGHT*CGFloat(numResults)
      
      self.searchResultsTable.frame = CGRect(x: 0.0, y: 0.0, width: self.searchResultsTable.frame.width, height: (SEARCH_HEIGHT > SEARCH_VIEWABLE_AREA) ? SEARCH_VIEWABLE_AREA : SEARCH_HEIGHT)
      
      UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
        self.searchResultsTable.alpha = 0.8
      })
      self.searchResultsTable.reloadData()
    } else {
      self.searchResultsTable.alpha = 0.0
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("Memory warning on Edit")
  }
}

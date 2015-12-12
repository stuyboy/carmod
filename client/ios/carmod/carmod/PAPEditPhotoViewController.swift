import UIKit
import QuartzCore
import MobileCoreServices
import ParseUI

class PAPEditPhotoViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoTableViewCellDelegate {
  private var alertController: DOAlertController!
  private var keyboardHeight: CGFloat = 0.0
  private var titleField: CustomTextField!
  private var searchTagField: UITextField!
  private var partTypeButton: UIButton!
  private var cancelButton: UIButton!
  private var photoTaggerView: PhotoTaggerView!
  
  private var photoTable: UITableView!
  var photos: [UIImage] = [] {
    didSet {
      self.photoTable.contentSize = CGSize(width: gPhotoSize, height: gPhotoSize*CGFloat(photos.count))
      self.photoTable.reloadData()
    }
  }
  private var photoTaggerViewOrigin: CGPoint!

  private var tagHelp: UILabel!

  private var addPhotoButton: UIButton!
  private var searchResultsTable: UITableView!
  
  private var pickerView: UIView!
  private var partPicker: UIPickerView!
  private var selectedPart: String!
  
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
    
    self.photos.append(aImage)
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
    
    self.shouldUploadImage(self.photos[0])
    
    self.initTitle()
    self.initBody()
    self.initTagger()
    self.initPartPicker()
    self.initResultsTable()
  }
  
  // MARK:- Initializers
  private func initTitle() {
//    let LABEL_HEIGHT: CGFloat = 30.0
//    
//    self.titleField = CustomTextField(frame: CGRect(x: OFFSET_SMALL, y: 0.0, width: self.view.frame.width, height: LABEL_HEIGHT))
//    self.titleField.placeholder = "Story Title (e.g. Grillcraft How-To-Installation-Guide)"
//    self.titleField.layer.borderColor = UIColor.fromRGB(COLOR_DARK_GRAY).CGColor
//    self.titleField.layer.borderWidth = 1.0
//    self.titleField.layer.cornerRadius = 2.0
//    self.titleField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
//    self.titleField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
//    self.titleField.autocorrectionType = .No
//    self.titleField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
//    self.titleField.setValue(UIColor.fromRGB(COLOR_MEDIUM_GRAY), forKeyPath: "_placeholderLabel.textColor")
//    self.titleField.keyboardType = .NumberPad
//    self.view.addSubview(self.titleField)
  }
  
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
    if self.photoTable.respondsToSelector("separatorInset") {
      self.photoTable.separatorInset = UIEdgeInsetsZero
    }
    self.photoTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI * 0.5))
    self.view.addSubview(self.photoTable)
    
    let LABEL_WIDTH: CGFloat = self.view.frame.width-OFFSET_XLARGE*2
    let LABEL_HEIGHT: CGFloat = 70.0
    self.tagHelp = UILabel(frame: CGRect(x: self.view.frame.width/2-LABEL_WIDTH/2, y: gPhotoSize+OFFSET_XLARGE, width: LABEL_WIDTH, height: LABEL_HEIGHT))
    self.tagHelp.textColor = UIColor.whiteColor()
    self.tagHelp.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.tagHelp.textAlignment = .Center
    self.tagHelp.lineBreakMode = .ByWordWrapping
    self.tagHelp.numberOfLines = 0
    self.tagHelp.text = "Tap photo to tag parts."
    self.view.addSubview(self.tagHelp)
    
    let BUTTON_WIDTH: CGFloat = self.view.frame.width-OFFSET_SMALL*2
    self.addPhotoButton = UIButton(frame: CGRect(x: self.view.frame.width/2-BUTTON_WIDTH/2, y: self.view.frame.height-STANDARD_BUTTON_HEIGHT-OFFSET_XLARGE-STATUS_BAR_HEIGHT-(self.navigationController?.navigationBar.frame.height)!, width: BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.addPhotoButton.setTitle("ADD ANOTHER PHOTO", forState: .Normal)
    self.addPhotoButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.addPhotoButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.addPhotoButton.backgroundColor = UIColor.fromRGB(COLOR_ORANGE)
    self.addPhotoButton.layer.cornerRadius = 4.0
    self.addPhotoButton.addTarget(self, action: "photoCaptureButtonAction:", forControlEvents: .TouchUpInside)
    self.view.addSubview(self.addPhotoButton)
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
    self.cancelButton.addTarget(self, action: "stopTagging", forControlEvents: .TouchUpInside)
  }
  
  private func initPartPicker() {
    let PICKER_Y: CGFloat = gPhotoSize+self.photoTaggerView.frame.height
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
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView == self.photoTable {
      self.stopTagging()
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
      self.presentViewController(alertController, animated: true, completion: nil)
      return
    }
    
    // both files have finished uploading
  
    // Create the photo
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
        
        // Create a story with a photo
        let story = PFObject(className: kStoryClassKey)
        story.setObject(PFUser.currentUser()!, forKey: kStoryAuthorKey)
        story.setObject("Test story title", forKey: kStoryTitleKey)
        let relation = story.relationForKey(kStoryPhotosKey)
        relation.addObject(photo)
        var err1: NSError?
        story.save(&err1)
        print("saving story with error = \(err1)")
        
        // userInfo might contain any caption which might have been posted by the uploader
        var annotations: [PFObject] = []
        
//        if self.tags.count > 0 {
//          for tag in self.tags {
//            let annotation = PFObject(className: kAnnotationClassKey)
////            print("Adding \(PartManager.sharedInstance.generateDisplayName(tag.partObject))")
//            annotation.setObject(tag.partObject.id, forKey: kAnnotationPartIDKey)
//            annotation.setObject(tag.partObject.brand, forKey: kAnnotationBrandKey)
//            annotation.setObject(tag.partObject.model, forKey: kAnnotationModelKey)
//            annotation.setObject(tag.partObject.partNumber, forKey: kAnnotationPartNumberKey)
//            annotation.setObject(photo, forKey: kAnnotationPhotoKey)
////            print("setting tag coordinates to be = \(tag.tagView.frame.origin)")
//            let coordinates = [tag.tagView.frame.origin.x, tag.tagView.frame.origin.y]
//            annotation.addObjectsFromArray(coordinates, forKey: kAnnotationCoordinatesKey)
//        
//            let ACL = PFACL(user: PFUser.currentUser()!)
//            ACL.setPublicReadAccess(true)
//            annotation.ACL = ACL
//            
//            annotations.append(annotation)
//            var err: NSError?
//            annotation.save(&err)
//          }
//        }
        
        PAPCache.sharedCache.setAttributesForPhoto(photo, likers: [PFUser](), commenters: [PFUser](), likedByCurrentUser: false, annotations: annotations)
        
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
    var count = 0
    
    if tableView == self.photoTable {
      count = self.photos.count
    } else if tableView == self.searchResultsTable {
      count = PartManager.sharedInstance.searchResults.count
    }
    
    return count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if tableView == self.photoTable {
      print("PAPEditPhotoController:cellForRowAtIndexPath -> Index=\(indexPath.row)")
      let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell

      if let image = self.photos[safe: indexPath.row] {
        cell.photo.image = image
        cell.delegate = self
        cell.printTags()
        
      }
  
      return cell
    } else if tableView == self.searchResultsTable {
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
    
    return UITableViewCell()
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView == self.photoTable {
      
    } else if tableView == self.searchResultsTable {
      let partObject = PartManager.sharedInstance.searchResults[indexPath.row]
      
      if partObject.partNumber == kPartJSONEmptyKey {
        partObject.partNumber = self.searchTagField.text
        partObject.brand = ""
        partObject.model = ""
      }
      
//      self.currentCell.addTag(partObject)
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        print("Adding part to indexpath at row = \(indexPath.row)")
        let photoCell: PhotoTableViewCell = self.photoTable.cellForRowAtIndexPath(indexPath) as! PhotoTableViewCell
        photoCell.addTag(partObject)
      }

      self.resetView()
    }
  }
  
  // MARK:- PhotoTableViewCellDelegate
  func changedTags(tagCount: Int) {
    if tagCount > 0 {
      self.tagHelp.text = "Tap photo to tag parts.\n\nDrag to move, or tap to remove."
    } else {
      self.tagHelp.text = "Tap photo to tag parts."
    }
  }
  
  func tappedPhoto() {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.photoTaggerView.alpha = 1.0
    }
    
    self.searchTagField.becomeFirstResponder()
  }
  
  func removedTag() {
    self.resetView()
  }
  
  // MARK:- Callbacks
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
  
  func stopTagging() {
    self.resetView()
    PartManager.sharedInstance.eventManager.trigger(EVENT_PICKER_CANCELLED)
  }
  
  func onDonePicker(sender: UIButton) {
    self.photoTaggerView.partType = PartType(rawValue: self.selectedPart) as PartType!
    self.pickerView.hidden = true
  }
  
  func onCancelPicker(sender: UIButton) {
    self.pickerView.hidden = true
  }
  
  func photoCaptureButtonAction(sender: AnyObject) {
    let cameraDeviceAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    let photoLibraryAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
    
    if cameraDeviceAvailable && photoLibraryAvailable {
      self.alertController = DOAlertController(title: nil, message: nil, preferredStyle: DOAlertControllerStyle.ActionSheet)
      self.alertController.overlayColor = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
      self.alertController.alertViewBgColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
      self.alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
      self.alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
      self.alertController.buttonFont[.Destructive] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Destructive] = UIColor.fromRGB(COLOR_BLUE)
      
      let takePhotoAction = DOAlertAction(title: NSLocalizedString("TAKE PHOTO", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.shouldStartCameraController() })
      let choosePhotoAction = DOAlertAction(title: NSLocalizedString("CHOOSE PHOTO", comment: ""), style: DOAlertActionStyle.Destructive, handler: { _ in self.shouldStartPhotoLibraryPickerController() })
      let cancelAction = DOAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: DOAlertActionStyle.Cancel, handler: { _ in self.shouldCloseAlertController() })
      
      self.alertController.addAction(takePhotoAction)
      self.alertController.addAction(choosePhotoAction)
      self.alertController.addAction(cancelAction)
      
      self.presentViewController(self.alertController, animated: true, completion: nil)
    } else {
      // if we don't have at least two options, we automatically show whichever is available (camera or roll)
      self.shouldPresentPhotoCaptureController()
    }
  }
  
  func shouldCloseAlertController() {
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
  
  // MARK:- UIImagePickerDelegate
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    self.dismissViewControllerAnimated(false, completion: nil)
    
    let image = info[UIImagePickerControllerEditedImage] as! UIImage
    self.photos.append(image)
    self.reloadPhotos()
  }
  
  // MARK: - Private methods
  private func reloadPhotos() {
    self.photoTable.reloadData()
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.photoTable.setContentOffset(CGPoint(x: 0.0, y: gPhotoSize*CGFloat(self.photos.count-1)), animated: true)
    }
  }
  
  func resetView() {
    if self.searchTagField.isFirstResponder() {
      self.searchTagField.resignFirstResponder()
    }
    
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

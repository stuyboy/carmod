import UIKit
import QuartzCore
import MobileCoreServices
import ParseUI

class EditPhotoViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoTableViewCellDelegate, PathMenuDelegate {
  let LABEL_HEIGHT: CGFloat = 40.0
  
  private var alertController: DOAlertController!
  private var keyboardHeight: CGFloat = 0.0
  private var searchTagField: UITextField!
  private var partTypeButton: UIButton!
  private var cancelButton: UIButton!
  private var photoTaggerView: PhotoTaggerView!
  
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
  
  private var photoTaggerViewOrigin: CGPoint!
  private var tagHelp: UILabel!

  private var addMenu: PathMenu!
  private var addTitleButton: UIButton!
  private var addPhotoButton: UIButton!
  private var searchResultsTable: UITableView!
  
  private var titleView: UIView!
  private var titleField: UITextField = UITextField()
  private var titleLabel: UILabel!
  
  private var pickerView: UIView!
  private var partPicker: UIPickerView!
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
    
    PartManager.sharedInstance.eventManager.listenTo(EVENT_SEARCH_RESULTS_COMPLETE) { () -> () in
      self.refreshSearchResults(PartManager.sharedInstance.searchResults.count)
    }
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelButtonAction:"))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: Selector("publishStory:"))
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    self.shouldUploadImage(self.photos[0])
    
    self.initBody()
    self.initTagger()
    self.initPartPicker()
    self.initResultsTable()
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
    self.titleView.addSubview(self.titleLabel)
    
    let closeImage = changeImageColor(UIImage(named: "ic_delete")!, tintColor: UIColor.fromRGB(COLOR_NEAR_BLACK))
    let closeButton = UIButton(frame: CGRect(x: self.titleView.frame.width-IMAGE_SIZE, y: self.titleView.frame.height/2-IMAGE_SIZE/2, width: IMAGE_SIZE, height: IMAGE_SIZE))
    closeButton.layer.cornerRadius = IMAGE_SIZE/2
    closeButton.clipsToBounds = true
    closeButton.backgroundColor = UIColor.whiteColor()
    closeButton.setImage(closeImage, forState: UIControlState.Normal)
    closeButton.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
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
    
    let FIELD_WIDTH: CGFloat = self.view.frame.width-OFFSET_XLARGE*2
    let FIELD_HEIGHT: CGFloat = 70.0
    self.tagHelp = UILabel(frame: CGRect(x: self.view.frame.width/2-FIELD_WIDTH/2, y: gPhotoSize+OFFSET_XLARGE, width: FIELD_WIDTH, height: FIELD_HEIGHT))
    self.tagHelp.textColor = UIColor.whiteColor()
    self.tagHelp.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.tagHelp.textAlignment = .Center
    self.tagHelp.lineBreakMode = .ByWordWrapping
    self.tagHelp.numberOfLines = 0
    self.tagHelp.text = "Tap photo to tag parts."
    self.view.addSubview(self.tagHelp)
    
    self.initMenu()
  }
  
  private func initMenu() {
    let BUTTON_SIZE: CGFloat = 44.0
    let circleImage = UIImage(named: "ic_circle_sm")!
    let circleImageLarge = UIImage(named: "ic_circle")!
    let photoImage = UIImage(named: "ic_camera")!
    let titleImage = UIImage(named: "ic_title")!
    let deleteImage = UIImage(named: "ic_delete")!
    
    let titleButton = PathMenuItem(image: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_GREEN)), highlightedImage: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY)), contentImage: changeImageColor(titleImage, tintColor: UIColor.whiteColor()), highlightedContentImage: changeImageColor(titleImage, tintColor: UIColor.fromRGB(COLOR_GREEN)))
    
    let photoButton = PathMenuItem(image: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_YELLOW)), highlightedImage: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY)), contentImage: changeImageColor(photoImage, tintColor: UIColor.whiteColor()), highlightedContentImage: changeImageColor(photoImage, tintColor: UIColor.fromRGB(COLOR_YELLOW)))
    
    let deleteButton = PathMenuItem(image: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_RED)), highlightedImage: changeImageColor(circleImage, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY)), contentImage: changeImageColor(deleteImage, tintColor: UIColor.whiteColor()), highlightedContentImage: changeImageColor(deleteImage, tintColor: UIColor.fromRGB(COLOR_RED)))
    
    let items = [titleButton, photoButton, deleteButton]
    
    let plusImage = changeImageColor(UIImage(named: "ic_plus")!, tintColor: UIColor.whiteColor())
    let plusImageHighlighted = changeImageColor(UIImage(named: "ic_plus")!, tintColor: UIColor.fromRGB(COLOR_DARK_GRAY))
    let startButton = PathMenuItem(image: changeImageColor(circleImageLarge, tintColor: UIColor.fromRGB(COLOR_ORANGE)), highlightedImage: changeImageColor(circleImageLarge, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY)), contentImage: plusImage, highlightedContentImage: plusImageHighlighted)
    
    self.addMenu = PathMenu(frame: self.view.bounds, startItem: startButton, items: items)
    self.addMenu.delegate = self
    self.addMenu.startPoint = CGPointMake(self.view.frame.width/2, self.view.frame.height-OFFSET_LARGE-BUTTON_SIZE*2)
    self.addMenu.alpha = 0.90
    self.addMenu.menuWholeAngle = CGFloat(degreesToRadians(90))
    self.addMenu.rotateAngle = CGFloat(degreesToRadians(-45))
    self.addMenu.timeOffset = 0.0
    self.addMenu.farRadius = 110.0
    self.addMenu.nearRadius = 90.0
    self.addMenu.endRadius = 100.0
    self.addMenu.animationDuration = 0.3
    self.view.addSubview(self.addMenu)
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
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView == self.photoTable {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.pageControl.currentPage = indexPath.row
        
        break
      }
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
        print("Photo uploaded successfully")
        thumbnailFile.saveInBackgroundWithBlock { (succeeded, error) in
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
  
  func publishStory(sender: AnyObject) {
    if photos.count == 0 {
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
    for var i = 0; i < self.photos.count; i++ {
      let photo = PFObject(className: kPAPPhotoClassKey)
      photo.setObject(PFUser.currentUser()!, forKey: kPAPPhotoUserKey)
      photo.setObject(self.photoFiles[i], forKey: kPAPPhotoPictureKey)
      photo.setObject(self.thumbnailFiles[i], forKey: kPAPPhotoThumbnailKey)
      // photos are public, but may only be modified by the user who uploaded them
      let photoACL = PFACL(user: PFUser.currentUser()!)
      photoACL.setPublicReadAccess(true)
      photo.ACL = photoACL
      
//      // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
//      self.photoPostBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
//        UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskId)
//      }
      
      // userInfo might contain any caption which might have been posted by the uploader
      
      photo.save()
//      print("Photo failed to save: \(error)")
//      let alertController = UIAlertController(title: NSLocalizedString("Couldn't post your photo", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//      let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
//      alertController.addAction(alertAction)
//      self.presentViewController(alertController, animated: true, completion: nil)
      
      relation.addObject(photo)
      
      var annotations: [PFObject] = []
      
      let tags = self.tags[i]
      for tag in tags {
        let annotation = PFObject(className: kAnnotationClassKey)
//        print("Adding \(PartManager.sharedInstance.generateDisplayName(tag.partObject))")
        annotation.setObject(tag.partObject.id, forKey: kAnnotationPartIDKey)
        annotation.setObject(tag.partObject.brand, forKey: kAnnotationBrandKey)
        annotation.setObject(tag.partObject.model, forKey: kAnnotationModelKey)
        annotation.setObject(tag.partObject.partNumber, forKey: kAnnotationPartNumberKey)
        annotation.setObject(photo, forKey: kAnnotationPhotoKey)
//        print("setting tag coordinates to be = \(tag.tagView.frame.origin)")
        let coordinates = [tag.coordinates.x, tag.coordinates.y]
        annotation.addObjectsFromArray(coordinates, forKey: kAnnotationCoordinatesKey)
        
        let ACL = PFACL(user: PFUser.currentUser()!)
        ACL.setPublicReadAccess(true)
        annotation.ACL = ACL
        
        annotations.append(annotation)
        annotation.save()
      }
      
      PAPCache.sharedCache.setAttributesForPhoto(photo, likers: [PFUser](), commenters: [PFUser](), likedByCurrentUser: false, annotations: annotations)
    }
    
    story.save()
    
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
      let cell = tableView.dequeueReusableCellWithIdentifier("PhotoTableViewCell") as! PhotoTableViewCell

      if let image = self.photos[safe: indexPath.row] {
        cell.delegate = self
        cell.isInteractionEnabled = true
        cell.photo.image = image
        cell.tags = self.tags[indexPath.row]
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
      
      self.addTag(partObject)
      self.resetView()
      self.photoTable.reloadData()
    }
  }
  
  // MARK:- PhotoTableViewCellDelegate  
  func tappedPhoto() {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.photoTaggerView.alpha = 1.0
    }
    
    self.searchTagField.becomeFirstResponder()
  }
  
  func removedTag(tagIndex: Int) {
    if tagIndex != -1 {
      let indexPaths: [NSIndexPath] = self.photoTable.indexPathsForVisibleRows!
      for indexPath in indexPaths {
        self.tags[indexPath.row].removeAtIndex(tagIndex)
        
        break
      }
    }
    self.resetView()
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
    
    let image = info[UIImagePickerControllerEditedImage] as! UIImage
    self.photos.append(image)
    let tagArray: [TagObject] = []
    self.tags.append(tagArray) // Add empty Tag Array as init
    
    self.shouldUploadImage(image)
    self.reloadPhotos()
  }
  
  // MARK: - PathMenuDelegate
  func pathMenu(menu: PathMenu, didSelectIndex idx: Int) {
    switch idx {
    case 0: // Add title
      self.onAddTitle()
      break
    case 1: // Add photo
      self.onAddPhoto()
      break
    case 2: // Delete photo
      self.onDeletePhoto()
      break
    default:
      break
    }
  }
  
  func pathMenuDidFinishAnimationOpen(menu: PathMenu) {
    
  }
  
  func pathMenuDidFinishAnimationClose(menu: PathMenu) {
    
  }
  
  func pathMenuWillAnimateClose(menu: PathMenu) {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.tagHelp.alpha = 1.0
    }
  }
  
  func pathMenuWillAnimateOpen(menu: PathMenu) {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.tagHelp.alpha = 0.0
    }
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
    
    let cancelAction = DOAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: DOAlertActionStyle.Cancel, handler: { _ in self.shouldCloseAlertController() })
    let okAction = DOAlertAction(title: NSLocalizedString("OK", comment: ""), style: DOAlertActionStyle.Default, handler: { _ in self.shouldAddTitle() })

    self.alertController.addAction(cancelAction)
    self.alertController.addAction(okAction)
    
    self.presentViewController(self.alertController, animated: true, completion: nil)
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
  
  func shouldAddTitle() {
    self.titleLabel.text = self.titleField.text
    
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.titleView.frame.origin.y = 0.0
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
    
    if self.tags.count > 0 {
      self.tagHelp.text = "Tap photo to tag parts.\n\nDrag to move, or tap to remove."
    } else {
      self.tagHelp.text = "Tap photo to tag parts."
    }
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

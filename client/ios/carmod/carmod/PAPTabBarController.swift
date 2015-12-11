import UIKit
import MobileCoreServices

@objc protocol PAPTabBarControllerDelegate {
  func tabBarController(tabBarController: UITabBarController, cameraButtonTouchUpInsideAction button: UIButton)
}

class PAPTabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var navController: UINavigationController?
  private var alertController: DOAlertController!
  private var photoImage: UIImage!
  
  // MARK:- UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // iOS 7 style
    self.tabBar.tintColor = UIColor.whiteColor()
    self.tabBar.barTintColor = UIColor.blackColor()
    
    self.navController = UINavigationController()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

  // MARK:- UITabBarController
  
  override func setViewControllers(viewControllers: [UIViewController]?, animated: Bool) {
    super.setViewControllers(viewControllers, animated: animated)
    
    let BUTTON_WIDTH: CGFloat = 131.0
    let BUTTON_HEIGHT: CGFloat = self.tabBar.bounds.size.height
    let cameraButton = UIButton(type: UIButtonType.Custom)
    cameraButton.frame = CGRectMake(self.tabBar.frame.width/2-BUTTON_WIDTH/2, 0.0, BUTTON_WIDTH, BUTTON_HEIGHT)
    cameraButton.setImage(UIImage(named: "ButtonCamera.png"), forState: UIControlState.Normal)
    cameraButton.setImage(UIImage(named: "ButtonCameraSelected.png"), forState: UIControlState.Highlighted)
    cameraButton.addTarget(self, action: Selector("photoCaptureButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
    self.tabBar.addSubview(cameraButton)
    
    let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleGesture:"))
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
    swipeUpGestureRecognizer.numberOfTouchesRequired = 1
    cameraButton.addGestureRecognizer(swipeUpGestureRecognizer)
  }
  
  // MARK:- UIImagePickerDelegate
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    self.dismissViewControllerAnimated(false, completion: nil)
    
    let image = info[UIImagePickerControllerEditedImage] as! UIImage
    
    let viewController: PAPEditPhotoViewController = PAPEditPhotoViewController(image: image)
    viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    
    self.navController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    self.navController!.pushViewController(viewController, animated: false)
    
    self.presentViewController(self.navController!, animated: true, completion: nil)
  }
  
  // MARK:- PAPTabBarController
  
  func shouldPresentPhotoCaptureController() -> Bool {
    var presentedPhotoCaptureController: Bool = self.shouldStartCameraController()
    
    if !presentedPhotoCaptureController {
      presentedPhotoCaptureController = self.shouldStartPhotoLibraryPickerController()
    }
    
    return presentedPhotoCaptureController
  }
  
  // MARK:- ()
  
  func photoCaptureButtonAction(sender: AnyObject) {
    let cameraDeviceAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    let photoLibraryAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
    
    if cameraDeviceAvailable && photoLibraryAvailable {
      self.alertController = DOAlertController(title: nil, message: nil, preferredStyle: DOAlertControllerStyle.ActionSheet)
      self.alertController.overlayColor = UIColor(red: 235/255, green: 245/255, blue: 255/255, alpha: 0.7)
      self.alertController.alertViewBgColor = UIColor.fromRGB(COLOR_DARK_GRAY)
      self.alertController.buttonFont[.Default] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Default] = UIColor.fromRGB(COLOR_ORANGE)
      self.alertController.buttonFont[.Cancel] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Cancel] = UIColor.fromRGB(COLOR_MEDIUM_GRAY)
      self.alertController.buttonFont[.Destructive] = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
      self.alertController.buttonBgColor[.Destructive] = UIColor.fromRGB(COLOR_BLUE)
      
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
  
  func handleGesture(gestureRecognizer: UIGestureRecognizer) {
    self.shouldPresentPhotoCaptureController()
  }
  
}

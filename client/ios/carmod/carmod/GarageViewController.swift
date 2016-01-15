//
//  GarageViewController.swift
//  carmod
//
//  Created by Thad Hwang on 12/3/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import MBProgressHUD
import ParseUI

class GarageViewController: UIViewController, AddCarDelegate, UITextFieldDelegate, PartCollectionViewDelegate {
  let ADD_CAR_TEXT = "Add a car to your garage"
  private var addCarView: AddCarView!
  private var carImage: UIImageView!
  private var carTitle: UILabel!
  private var cars: [CarObject] = []
  private var carIndex = -1
  private var partCollectionView: PartCollectionView!
  private var emptyPartView: UIView!
  private var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.rightBarButtonItem = PAPSettingsButtonItem(target: self, action: Selector("settingsButtonAction:"))
    
    self.initCarProfile()
    self.initPartCollectionView()
    self.initAddCarView()

    PartManager.sharedInstance.eventManager.listenTo(EVENT_PART_SEARCH_COMPLETE) { () -> () in
      self.partCollectionView.partObjects = PartManager.sharedInstance.garageParts
      self.emptyPartView.hidden = self.partCollectionView.partObjects.count > 0
      self.activityIndicator.stopAnimating()
    }
    
    CarManager.sharedInstance.eventManager.listenTo(EVENT_CAR_QUERY_COMPLETE) { () -> () in
      if self.carTitle.text == self.ADD_CAR_TEXT {
        self.carImage.image = changeImageColor(UIImage(named: "ic_car")!, tintColor: UIColor.fromRGB(COLOR_MEDIUM_GRAY))
      } else {
        ImageManager.sharedInstance.searchImage(self.carTitle.text!)
      }
    }
    
    ImageManager.sharedInstance.eventManager.listenTo(EVENT_IMAGE_SEARCH_COMPLETE) { () -> () in
      self.carImage.image = ImageManager.sharedInstance.image
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    self.loadCars()
    
    self.activityIndicator.startAnimating()
    PartManager.sharedInstance.getPartsForCurrentUser()
  }
  
  // MARK:- Initializers
  private func initCarProfile() {
    let PROFILE_IMAGE_SIZE: CGFloat = 100.0
    
    self.carImage = UIImageView(frame: CGRect(x: self.view.frame.width/2-PROFILE_IMAGE_SIZE/2, y: OFFSET_XLARGE, width: PROFILE_IMAGE_SIZE, height: PROFILE_IMAGE_SIZE))
    self.carImage.contentMode = .ScaleAspectFill
    self.carImage.clipsToBounds = true
    self.carImage.backgroundColor = UIColor.whiteColor()
    self.carImage.layer.borderColor = UIColor.fromRGB(COLOR_MEDIUM_GRAY).CGColor
    self.carImage.layer.borderWidth = 3.0
    self.carImage.layer.cornerRadius = PROFILE_IMAGE_SIZE/2
    self.carImage.alpha = 1.0
    self.carImage.userInteractionEnabled = true
    self.carImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapCar"))
    self.view.addSubview(self.carImage)
    
    let LABEL_WIDTH: CGFloat = self.view.frame.width-OFFSET_XLARGE*2
    self.carTitle = UILabel(frame: CGRect(x: self.view.frame.width/2-LABEL_WIDTH/2, y: self.carImage.frame.maxY+OFFSET_SMALL, width: LABEL_WIDTH, height: 30.0))
    self.carTitle.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.carTitle.textColor = UIColor.whiteColor()
    self.carTitle.textAlignment = .Center
    self.carTitle.text = ADD_CAR_TEXT
    self.carTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTapCar"))
    self.view.addSubview(self.carTitle)
  }
  
  private func initAddCarView() {
    self.addCarView = AddCarView(frame: self.view.frame)
    self.addCarView.alpha = 0.0
    self.addCarView.delegate = self
    self.view.addSubview(self.addCarView)
    
    let cancelButton = self.addCarView.cancelButton
    cancelButton.addTarget(self, action: "onCloseAddCarView", forControlEvents: .TouchUpInside)
    let closeButton = self.addCarView.closeButton
    closeButton.addTarget(self, action: "onCloseAddCarView", forControlEvents: .TouchUpInside)
  }
  
  private func initPartCollectionView() {
    let divider = UIView(frame: CGRect(x: 0.0, y: 175.0, width: self.view.frame.width, height: 1.0))
    divider.backgroundColor = UIColor.fromRGB(COLOR_DARK_GRAY)
    self.view.addSubview(divider)
    
    let partLabel: UILabel = UILabel()
    partLabel.font = UIFont(name: FONT_BOLD, size: FONTSIZE_STANDARD)
    partLabel.textColor = UIColor.whiteColor()
    partLabel.text = "Your car mods:"
    partLabel.sizeToFit()
    partLabel.frame.origin = CGPoint(x: 5.0, y: 190.0)
    self.view.addSubview(partLabel)
    
    self.partCollectionView = PartCollectionView(frame: CGRect(x: 0.0, y: partLabel.frame.maxY+5.0, width: self.view.frame.width, height: self.view.frame.height-partLabel.frame.maxY-5.0-STATUS_BAR_HEIGHT-TOPNAV_BAR_SIZE-(self.navigationController?.navigationBar.frame.height)!))
    self.partCollectionView.partCollectionViewDelegate = self
    self.partCollectionView.backgroundColor = UIColor.clearColor()
    self.view.addSubview(self.partCollectionView)
    
    let INDICATOR_SIZE: CGFloat = 100.0
    self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.partCollectionView.frame.width/2-INDICATOR_SIZE/2, y: self.partCollectionView.frame.height/2-INDICATOR_SIZE/2, width: INDICATOR_SIZE, height: INDICATOR_SIZE))
    self.activityIndicator.hidesWhenStopped = true
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    self.partCollectionView.addSubview(self.activityIndicator)
    self.activityIndicator.stopAnimating()
    
    self.emptyPartView = UIView(frame: self.partCollectionView.frame)
    self.emptyPartView.backgroundColor = UIColor.blackColor()
    self.emptyPartView.hidden = true
    self.view.addSubview(self.emptyPartView)
    
    let MESSAGE_WIDTH: CGFloat = self.emptyPartView.frame.width-OFFSET_XLARGE*2
    let emptyMessage = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: MESSAGE_WIDTH, height: 0.0))
    emptyMessage.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    emptyMessage.textColor = UIColor.whiteColor()
    emptyMessage.textAlignment = .Center
    emptyMessage.text = "No car mods to display.\nTry adding a photo and tagging the parts. They'll appear here \"auto\"matically."
    emptyMessage.numberOfLines = 0
    emptyMessage.lineBreakMode = .ByWordWrapping
    let requiredHeight = emptyMessage.requiredHeight()
    emptyMessage.frame = CGRect(x: self.emptyPartView.frame.width/2-MESSAGE_WIDTH/2, y: OFFSET_XLARGE*2, width: MESSAGE_WIDTH, height: requiredHeight)
    self.emptyPartView.addSubview(emptyMessage)
  }
  
  // MARK:- Callbacks
  func onTapCar() {
    if self.carTitle.text != ADD_CAR_TEXT {
      let alert = UIAlertController(title: "Remove Car?", message: "Remove \(self.carTitle.text!) from your garage?", preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "Remove", style: .Default, handler: { (alertView) -> Void in
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)

        let carObject = self.cars[self.carIndex]
        let query = PFQuery(className: kEntityClassKey)
        query.whereKey(kEntityObjectIDKey, equalTo: carObject.objectID)
        query.findObjectsInBackgroundWithBlock {
          (objects: [AnyObject]?, error: NSError?) -> Void in
          for object in objects! {
            object.deleteEventually()
          }
        }

        self.cars.removeAtIndex(self.carIndex)
        self.carIndex = self.cars.count-1
        self.carTitle.text = self.ADD_CAR_TEXT
        
        MBProgressHUD.hideHUDForView(self.view, animated: true)
      }))
      self.presentViewController(alert, animated: true, completion: nil)

    } else {
      self.onShowAddCarView()
    }
  }
  
  func onShowAddCarView() {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL) { () -> Void in
      self.addCarView.alpha = 1.0
    }
  }
  
  func onCloseAddCarView() {
    self.addCarView.alpha = 0.0
  }
  
  // MARK:- AddCarDelegate
  func addedCar() {
    self.loadCars()
    self.onCloseAddCarView()
  }
  
  // MARK:- PartCollectionViewDelegate
  func tappedPart(partObject: PartObject, isSelected: Bool) {
    
  }
  
  // MARK:- Callbacks
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
  
  // MARK:- Private methods

  
  // MARK:- Public methods
  func loadCars() {
    let query = PFQuery(className: kEntityClassKey)
    query.whereKey(kEntityUserKey, equalTo: PFUser.currentUser()!)
    query.orderByDescending("createdAt")
    query.cachePolicy = PFCachePolicy.NetworkOnly
    
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
      if let cars = objects {
        for car in cars as! [PFObject] {
          let carObject = CarObject()
          carObject.objectID = car.objectId
          carObject.year = car.objectForKey(kEntityYearKey) as! Int
          carObject.make = car.objectForKey(kEntityMakeKey) as! String
          carObject.model = car.objectForKey(kEntityModelKey) as! String
          self.carTitle.text = "\(carObject.year!) \(carObject.make!) \(carObject.model!)"
          self.cars.append(carObject)
          self.carIndex = self.cars.count-1
        }
      }
      
      CarManager.sharedInstance.eventManager.trigger(EVENT_CAR_QUERY_COMPLETE)
    }
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
}

//
//  GarageViewController.swift
//  carmod
//
//  Created by Thad Hwang on 12/3/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import MBProgressHUD
import ParseUI

class GarageViewController: UIViewController, AddCarDelegate, UITextFieldDelegate {
  let ADD_CAR_TEXT = "Add a car to your garage"
  private var addCarView: AddCarView!
  private var carImage: PFImageView!
  private var carTitle: UILabel!
  private var addCarButton: UIButton!
  private var cars: [CarObject] = []
  private var carIndex = -1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.rightBarButtonItem = PAPSettingsButtonItem(target: self, action: Selector("settingsButtonAction:"))
    
    self.initCarProfile()
    self.initAddCarView()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.loadCars()
  }
  
  // MARK:- Initializers
  private func initCarProfile() {
    let PROFILE_IMAGE_SIZE: CGFloat = 100.0
    
    self.carImage = PFImageView(frame: CGRect(x: self.view.frame.width/2-PROFILE_IMAGE_SIZE/2, y: OFFSET_XLARGE, width: PROFILE_IMAGE_SIZE, height: PROFILE_IMAGE_SIZE))
    self.carImage.clipsToBounds = true
    self.carImage.layer.cornerRadius = PROFILE_IMAGE_SIZE/2
    self.carImage.alpha = 0.0
    self.carImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onShowAddCarView"))
    self.view.addSubview(self.carImage)
    
    self.addCarButton = UIButton(frame: self.carImage.frame)
    self.addCarButton.backgroundColor = UIColor.whiteColor()
    self.addCarButton.layer.borderColor = UIColor.fromRGB(COLOR_MEDIUM_GRAY).CGColor
    self.addCarButton.layer.borderWidth = 3.0
    self.addCarButton.layer.cornerRadius = PROFILE_IMAGE_SIZE/2
    self.addCarButton.clipsToBounds = true
    let carImage = changeImageColor(UIImage(named: "ic_car")!, tintColor: UIColor.fromRGB(COLOR_MEDIUM_GRAY))
    self.addCarButton.setImage(carImage, forState: .Normal)
    let OFFSET: CGFloat = 15.0
    self.addCarButton.contentEdgeInsets = UIEdgeInsets(top: OFFSET, left: OFFSET, bottom: OFFSET, right: OFFSET)
    self.addCarButton.alpha = 1.0
    self.addCarButton.addTarget(self, action: "onTapCar", forControlEvents: .TouchUpInside)
    self.view.addSubview(self.addCarButton)
    
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
  
  // MARK:- Public methods
  func loadCars() {
    let query = PFQuery(className: kEntityClassKey)
    query.whereKey(kEntityUserKey, equalTo: PFUser.currentUser()!)
    query.orderByDescending("createdAt")
    query.cachePolicy = PFCachePolicy.NetworkOnly
    
    query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
      if error != nil {
        return
      }
      
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
    }
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
}

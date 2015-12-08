//
//  AddCarView.swift
//  carmod
//
//  Created by Thad Hwang on 12/4/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import MBProgressHUD

protocol AddCarDelegate: class {
  func addedCar()
}

class AddCarView: UIView, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
  let VIEW_HEIGHT: CGFloat = 160.0
  
  weak var delegate: AddCarDelegate?
  
  private var keyboardHeight: CGFloat = 0.0
  private var blurView: UIVisualEffectView!
  private var backgroundView: UIView!
  private var yearField: CustomTextField!
  private var makeModelField: CustomTextField!
  private var addButton: UIButton!
  private var carResultsTable: UITableView!
  private var selectedCarObject: CarObject!
  var closeButton: UIButton!
  var cancelButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
    CarManager.sharedInstance.eventManager.listenTo(EVENT_CAR_RESULTS_COMPLETE) { () -> () in
      self.refreshSearchResults(CarManager.sharedInstance.searchResults.count)
    }
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    self.blurView = UIVisualEffectView(effect: blurEffect)
    self.blurView.frame = self.bounds
    self.blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
    self.addSubview(self.blurView)
    
    self.backgroundView = UIView(frame: CGRect(x: OFFSET_SMALL, y: self.frame.height/2-VIEW_HEIGHT, width: self.frame.width-OFFSET_SMALL*2, height: VIEW_HEIGHT))
    self.backgroundView.backgroundColor = UIColor.whiteColor()
    self.backgroundView.clipsToBounds = true
    self.backgroundView.layer.cornerRadius = 8.0
    self.addSubview(self.backgroundView)
    
    self.initLabels()
    self.initLookupTable()
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK:- Initializers
  private func initLabels() {
    let closeImage = changeImageColor(UIImage(named: "ic_close")!, tintColor: UIColor.fromRGB(COLOR_NEAR_BLACK))
    self.closeButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: STANDARD_BUTTON_SIZE, height: STANDARD_BUTTON_SIZE))
    self.closeButton.contentEdgeInsets = UIEdgeInsets(top: OFFSET_STANDARD, left: OFFSET_STANDARD, bottom: OFFSET_STANDARD, right: OFFSET_STANDARD)
    self.closeButton.setImage(closeImage, forState: UIControlState.Normal)
    self.closeButton.addTarget(self, action: "closeKeyboard", forControlEvents: .TouchUpInside)
    self.backgroundView.addSubview(self.closeButton)
    
    let LABEL_HEIGHT: CGFloat = 30.0
    
    let titleLabel = UILabel(frame: CGRect(x: OFFSET_SMALL, y: STANDARD_BUTTON_SIZE/2-LABEL_HEIGHT/2, width: self.backgroundView.frame.width-OFFSET_SMALL*2, height: LABEL_HEIGHT))
    titleLabel.font = UIFont(name: FONT_BOLD, size: FONTSIZE_LARGE)
    titleLabel.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    titleLabel.textAlignment = .Center
    titleLabel.text = "Add a car to your garage:"
    self.backgroundView.addSubview(titleLabel)
    
    let YEAR_WIDTH: CGFloat = 60.0
    let yPos: CGFloat = titleLabel.frame.maxY+OFFSET_STANDARD
    
    self.yearField = CustomTextField(frame: CGRect(x: OFFSET_SMALL, y: yPos, width: YEAR_WIDTH, height: LABEL_HEIGHT))
    self.yearField.placeholder = "Year"
    self.yearField.layer.borderColor = UIColor.fromRGB(COLOR_DARK_GRAY).CGColor
    self.yearField.layer.borderWidth = 1.0
    self.yearField.layer.cornerRadius = 2.0
    self.yearField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.yearField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.yearField.autocorrectionType = .No
    self.yearField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.yearField.setValue(UIColor.fromRGB(COLOR_MEDIUM_GRAY), forKeyPath: "_placeholderLabel.textColor")
    self.yearField.keyboardType = .NumberPad
    self.yearField.delegate = self
    self.yearField.addTarget(self, action: "onChangeText:", forControlEvents: UIControlEvents.EditingChanged)
    self.backgroundView.addSubview(self.yearField)
    
    let FIELD_WIDTH: CGFloat = self.backgroundView.frame.width-YEAR_WIDTH-OFFSET_SMALL*3
    self.makeModelField = CustomTextField(frame: CGRect(x: self.yearField.frame.maxX+OFFSET_SMALL, y: yPos, width: FIELD_WIDTH, height: LABEL_HEIGHT))
    self.makeModelField.placeholder = "Make and Model"
    self.makeModelField.layer.borderColor = UIColor.fromRGB(COLOR_DARK_GRAY).CGColor
    self.makeModelField.layer.borderWidth = 1.0
    self.makeModelField.layer.cornerRadius = 2.0
    self.makeModelField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_MEDIUM)
    self.makeModelField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.makeModelField.autocorrectionType = .No
    self.makeModelField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.makeModelField.setValue(UIColor.fromRGB(COLOR_MEDIUM_GRAY), forKeyPath: "_placeholderLabel.textColor")
    self.makeModelField.delegate = self
    self.makeModelField.addTarget(self, action: "onChangeText:", forControlEvents: UIControlEvents.EditingChanged)
    self.backgroundView.addSubview(self.makeModelField)
    
    let BUTTON_WIDTH: CGFloat = (self.backgroundView.frame.width-OFFSET_SMALL*3)/2
    
    self.cancelButton = UIButton(frame: CGRect(x: OFFSET_SMALL, y: self.makeModelField
      .frame.maxY+OFFSET_LARGE, width: BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.cancelButton.setTitle("CANCEL", forState: .Normal)
    self.cancelButton.setTitleColor(UIColor.fromRGB(COLOR_DARK_GRAY), forState: .Normal)
    self.cancelButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.cancelButton.backgroundColor = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.cancelButton.layer.cornerRadius = 4.0
    self.cancelButton.addTarget(self, action: "closeKeyboard", forControlEvents: .TouchUpInside)
    self.backgroundView.addSubview(self.cancelButton)
    
    self.addButton = UIButton(frame: CGRect(x: self.cancelButton.frame.maxX+OFFSET_SMALL, y: self.makeModelField
      .frame.maxY+OFFSET_LARGE, width: BUTTON_WIDTH, height: STANDARD_BUTTON_HEIGHT))
    self.addButton.setTitle("ADD TO GARAGE", forState: .Normal)
    self.addButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.addButton.setTitleColor(UIColor.fromRGB(COLOR_MEDIUM_GRAY), forState: .Disabled)
    self.addButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.addButton.backgroundColor = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.addButton.layer.cornerRadius = 4.0
    self.addButton.addTarget(self, action: "onAddToGarage:", forControlEvents: .TouchUpInside)
    self.addButton.enabled = false
    self.backgroundView.addSubview(self.addButton)
  }
  
  private func initLookupTable() {
    self.selectedCarObject = CarObject()
    
    self.carResultsTable = UITableView(frame: CGRect(x: self.makeModelField.frame.origin.x, y: self.makeModelField.frame.maxY, width: self.makeModelField.frame.width, height: 0.0))
    self.carResultsTable.registerClass(CarTableViewCell.classForCoder(), forCellReuseIdentifier: "CarTableViewCell")
    self.carResultsTable.layer.borderColor = UIColor.fromRGB(COLOR_LIGHT_GRAY).CGColor
    self.carResultsTable.layer.borderWidth = 1.0
    self.carResultsTable.clipsToBounds = true
    self.carResultsTable.backgroundColor = UIColor.whiteColor()
    self.carResultsTable.separatorColor = UIColor.fromRGB(COLOR_LIGHT_GRAY)
    self.carResultsTable.rowHeight = SEARCH_RESULTS_ROW_HEIGHT
    self.carResultsTable.delegate = self
    self.carResultsTable.dataSource = self
    self.carResultsTable.bounces = false
    self.carResultsTable.alpha = 0.0
    if (self.carResultsTable.respondsToSelector("separatorInset")) {
      self.carResultsTable.separatorInset = UIEdgeInsetsZero
    }
    self.addSubview(self.carResultsTable)
  }
  
  // MARK: - UITableViewDataSource
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    print("CarManager.sharedInstance.searchResults.count = \(CarManager.sharedInstance.searchResults.count)")
    return CarManager.sharedInstance.searchResults.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CarTableViewCell") as! CarTableViewCell

    if let carObject = CarManager.sharedInstance.searchResults[safe: indexPath.row] {
      if carObject.id == kCarJSONEmptyKey {
        cell.carObject = nil
      } else {
        cell.carObject = carObject
      }
      
      cell.searchKeywords = self.makeModelField.text!
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let carObject = CarManager.sharedInstance.searchResults[indexPath.row]
    
    if carObject.id == kCarJSONEmptyKey {
      carObject.id = ""
      carObject.make = self.makeModelField.text!
      carObject.model = ""
    }
    
    self.selectedCarObject = carObject
    self.makeModelField.text = "\(carObject.make) \(carObject.model)"
    
    self.resetView()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == self.yearField {
      let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
      let components = string.componentsSeparatedByCharactersInSet(inverseSet)
      let filtered = components.joinWithSeparator("")
      
      return string == filtered
    }
    
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
  
  // MARK:- Callbacks
  func onAddToGarage(sender: UIButton) {
    if sender.enabled {
      self.closeKeyboard()
      
      // create a car object
      let car = PFObject(className: kEntityClassKey)
      car.setObject(PFUser.currentUser()!, forKey: kEntityUserKey)
      let year = Int(self.yearField.text!)
      car.setObject(year!, forKey: kEntityYearKey)
      
      car.setObject(self.selectedCarObject.make, forKey: kEntityMakeKey)
      car.setObject(self.selectedCarObject.model, forKey: kEntityModelKey)
      
      MBProgressHUD.showHUDAddedTo(self, animated: true)
      
      car.saveInBackgroundWithBlock { (success, error) -> Void in
        MBProgressHUD.hideHUDForView(self, animated: true)
        
        if success {
          if let delegate = self.delegate {
            delegate.addedCar()
          }
        } else {
          
        }
      }
    }
  }
  
  func onChangeText(sender: UITextField) {
    if sender == self.makeModelField {
      if sender.text != "" {
        CarManager.sharedInstance.searchCar(self.makeModelField.text!)
      } else {
        CarManager.sharedInstance.clearSearchResults()
        self.carResultsTable.alpha = 0.0
      }
    }
    
    if self.yearField.text != "" && self.makeModelField.text != "" {
      self.addButton.backgroundColor = UIColor.fromRGB(COLOR_ORANGE)
      self.addButton.enabled = true
    } else {
      self.addButton.backgroundColor = UIColor.fromRGB(COLOR_LIGHT_GRAY)
      self.addButton.enabled = false
    }
  }
  
  // MARK:- Keyboard methods
  func closeKeyboard() {
    if self.yearField.isFirstResponder() {
      self.yearField.resignFirstResponder()
    }
    if self.makeModelField.isFirstResponder() {
      self.makeModelField.resignFirstResponder()
    }
  }
  
  func keyboardWillShow(sender: NSNotification) {
    if let userInfo = sender.userInfo {
      if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
        self.keyboardHeight = keyboardHeight
        
        UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
          self.backgroundView.frame.origin.y = OFFSET_STANDARD
        })
      }
    }
  }
  
  func keyboardWillHide(sender: NSNotification) {
    UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
      self.backgroundView.frame.origin.y = self.frame.height/2-self.VIEW_HEIGHT
    })
  }
  
  // MARK:- Public methods
  func refreshSearchResults(numResults: Int) {
    if CarManager.sharedInstance.searchResults.count > 0 {
      let FIELD_POS: CGPoint = self.backgroundView.convertPoint(self.makeModelField.frame.origin, toView: self)
      let SEARCH_VIEWABLE_AREA: CGFloat = self.frame.height-self.keyboardHeight-FIELD_POS.y-self.makeModelField.frame.height-STATUS_BAR_HEIGHT-TOPNAV_BAR_SIZE
      let SEARCH_HEIGHT: CGFloat = SEARCH_RESULTS_ROW_HEIGHT*CGFloat(numResults)
      
      self.carResultsTable.frame = CGRect(x: FIELD_POS.x, y: FIELD_POS.y+self.makeModelField.frame.height, width: self.carResultsTable.frame.width, height: (SEARCH_HEIGHT > SEARCH_VIEWABLE_AREA) ? SEARCH_VIEWABLE_AREA : SEARCH_HEIGHT)
      
      UIView.animateWithDuration(TRANSITION_TIME_NORMAL, animations: { () -> Void in
        self.carResultsTable.alpha = 1.0
      })
      self.carResultsTable.reloadData()
    } else {
      self.carResultsTable.alpha = 0.0
    }
  }
  
  // MARK:- Private methods
  private func resetView() {
    if self.makeModelField.isFirstResponder() {
      self.makeModelField.resignFirstResponder()
    }
    self.carResultsTable.alpha = 0.0
  }
}

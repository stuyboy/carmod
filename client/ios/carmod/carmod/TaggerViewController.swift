//
//  TaggerViewController.swift
//  carmod
//
//  Created by Thad Hwang on 1/11/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import DOPDropDownMenu_Enhanced

class TaggerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, DOPDropDownMenuDataSource, DOPDropDownMenuDelegate, PartCollectionViewDelegate {
  private let categories: [String] = [
    "All Categories",
    "Accessories",
    "Air Conditioning & Heat",
    "Air Intake & Fuel Delivery",
    "Brakes",
    "Charging & Startup Systems",
    "Computer, Chip, Cruise Control",
    "Cooling System",
    "Decals/Emblems/License Frames",
    "Electric Vehicle Parts",
    "Emission System",
    "Engines & Components",
    "Exhaust",
    "Exterior",
    "Filters",
    "Gaskets",
    "Gauges",
    "Glass",
    "Ignition System",
    "Interio",
    "Lighting & Lamps",
    "Safety & Security",
    "Suspension & Steering",
    "Transmission & Drivetrain",
    "Turbos, Nitrous, Superchargers",
    "Wheels, Tires & Parts",
  ]
  private let brands: [String] = [
    "All Brands",
    "ACDelco",
    "Bestop",
    "Bosch",
    "Camco",
    "Curt",
    "Goal Zero",
    "K&N",
    "Lund",
    "Meguiars",
    "Mopar",
    "Power Stop",
    "Rightline Gear",
  ]
  
  private var statusBar: UIView!
  private var topNavBar: UIView!
  private var keyboardHeight: CGFloat = 0.0
  
  private var saveButton: UIButton!
  private var filterMenu: DOPDropDownMenu!
  private var partCollectionView: PartCollectionView!
  private var selectedPart: PartObject!
  
  private var photoTaggerView: PhotoTaggerView!
  private var photoTaggerViewOrigin: CGPoint!
  private var searchTagField: UITextField!
  private var partTypeButton: UIButton!
  private var cancelButton: UIButton!
  private var pickerView: UIView!
  private var partPicker: UIPickerView!
  
  var editPhotoViewController: EditPhotoViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    PartManager.sharedInstance.eventManager.listenTo(EVENT_SEARCH_RESULTS_COMPLETE) { () -> () in
      self.partCollectionView.partObjects = PartManager.sharedInstance.searchResults
    }
    
    self.initTopNav()
    self.initTaggerBar()
    
    self.initFilters()
    self.initPartCollectionView()
    self.searchParts("*")
    
    self.initPartPicker()
    
    self.view.bringSubviewToFront(self.filterMenu)
  }
  
  override func viewDidAppear(animated: Bool) {
    self.filterMenu.reloadData()
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  // MARK:- Initializers
  private func initTopNav() {
    self.statusBar = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: STATUS_BAR_HEIGHT))
    self.statusBar.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.view.addSubview(self.statusBar)
    
    self.topNavBar = UIView(frame: CGRect(x: 0.0, y: STATUS_BAR_HEIGHT, width: self.view.frame.width, height: TOPNAV_BAR_SIZE))
    self.topNavBar.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.view.addSubview(self.topNavBar)
    
    let logoView = UIImageView(image: UIImage(named: "app_logo"))
    let LOGO_HEIGHT: CGFloat = 25.0
    let LOGO_WIDTH: CGFloat = LOGO_HEIGHT*(270/60)
    logoView.frame = CGRect(x: self.topNavBar.frame.width/2-LOGO_WIDTH/2, y: self.topNavBar.frame.height/2-LOGO_HEIGHT/2, width: LOGO_WIDTH, height: LOGO_HEIGHT)
    self.topNavBar.addSubview(logoView)
    
    let BUTTON_WIDTH: CGFloat = 60.0
    let BUTTON_HEIGHT: CGFloat = self.topNavBar.frame.height
    self.saveButton = UIButton(frame: CGRect(x: self.topNavBar.frame.width-BUTTON_WIDTH, y: 0.0, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
    self.saveButton.titleLabel?.textAlignment = .Center
    self.saveButton.titleLabel?.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_LARGE)
    self.saveButton.setTitle("Save", forState: .Normal)
    self.saveButton.setTitleColor(UIColor.fromRGB(COLOR_ORANGE), forState: .Normal)
    self.saveButton.setTitleColor(UIColor.fromRGB(COLOR_MEDIUM_GRAY), forState: .Disabled)
    self.saveButton.setTitle("Save", forState: .Disabled)
    self.saveButton.enabled = false
    self.saveButton.addTarget(self, action: "onSave:", forControlEvents: .TouchUpInside)
    self.topNavBar.addSubview(self.saveButton)
    
    let BUTTON_SIZE: CGFloat = self.topNavBar.frame.height
    let closeButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: BUTTON_SIZE, height: BUTTON_SIZE))
    let closeImage = changeImageColor(UIImage(named: "ic_close")!, tintColor: UIColor.fromRGB(COLOR_LIGHT_GRAY))
    closeButton.setImage(closeImage, forState: .Normal)
    let INSET_OFFSET: CGFloat = 15.0
    closeButton.contentEdgeInsets = UIEdgeInsets(top: INSET_OFFSET, left: INSET_OFFSET, bottom: INSET_OFFSET, right: INSET_OFFSET)
    closeButton.addTarget(self, action: "onClose:", forControlEvents: .TouchUpInside)
    self.topNavBar.addSubview(closeButton)
  }
  
  private func initTaggerBar() {
    self.photoTaggerView = PhotoTaggerView(frame: CGRect(x: 0.0, y: self.topNavBar.frame.maxY, width: self.view.frame.width, height: TOPNAV_BAR_SIZE))
    self.photoTaggerView.backgroundColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.photoTaggerViewOrigin = self.photoTaggerView.frame.origin
    
    self.searchTagField = self.photoTaggerView.tagField
    self.searchTagField.addTarget(self, action: "onChangeText:", forControlEvents: UIControlEvents.EditingChanged)
    self.searchTagField!.delegate = self
    
    self.partTypeButton = self.photoTaggerView.partTypeButton
    self.partTypeButton.addTarget(self, action: "onTapPartType:", forControlEvents: .TouchUpInside)
    
    self.cancelButton = self.photoTaggerView.cancelButton
    self.cancelButton.addTarget(self, action: "stopTagging", forControlEvents: .TouchUpInside)
    
    self.view.addSubview(self.photoTaggerView)
  }
  
  private func initFilters() {
    self.filterMenu = DOPDropDownMenu(origin: CGPoint(x: 0.0, y: self.photoTaggerView.frame.maxY), andHeight: TOPNAV_BAR_SIZE)
    self.filterMenu.delegate = self
    self.filterMenu.dataSource = self
    self.filterMenu.detailTextFont = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.filterMenu.detailTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.filterMenu.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.view.addSubview(self.filterMenu)
  }
  
  private func initPartCollectionView() {
    self.partCollectionView = PartCollectionView(frame: CGRect(x: 0.0, y: self.filterMenu.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-TOPNAV_BAR_SIZE), isSelectable: true)
    self.partCollectionView.partCollectionViewDelegate = self
    self.partCollectionView.backgroundColor = UIColor.whiteColor()
    self.view.addSubview(self.partCollectionView)
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
  
  // MARK:- DOPDropDownMenuDataSource
  func menu(menu: DOPDropDownMenu!, numberOfRowsInColumn column: Int) -> Int {
    switch column {
      case 0:
        return self.categories.count
      case 1:
        return self.brands.count
      default:
        return 0
    }
  }
  
  func menu(menu: DOPDropDownMenu!, titleForRowAtIndexPath indexPath: DOPIndexPath!) -> String! {
    switch indexPath.column {
      case 0:
        return self.categories[indexPath.row]
      case 1:
        return self.brands[indexPath.row]
      default:
        return ""
    }
  }
  
  func numberOfColumnsInMenu(menu: DOPDropDownMenu!) -> Int {
    return 2
  }
  
  // MARK:- DOPDropDownMenuDelegate
  func menu(menu: DOPDropDownMenu!, didSelectRowAtIndexPath indexPath: DOPIndexPath!) {
    
  }
  
  // MARK:- PartCollectionViewDelegate
  func tappedPart(partObject: PartObject, isSelected: Bool) {
    self.selectedPart = isSelected ? partObject : nil
    self.saveButton.enabled = isSelected
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
    
//    self.addTag(partObject)
    self.resetView()
//    self.photoTable.reloadData()
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
//    self.selectedPart = PartManager.sharedInstance.PART_CATEGORIES[row]
  }

  // MARK:- Callbacks
  func onChangeText(sender: UITextField) {
    if sender.text != "" {
      self.searchParts(sender.text!)
    } else {
      PartManager.sharedInstance.clearSearchResults()
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
//    self.photoTaggerView.partType = PartType(rawValue: self.selectedPart) as PartType!
    self.pickerView.hidden = true
  }
  
  func onCancelPicker(sender: UIButton) {
    self.pickerView.hidden = true
  }
  
  func onClose(sender: AnyObject) {
    self.closeView()
  }
  
  func onSave(sender: AnyObject) {
    if self.selectedPart != nil {
      self.editPhotoViewController.addTag(self.selectedPart)
    }
    self.closeView()
  }
  
  // MARK:- Private methods
  func resetView() {
    if self.searchTagField.isFirstResponder() {
      self.searchTagField.resignFirstResponder()
    }
    
    self.searchTagField.text = ""
    self.photoTaggerView.reset()
    self.pickerView.hidden = true
    
    self.searchParts("*")
  }
  
  private func searchParts(query: String) {
    PartManager.sharedInstance.searchPart(query)
  }
  
  private func closeView() {
    self.dismissViewControllerAnimated(true, completion: nil)
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
}

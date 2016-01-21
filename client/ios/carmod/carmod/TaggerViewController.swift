//
//  TaggerViewController.swift
//  carmod
//
//  Created by Thad Hwang on 1/11/16.
//  Copyright © 2016 Thunderchicken Labs, LLC. All rights reserved.
//

import UIKit
import DOPDropDownMenu_Enhanced

class TaggerViewController: UIViewController, DOPDropDownMenuDataSource, DOPDropDownMenuDelegate, PartCollectionViewDelegate {
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
  private var saveButton: UIButton!
  private var filterMenu: DOPDropDownMenu!
  private var partCollectionView: PartCollectionView!
  private var selectedPart: PartObject!
  var editPhotoViewController: EditPhotoViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
//    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onCancel:"))
//    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: Selector("onSave:"))
    
    self.initTopNav()
    self.initFilters()
    self.initPartCollectionView()
    self.loadParts()
    
    self.view.bringSubviewToFront(self.filterMenu)
    
    PartManager.sharedInstance.eventManager.listenTo(EVENT_SEARCH_RESULTS_COMPLETE) { () -> () in
      self.partCollectionView.partObjects = PartManager.sharedInstance.searchResults
    }
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
  
  private func initFilters() {
    self.filterMenu = DOPDropDownMenu(origin: CGPoint(x: 0.0, y: self.topNavBar.frame.maxY), andHeight: TOPNAV_BAR_SIZE)
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
  
  // MARK:- Private methods
  private func loadParts() {
    PartManager.sharedInstance.searchPart("*")
  }
  
  private func closeView() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK:- Callbacks
  func onClose(sender: AnyObject) {
    self.closeView()
  }
  
  func onSave(sender: AnyObject) {
    if self.selectedPart != nil {
      self.editPhotoViewController.addTag(self.selectedPart)
    }
    self.closeView()
  }
}

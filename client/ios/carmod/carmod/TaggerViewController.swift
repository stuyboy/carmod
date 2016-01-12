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
  private var filterMenu: DOPDropDownMenu!
  private var partCollectionView: PartCollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UIImageView(image: UIImage(named: "app_logo"))
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("onCancel:"))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Done, target: self, action: Selector("onSave:"))
    
    self.initPartCollectionView()
    self.initFilters()
    self.loadParts()
    
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
  private func initFilters() {
    self.filterMenu = DOPDropDownMenu(origin: CGPoint(x: 0.0, y: 0.0), andHeight: TOPNAV_BAR_SIZE)
    self.filterMenu.delegate = self
    self.filterMenu.dataSource = self
    self.filterMenu.detailTextFont = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.filterMenu.detailTextColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.filterMenu.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.view.addSubview(self.filterMenu)
  }
  
  private func initPartCollectionView() {
    self.partCollectionView = PartCollectionView(frame: CGRect(x: 0.0, y: TOPNAV_BAR_SIZE, width: self.view.frame.width, height: self.view.frame.height-TOPNAV_BAR_SIZE-(self.navigationController?.navigationBar.frame.height)!))
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
  func tappedPart(image: UIImage, isSelected: Bool) {
    
  }
  
  // MARK:- Private methods
  private func loadParts() {
    PartManager.sharedInstance.searchPart("*")
  }

  // MARK:- Callbacks
  func onCancel(sender: AnyObject) {
    self.parentViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func onSave(sender: AnyObject) {
    
  }
}

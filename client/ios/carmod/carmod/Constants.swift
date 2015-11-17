//
//  Constants.swift
//  SwiftAnyPic
//
//  Created by Thad Hwang on 11/16/15.
//  Copyright © 2015 parse. All rights reserved.
//

/*
green:        0x559A00 #559A00
alt-green:    0x559A00 #559A00 85 154 0
yellow:       0xFFD166 #FFD166 255 209 102
red:          0xEF476F #EF476F 239 71 111
blue:         0x26547C #26547C 38 84 124
*/

import UIKit

// App constants
let IS_DEBUG: Bool = false

let APP_NAME: String = "Car Mod"
let APP_ID: UInt = 0
let APP_DOMAIN = "com.thunderchickenlabs.carmod"
let APP_DOWNLOAD_URL: String = "https://itunes.apple.com/us/app/id\(APP_ID)"
let APP_DOWNLOAD_URL_SHORTENED: String = "http://apple.co/1KaRNRE"
let APP_RATE_URL: String = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(APP_ID)&pageNumber=0&type=Purple+Software&mt=8"
let APP_RATE_MESSAGE: String = "If you enjoy using \(APP_NAME), mind taking a moment to rate it? Thanks for your support!"
let APP_FIRST_OPEN = "AppFirstOpen"
let APP_FIRST_FAVORITE = "AppFirstFavorite"
let APP_LOCATION_PROMPT = "AppLocationPrompt"
let APP_LAST_LOCATION = "AppLastLocation"

let IS_IPHONE = UIDevice.currentDevice().userInterfaceIdiom == .Phone
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH = min(SCREEN_WIDTH, SCREEN_HEIGHT)
let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH < 568.0
let IS_IPHONE_5 = IS_IPHONE && SCREEN_MAX_LENGTH == 568.0
let IS_IPHONE_5_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH <= 568.0
let IS_IPHONE_6 = IS_IPHONE && SCREEN_MAX_LENGTH == 667.0
let IS_IPHONE_6P = IS_IPHONE && SCREEN_MAX_LENGTH == 736.0

let IPHONE_4_RATIO: CGFloat = 480.0/480.0
let IPHONE_5_RATIO: CGFloat  = 568.0/480.0
let IPHONE_6_RATIO: CGFloat  = 667.0/480.0
let IPHONE_6P_RATIO: CGFloat  = 736.0/480.0

// Font constants
let FONT_PRIMARY: String = "Lato-Regular"
let FONT_LIGHT: String = "Lato-Light"
let FONT_BOLD: String = "Lato-Bold"

let FONTSIZE_XLARGE: CGFloat = IS_IPHONE_4_OR_LESS ? 22.0 : IS_IPHONE_5_OR_LESS ? 24.0 : 26.0
let FONTSIZE_LARGE: CGFloat = IS_IPHONE_4_OR_LESS ? 16.0 : IS_IPHONE_5_OR_LESS ? 18.0 : 20.0
let FONTSIZE_STANDARD: CGFloat = IS_IPHONE_4_OR_LESS ? 15.0 : IS_IPHONE_5_OR_LESS ? 16.0 : 18.0
let FONTSIZE_MEDIUM: CGFloat = IS_IPHONE_4_OR_LESS ? 14.0 : IS_IPHONE_5_OR_LESS ? 14.0 : 16.0
let FONTSIZE_SMALL: CGFloat = IS_IPHONE_4_OR_LESS ? 12.0 : IS_IPHONE_5_OR_LESS ? 12.0 : 14.0
let FONTSIZE_XSMALL: CGFloat = IS_IPHONE_4_OR_LESS ? 9.0 : IS_IPHONE_5_OR_LESS ? 9.0 : 11.0
let FONTSIZE_TINY: CGFloat = IS_IPHONE_4_OR_LESS ? 7.0 : IS_IPHONE_5_OR_LESS ? 7.0 : 8.5

// Color constants
let COLOR_PRIMARY: UInt = 0x559A00
let COLOR_SECONDARY: UInt = 0xFFD166
let COLOR_TERTIARY: UInt = 0xEF476F
let COLOR_GREEN: UInt = 0x559A00 //0x4DBC6B
let COLOR_MINT: UInt = 0x06D6A0
let COLOR_YELLOW: UInt = 0xfcbf00
let COLOR_RED: UInt = 0xEF476F
let COLOR_BLUE: UInt = 0x26547C
let COLOR_LIGHT_BLUE: UInt = 0x387BB8
let COLOR_BRIGHT_BLUE: UInt = 0x0353A4
let COLOR_LIGHT_GRAY: UInt = 0xDDDDDD
let COLOR_MEDIUM_GRAY: UInt = 0x999999
let COLOR_DARK_GRAY: UInt = 0x555555
let COLOR_NEAR_BLACK: UInt = 0x222222
let COLOR_OFF_WHITE: UInt = 0xfafafa
let COLOR_CANCEL: UInt = 0xE1E1E1
let COLOR_OK: UInt = 0xF9F9F9

let OFFSET_XLARGE: CGFloat = 25.0
let OFFSET_LARGE: CGFloat = 20.0
let OFFSET_STANDARD: CGFloat = 15.0
let OFFSET_SMALL: CGFloat = 10.0
let OFFSET_XSMALL: CGFloat = 7.5
let OFFSET_TINY: CGFloat = 5.0
let OFFSET_STATUS_BAR: CGFloat = 15.0

let TRANSITION_TIME_FAST: Double = 0.15
let TRANSITION_TIME_NORMAL: Double = 0.30
let TRANSITION_TIME_SLOW: Double = 0.45
let OFFSCREEN_START_POS: CGFloat = 2000.0

let STATUS_BAR_HEIGHT: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
let DRAWER_WIDTH_RATIO: CGFloat = 0.7
let TOPNAV_BAR_SIZE: CGFloat = 50.0
let SEARCH_BAR_HEIGHT: CGFloat = 48.0
let SEARCH_BAR_OFFSET: CGFloat = 0.0

let LARGE_BUTTON_SIZE: CGFloat = 50.0
let STANDARD_BUTTON_SIZE: CGFloat = 44.0
let STANDARD_TAB_HEIGHT: CGFloat = 48.0
let STANDARD_BUTTON_HEIGHT: CGFloat = 44.0
let STANDARD_BUTTON_WIDTH: CGFloat = 250.0

let TABLE_ROW_HEIGHT: CGFloat = 48.0
let FAVORITES_ROW_HEIGHT: CGFloat = 70.0
let SEARCH_RESULTS_ROW_HEIGHT: CGFloat = 50.0
let MARKET_RESULTS_ROW_HEIGHT: CGFloat = 65.0

let THUMBNAIL_SIZE: CGFloat = (IS_IPHONE_4_OR_LESS ) ? 65.0 : (IS_IPHONE_5_OR_LESS) ? 70.0 : 80.0
let THUMBNAIL_SIZE_XL: CGFloat = (IS_IPHONE_4_OR_LESS ) ? 90.0 : (IS_IPHONE_5_OR_LESS) ? 100.0 : 110.0

let SPINNER_SIZE: CGFloat = 50.0
let SPINNER_LARGE_SIZE: CGFloat = 100.0

let ERROR_NO_INTERNET = 105
let NSERROR_NO_INTERNET = NSError(domain: APP_DOMAIN, code: ERROR_NO_INTERNET, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])



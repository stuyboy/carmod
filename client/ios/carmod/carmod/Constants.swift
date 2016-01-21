//
//  Constants.swift
//  SwiftAnyPic
//
//  Created by Thad Hwang on 11/16/15.
//  Copyright © 2015 parse. All rights reserved.
//

/*
green:        0x559A00 #559A00
orange:       0xFE9532 #FE9532 254 149 50
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
let GOOGLE_API_KEY = "AIzaSyBoPovyx0Z8qIlXtwMWhalqkZXd7JR_BuM"
let GOOGLE_SEARCH_ENGINE_KEY = "003309163549465394829:h2dzvntgkjm"

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
let FONT_PRIMARY: String = "Oxygen-Regular"
let FONT_BOLD: String = "Oxygen-Bold"
let FONT_LIGHT: String = "Oxygen-Light"

let FONTSIZE_XLARGE: CGFloat = IS_IPHONE_4_OR_LESS ? 22.0 : IS_IPHONE_5_OR_LESS ? 22.0 : 24.0
let FONTSIZE_LARGE: CGFloat = IS_IPHONE_4_OR_LESS ? 16.0 : IS_IPHONE_5_OR_LESS ? 16.0 : 18.0
let FONTSIZE_STANDARD: CGFloat = IS_IPHONE_4_OR_LESS ? 15.0 : IS_IPHONE_5_OR_LESS ? 14.0 : 16.0
let FONTSIZE_MEDIUM: CGFloat = IS_IPHONE_4_OR_LESS ? 14.0 : IS_IPHONE_5_OR_LESS ? 12.0 : 14.0
let FONTSIZE_SMALL: CGFloat = IS_IPHONE_4_OR_LESS ? 12.0 : IS_IPHONE_5_OR_LESS ? 10.0 : 12.0
let FONTSIZE_XSMALL: CGFloat = IS_IPHONE_4_OR_LESS ? 9.0 : IS_IPHONE_5_OR_LESS ? 8.0 : 10.0
let FONTSIZE_TINY: CGFloat = IS_IPHONE_4_OR_LESS ? 7.0 : IS_IPHONE_5_OR_LESS ? 7.0 : 8.0

// Color constants
let COLOR_PRIMARY: UInt = 0x559A00
let COLOR_SECONDARY: UInt = 0xFFD166
let COLOR_TERTIARY: UInt = 0xEF476F
let COLOR_GREEN: UInt = 0x559A00 //0x4DBC6B
let COLOR_ORANGE: UInt = 0xFE9532
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
let SMALL_BUTTON_SIZE: CGFloat = IS_IPHONE_4_OR_LESS ? 18.0 : IS_IPHONE_5_OR_LESS ? 24.0 : 32.0
let STANDARD_TAB_HEIGHT: CGFloat = 48.0
let STANDARD_BUTTON_HEIGHT: CGFloat = 44.0
let STANDARD_BUTTON_WIDTH: CGFloat = 250.0

let TABLE_ROW_HEIGHT: CGFloat = 48.0
let TAG_ROW_HEIGHT: CGFloat = 36.0
let SEARCH_RESULTS_ROW_HEIGHT: CGFloat = 50.0

let THUMBNAIL_SIZE: CGFloat = (IS_IPHONE_4_OR_LESS ) ? 65.0 : (IS_IPHONE_5_OR_LESS) ? 70.0 : 80.0
let THUMBNAIL_SIZE_XL: CGFloat = (IS_IPHONE_4_OR_LESS ) ? 90.0 : (IS_IPHONE_5_OR_LESS) ? 100.0 : 110.0
let THUMBNAIL_LABEL_HEIGHT: CGFloat = 30.0

let SPINNER_SIZE: CGFloat = 50.0
let SPINNER_LARGE_SIZE: CGFloat = 100.0

let ERROR_NO_INTERNET = 105
let NSERROR_NO_INTERNET = NSError(domain: APP_DOMAIN, code: ERROR_NO_INTERNET, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])

let EVENT_SEARCH_RESULTS_COMPLETE: String = "Event::SearchResultsComplete"
let EVENT_CAR_RESULTS_COMPLETE: String = "Event::CarResultsComplete"
let EVENT_CAR_QUERY_COMPLETE: String = "Event::CarQueryComplete"
let EVENT_PICKER_CANCELLED: String = "Event::PickerCancelled"
let EVENT_STORY_PUBLISHED: String = "Event::StoryPublished"
let EVENT_PART_SEARCH_COMPLETE: String = "Event::PartSearchComplete"
let EVENT_IMAGE_SEARCH_COMPLETE: String = "Event::ImageSearchComplete"

// TAG size constants
let TAG_WIDTH: CGFloat = 145.0
let TAG_FIELD_HEIGHT: CGFloat = 30.0
let TAG_ARROW_SIZE: CGFloat = 20.0

let PICKER_HEIGHT: CGFloat = 197.0
let HEADER_HEIGHT: CGFloat = 44.0

let kJSONArrayKey               = "results"

// JSON Part Field keys
let kPartJSONIDKey              = "id"
let kPartJSONClassificationKey  = "classification"
let kPartJSONBrandKey           = "brand"
let kPartJSONModelKey           = "model"
let kPartJSONProductCodeKey     = "productCode"
let kPartJSONSearchStringKey    = "searchString"
let kPartJSONImageURLKey        = "imageUrl"
let kPartJSONEmptyKey           = "Empty"

// JSON Car Field keys
let kCarJSONIDKey               = "id"
let kCarJSONYearKey             = "year"
let kCarJSONMakeKey             = "make"
let kCarJSONModelKey            = "model"
let kCarJSONTypeKey             = "type"
let kCarJSONHorsepowerKey       = "horsepower"
let kCarJSONCylindersKey        = "cylinders"
let kCarJSONDriveKey            = "drive"
let kCarJSONEmptyKey            = "Empty"

// Story Field keys
let kStoryClassKey              = "Story"
let kStoryPhotosKey             = "Photos"
let kStoryAuthorKey             = "author"
let kStoryTitleKey              = "title"

// Photo Field keys
let kPhotoClassKey              = "Photo"
let kPhotoImageKey              = "image"
let kPhotoThumbnailKey          = "thumbnail"
let kPhotoUserKey               = "user"

// Annotation Field keys
let kAnnotationClassKey         = "Annotation"
let kAnnotationCoordinatesKey   = "coordinates"
let kAnnotationBrandKey         = "brand"
let kAnnotationModelKey         = "model"
let kAnnotationPartNumberKey    = "productCode"
let kAnnotationPartIDKey        = "partId"
let kAnnotationPhotoKey         = "photo"
let kAnnotationImageURLKey      = "imageUrl"
let kAnnotationPartTypeKey      = "classification"
let kAnnotationUserKey          = "user"

// Entity Field keys
let kEntityClassKey             = "Entity"
let kEntityObjectIDKey          = "objectId"
let kEntityYearKey              = "year"
let kEntityMakeKey              = "make"
let kEntityModelKey             = "model"
let kEntityUserKey              = "user"
let kEntityImageKey             = "image"

// MARK:- Cached Story Attributes
// keys
let kStoryAttributesPhotosKey                 = "photos"
let kStoryAttributesIsLikedByCurrentUserKey   = "isLikedByCurrentUser"
let kStoryAttributesLikeCountKey              = "likeCount"
let kStoryAttributesLikersKey                 = "likers"
let kStoryAttributesCommentCountKey           = "commentCount"
let kStoryAttributesCommentersKey             = "commenters"

// MARK:- Cached Photo Attributes
// keys
let kPhotoAttributesAnnotationsKey            = "annotations"
let kPhotoAttributesAnnotationsCountKey       = "annotationsCount"

// MARK:- Cached Annotation Attributes
// keys
let kAnnotationAttributesCoordinateXKey       = "coordinateX"
let kAnnotationAttributesCoordinateYKey       = "coordinateY"
let kAnnotationAttributesBrandKey             = "brand"
let kAnnotationAttributesModelKey             = "model"
let kAnnotationAttributesProductCodeKey       = "productCode"
let kAnnotationAttributesPartIDKey            = "partID"

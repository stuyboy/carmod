//
//  StoryCache.swift
//  carmod
//
//  Created by Thad Hwang on 12/15/15.
//  Copyright © 2015 Thunderchicken Labs, LLC. All rights reserved.
//

import Foundation

final class StoryCache {
  private var cache: NSCache
  
  static let sharedCache = StoryCache()
  
  private init() {
    self.cache = NSCache()
  }
  
  func clear() {
    cache.removeAllObjects()
  }
  
  // MARK:- Story Cache
  func setAttributesForStory(story: PFObject, title: String, photos: [PFObject]) {
    let attributes = [
      kStoryAttributesTitleKey: title,
      kStoryAttributesPhotosKey: photos
    ]
    setAttributes(attributes as! [String : AnyObject], forStory: story)
  }
  
  func attributesForStory(story: PFObject) -> [String:AnyObject]? {
    let key: String = self.keyForStory(story)
    return cache.objectForKey(key) as? [String:AnyObject]
  }
  
  func setAttributes(attributes: [String : AnyObject], forStory photo: PFObject) {
    let key: String = self.keyForStory(photo)
    cache.setObject(attributes, forKey: key)
  }
  
  func keyForStory(story: PFObject) -> String {
    return "story_\(story.objectId)"
  }
  
  func titleForStory(story: PFObject) -> String {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesTitleKey] as! String
    }
    
    return ""
  }
  
  func photosForStory(story: PFObject) -> [PFObject] {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesPhotosKey] as! [PFObject]
    }
    
    return [PFObject]()
  }
  
  // MARK:- User Cache
  func setAttributesForUser(user: PFUser, photoCount count: Int, followedByCurrentUser following: Bool) {
    let attributes = [
      kPAPUserAttributesPhotoCountKey: count,
      kPAPUserAttributesIsFollowedByCurrentUserKey: following
    ]
    
    setAttributes(attributes as! [String : AnyObject], forUser: user)
  }
  
  func attributesForUser(user: PFUser) -> [String:AnyObject]? {
    let key = keyForUser(user)
    return cache.objectForKey(key) as? [String:AnyObject]
  }
  
  func setAttributes(attributes: [String:AnyObject], forUser user: PFUser) {
    let key: String = self.keyForUser(user)
    cache.setObject(attributes, forKey: key)
  }
  
  func keyForUser(user: PFUser) -> String {
    return "user_\(user.objectId)"
  }
  
  // MARK:- Photo Cache
  func setAttributesForPhoto(photo: PFObject, annotations: [PFObject], description: String, likers: [PFUser], commenters: [PFUser], likedByCurrentUser: Bool) {
    let attributes = [
      kPhotoAttributesAnnotationsKey: annotations,
      kPhotoAttributesAnnotationsCountKey: annotations.count,
      kPhotoAttributesDescriptionKey: description,
      kPAPPhotoAttributesIsLikedByCurrentUserKey: likedByCurrentUser,
      kPAPPhotoAttributesLikeCountKey: likers.count,
      kPAPPhotoAttributesLikersKey: likers,
      kPAPPhotoAttributesCommentCountKey: commenters.count,
      kPAPPhotoAttributesCommentersKey: commenters,
    ]
    setAttributes(attributes as! [String : AnyObject], forPhoto: photo)
  }
  
  func attributesForPhoto(photo: PFObject) -> [String:AnyObject]? {
    let key: String = self.keyForPhoto(photo)
    return cache.objectForKey(key) as? [String:AnyObject]
  }
  
  func setAttributes(attributes: [String:AnyObject], forPhoto photo: PFObject) {
    let key: String = self.keyForPhoto(photo)
    cache.setObject(attributes, forKey: key)
  }
  
  func keyForPhoto(photo: PFObject) -> String {
    return "photo_\(photo.objectId)"
  }
  
  func annotationCountForPhoto(photo: PFObject) -> Int {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesAnnotationsCountKey] as! Int
    }
    
    return 0
  }
  
  func annotationsForPhoto(photo: PFObject) -> [PFObject] {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesAnnotationsKey] as! [PFObject]
    }
    
    return [PFObject]()
  }
  
  func descriptionForPhoto(photo: PFObject) -> String {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesDescriptionKey] as! String
    }
    
    return ""
  }
  
  func likeCountForPhoto(photo: PFObject) -> Int {
    let attributes: [NSObject:AnyObject]? = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesLikeCountKey] as! Int
    }
    
    return 0
  }
  
  func commentCountForPhoto(photo: PFObject) -> Int {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesCommentCountKey] as! Int
    }
    
    return 0
  }
  
  func likersForPhoto(photo: PFObject) -> [PFUser] {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesLikersKey] as! [PFUser]
    }
    
    return [PFUser]()
  }
  
  func commentersForPhoto(photo: PFObject) -> [PFUser] {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesCommentersKey] as! [PFUser]
    }
    
    return [PFUser]()
  }
  
  func setPhotoIsLikedByCurrentUser(photo: PFObject, liked: Bool) {
    var attributes = self.attributesForPhoto(photo)
    attributes![kPhotoAttributesIsLikedByCurrentUserKey] = liked
    setAttributes(attributes!, forPhoto: photo)
  }
  
  func isPhotoLikedByCurrentUser(photo: PFObject) -> Bool {
    let attributes = self.attributesForPhoto(photo)
    if attributes != nil {
      return attributes![kPhotoAttributesIsLikedByCurrentUserKey] as! Bool
    }
    
    return false
  }
  
  func incrementLikerCountForPhoto(photo: PFObject) {
    let likerCount = likeCountForPhoto(photo) + 1
    var attributes = attributesForPhoto(photo)
    attributes![kPhotoAttributesLikeCountKey] = likerCount
    setAttributes(attributes!, forPhoto: photo)
  }
  
  func decrementLikerCountForPhoto(photo: PFObject) {
    let likerCount = likeCountForPhoto(photo) - 1
    if likerCount < 0 {
      return
    }
    var attributes = attributesForStory(photo)
    attributes![kPhotoAttributesLikeCountKey] = likerCount
    setAttributes(attributes!, forPhoto: photo)
  }
  
  func incrementCommentCountForPhoto(photo: PFObject) {
    let commentCount = commentCountForPhoto(photo) + 1
    var attributes = attributesForPhoto(photo)
    attributes![kPhotoAttributesCommentCountKey] = commentCount
    setAttributes(attributes!, forPhoto: photo)
  }
  
  func decrementCommentCountForPhoto(photo: PFObject) {
    let commentCount = commentCountForPhoto(photo) - 1
    if commentCount < 0 {
      return
    }
    var attributes = attributesForPhoto(photo)
    attributes![kPhotoAttributesCommentCountKey] = commentCount
    setAttributes(attributes!, forPhoto: photo)
  }
  
  // MARK:- Annotation Cache
  func setAttributesForAnnotation(annotation: PFObject, coordinateX: Double, coordinateY: Double, brand: String, model: String, productCode: String) {
    let attributes = [
      kAnnotationAttributesCoordinateXKey: coordinateX,
      kAnnotationAttributesCoordinateYKey: coordinateY,
      kAnnotationAttributesBrandKey: brand,
      kAnnotationAttributesModelKey: model,
      kAnnotationAttributesProductCodeKey: productCode,
    ]
    setAttributes(attributes as! [String : AnyObject], forAnnotation: annotation)
  }
  
  func attributesForAnnotation(annotation: PFObject) -> [String:AnyObject]? {
    let key: String = self.keyForAnnotation(annotation)
    return cache.objectForKey(key) as? [String:AnyObject]
  }
  
  func setAttributes(attributes: [String:AnyObject], forAnnotation annotation: PFObject) {
    let key: String = self.keyForAnnotation(annotation)
    cache.setObject(attributes, forKey: key)
  }
  
  func keyForAnnotation(annotation: PFObject) -> String {
    return "annotation_\(annotation.objectId)"
  }
  
  func coordinatesForAnnotation(annotation: PFObject) -> CGPoint {
    let attributes = self.attributesForAnnotation(annotation)
    if attributes != nil {
      let coordinateX = attributes![kAnnotationAttributesCoordinateXKey] as! Double
      let coordinateY = attributes![kAnnotationAttributesCoordinateXKey] as! Double
      return CGPoint(x: coordinateX, y: coordinateY)
    }
    
    return CGPoint(x: 0, y: 0)
  }

  func brandForAnnotation(annotation: PFObject) -> String {
    let attributes = self.attributesForAnnotation(annotation)
    if attributes != nil {
      return attributes![kAnnotationAttributesBrandKey] as! String
    }
    
    return ""
  }
  
  func modelForAnnotation(annotation: PFObject) -> String {
    let attributes = self.attributesForAnnotation(annotation)
    if attributes != nil {
      return attributes![kAnnotationAttributesModelKey] as! String
    }
    
    return ""
  }
  
  func productCodeForAnnotation(annotation: PFObject) -> String {
    let attributes = self.attributesForAnnotation(annotation)
    if attributes != nil {
      return attributes![kAnnotationAttributesProductCodeKey] as! String
    }
    
    return ""
  }
}
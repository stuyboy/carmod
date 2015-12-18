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
  func setAttributesForStory(story: PFObject, photos: [PFObject], likers: [PFUser], commenters: [PFUser], likedByCurrentUser: Bool) {
    let attributes = [
      kStoryAttributesPhotosKey: photos,
      kStoryAttributesIsLikedByCurrentUserKey: likedByCurrentUser,
      kStoryAttributesLikeCountKey: likers.count,
      kStoryAttributesLikersKey: likers,
      kStoryAttributesCommentCountKey: commenters.count,
      kStoryAttributesCommentersKey: commenters
    ]
    setAttributes(attributes as! [String : AnyObject], forStory: story)
  }
  
  func attributesForStory(story: PFObject) -> [String:AnyObject]? {
    let key: String = self.keyForStory(story)
    return cache.objectForKey(key) as? [String:AnyObject]
  }
  
  func setAttributes(attributes: [String:AnyObject], forStory photo: PFObject) {
    let key: String = self.keyForStory(photo)
    cache.setObject(attributes, forKey: key)
  }
  
  func keyForStory(story: PFObject) -> String {
    return "story_\(story.objectId)"
  }
  
  func photosForStory(story: PFObject) -> [PFObject] {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesPhotosKey] as! [PFObject]
    }
    
    return [PFObject]()
  }
  
  func likeCountForStory(story: PFObject) -> Int {
    let attributes: [NSObject:AnyObject]? = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesLikeCountKey] as! Int
    }
    
    return 0
  }
  
  func commentCountForStory(story: PFObject) -> Int {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesCommentCountKey] as! Int
    }
    
    return 0
  }
  
  func likersForStory(story: PFObject) -> [PFUser] {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesLikersKey] as! [PFUser]
    }
    
    return [PFUser]()
  }
  
  func commentersForStory(story: PFObject) -> [PFUser] {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesCommentersKey] as! [PFUser]
    }
    
    return [PFUser]()
  }
  
  func setStoryIsLikedByCurrentUser(story: PFObject, liked: Bool) {
    var attributes = self.attributesForStory(story)
    attributes![kStoryAttributesIsLikedByCurrentUserKey] = liked
    setAttributes(attributes!, forStory: story)
  }
  
  func isStoryLikedByCurrentUser(story: PFObject) -> Bool {
    let attributes = self.attributesForStory(story)
    if attributes != nil {
      return attributes![kStoryAttributesIsLikedByCurrentUserKey] as! Bool
    }
    
    return false
  }

  func incrementLikerCountForStory(story: PFObject) {
    let likerCount = likeCountForStory(story) + 1
    var attributes = attributesForStory(story)
    attributes![kStoryAttributesLikeCountKey] = likerCount
    setAttributes(attributes!, forStory: story)
  }
  
  func decrementLikerCountForStory(story: PFObject) {
    let likerCount = likeCountForStory(story) - 1
    if likerCount < 0 {
      return
    }
    var attributes = attributesForStory(story)
    attributes![kStoryAttributesLikeCountKey] = likerCount
    setAttributes(attributes!, forStory: story)
  }
  
  func incrementCommentCountForStory(story: PFObject) {
    let commentCount = commentCountForStory(story) + 1
    var attributes = attributesForStory(story)
    attributes![kStoryAttributesCommentCountKey] = commentCount
    setAttributes(attributes!, forStory: story)
  }
  
  func decrementCommentCountForStory(story: PFObject) {
    let commentCount = commentCountForStory(story) - 1
    if commentCount < 0 {
      return
    }
    var attributes = attributesForStory(story)
    attributes![kStoryAttributesCommentCountKey] = commentCount
    setAttributes(attributes!, forStory: story)
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
  func setAttributesForPhoto(photo: PFObject, annotations: [PFObject]) {
    let attributes = [
      kPhotoAttributesAnnotationsKey: annotations,
      kPhotoAttributesAnnotationsCountKey: annotations.count
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
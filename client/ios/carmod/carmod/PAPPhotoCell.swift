import UIKit
import ParseUI

class PAPPhotoCell: PFTableViewCell {
  var photoButton: UIButton?
  var annotations: [PFObject]! {
    didSet {
      for annotation in annotations {
        let brand = annotation.objectForKey(kAnnotationBrandKey) as! String
        let model = annotation.objectForKey(kAnnotationModelKey) as! String
        let partNumber = annotation.objectForKey(kAnnotationPartNumberKey) as! String
        let coordinates = annotation.objectForKey(kAnnotationCoordinatesKey) as! [CGFloat]
        
        let tagView = TagView(frame: CGRect(x: coordinates[0], y: coordinates[1], width: TAG_WIDTH, height: TAG_FIELD_HEIGHT+TAG_ARROW_SIZE), arrowSize: TAG_ARROW_SIZE, fieldHeight: TAG_FIELD_HEIGHT)
        tagView.alpha = 0.8
        tagView.tagLabel.text = "\(brand) \(model) \(partNumber)"
        tagView.toggleRemoveVisibility(true)
        self.imageView!.addSubview(tagView)
      }
    }
  }
  
  // MARK:- NSObject
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    // Initialization code
    self.opaque = false
    self.selectionStyle = UITableViewCellSelectionStyle.None
    self.accessoryType = UITableViewCellAccessoryType.None
    self.clipsToBounds = false
    
    self.backgroundColor = UIColor.clearColor()
    
    self.imageView!.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.width)
    self.imageView!.backgroundColor = UIColor.blackColor()
    self.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
    
    self.photoButton = UIButton(type: UIButtonType.Custom)
    self.photoButton!.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.width)
    self.photoButton!.backgroundColor = UIColor.clearColor()
    self.contentView.addSubview(self.photoButton!)
    
    self.contentView.bringSubviewToFront(self.imageView!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK:- UIView
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.imageView!.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.width)
    self.photoButton!.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.width)
  }
  
  override func prepareForReuse() {
    for view in self.imageView!.subviews{
      if view is TagView {
        view.removeFromSuperview()
      }
    }
  }
}

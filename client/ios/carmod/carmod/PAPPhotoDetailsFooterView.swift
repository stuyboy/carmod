import UIKit

class PAPPhotoDetailsFooterView: UIView {
  private var mainView: UIView!
  var commentField: UITextField!
  var hideDropShadow: Bool = false
  
  // MARK:- NSObject
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    // Initialization code
    self.backgroundColor = UIColor.clearColor()
    
    self.mainView = UIView(frame: CGRectMake(0.0, 0.0, self.frame.width, 51.0))
    self.mainView.backgroundColor = UIColor.whiteColor()
    self.addSubview(self.mainView)
    
    let messageIcon = UIImageView(image: UIImage(named: "IconAddComment.png"))
    messageIcon.frame = CGRectMake(20.0, 15.0, 22.0, 22.0)
    self.mainView.addSubview(messageIcon)
    
    let BOX_WIDTH: CGFloat = self.frame.width-75.0
    let BOX_HEIGHT: CGFloat = 34.0
    let commentBox = UIView(frame: CGRect(x: 55.0, y: 8.0, width: BOX_WIDTH, height: BOX_HEIGHT))
    commentBox.layer.borderColor = UIColor.fromRGB(COLOR_ORANGE).CGColor
    commentBox.layer.borderWidth = 1.0
    commentBox.layer.cornerRadius = 16.0
    mainView.addSubview(commentBox)
    
    self.commentField = UITextField(frame: CGRectMake(68.0, 8.0, BOX_WIDTH, BOX_HEIGHT))
    self.commentField.font = UIFont(name: FONT_PRIMARY, size: FONTSIZE_STANDARD)
    self.commentField.placeholder = "Add a comment"
    self.commentField.returnKeyType = UIReturnKeyType.Send
    self.commentField.textColor = UIColor.fromRGB(COLOR_NEAR_BLACK)
    self.commentField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
    self.commentField.setValue(UIColor.fromRGB(COLOR_DARK_GRAY), forKeyPath: "_placeholderLabel.textColor") // Are we allowed to modify private properties like this? -Héctor
    self.mainView.addSubview(self.commentField)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK:- PAPPhotoDetailsFooterView
  
  class func rectForView() -> CGRect {
    return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, 69.0)
  }
}

import UIKit

public var TextIncoming = UIEdgeInsets(top:5, left:15, bottom:11, right:10)
public var TextOutgoing = UIEdgeInsets(top:5, left:10, bottom:11, right:17)
public var ImgIncoming = UIEdgeInsets(top:11, left:13, bottom:16, right:22)
public var ImgOutgoing = UIEdgeInsets(top:11, left:13, bottom:16, right:22)

class TableViewCell:UITableViewCell
{
    
    var customView:UIView!
    var bubbleImage:UIImageView!
    var avatarImage:UIImageView!
    var msgItem:MessageItem!
    var insets:UIEdgeInsets!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //- (void) setupInternalData
    init(data:MessageItem, reuseIdentifier cellId:String)
    {
        self.msgItem = data
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier:cellId)
        rebuildUserInterface()
    }
    
    func rebuildUserInterface()
    {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        if (self.bubbleImage == nil)
        {
            self.bubbleImage = UIImageView()
            self.addSubview(self.bubbleImage)
        }
        
        let type =  self.msgItem.mtype
        
        var msgWidth:CGFloat
        var msgHeight:CGFloat
        
        //for text
        
        let content = msgItem.content
        switch(content){
        case .image(let img):
            //print("it is image")
            var size = img.size
            
            //等比缩放
            if (size.width > 220)
            {
                size.height /= (size.width / 220);
                size.width = 220;
            }
            msgWidth = size.width
            msgHeight = size.height
            
            let imageView = UIImageView(frame:CGRectMake(0, 0, size.width, size.height))
            imageView.image = img
            imageView.layer.cornerRadius = 5.0
            imageView.layer.masksToBounds = true
            
            insets =  (type == ChatType.Outgoing ?ImgOutgoing : ImgIncoming)
            
            self.customView = imageView
            
        case .text(let str):
            //print("it is str")
            let font =  UIFont.boldSystemFontOfSize(14)
            let width =  225.0, height = 10000.0
            let atts =  [NSFontAttributeName: font]
            
            let size =  str.boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat(height))  ,     options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:atts ,     context:nil)
            msgWidth = size.width
            msgHeight = size.height
            
            
            
            let label =  UILabel(frame:CGRectMake(0, 0, size.size.width, size.size.height))
            
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.ByWordWrapping
            label.text = (str.length != 0 ? str as String : "")
            label.font = font
            label.backgroundColor = UIColor.clearColor()
            
            insets = (type == ChatType.Incoming) ? TextIncoming : TextOutgoing
            
            self.customView = label
        }
        
        //print("msgHeight :\(msgHeight)")
        
        var x =  (type == ChatType.Incoming) ? 0 : self.frame.size.width - msgWidth - insets.left - insets.right
        var y:CGFloat =  0
        
        //for img
        
        //for audio
        
        
        //let width =  self.msgItem.view.frame.size.width
        //let height =  self.msgItem.view.frame.size.height
        
        
        
        
        //if we have a chatUser show the avatar of the YDChatUser property
        if (self.msgItem.user.username != "")
        {
            
            let thisUser =  self.msgItem.user
            //self.avatarImage.removeFromSuperview()
            
            self.avatarImage = UIImageView(image:UIImage(named:(thisUser.avatar != "" ? thisUser.avatar : "noAvatar.png")))
            
            self.avatarImage.layer.cornerRadius = 9.0
            self.avatarImage.layer.masksToBounds = true
            self.avatarImage.layer.borderColor = UIColor(white:0.0 ,alpha:0.2).CGColor
            self.avatarImage.layer.borderWidth = 1.0
            //calculate the x position
            
            let avatarX =  (type == ChatType.Incoming) ? 2 : self.frame.size.width - 52
            //print("avata:\(height)")
            let avatarY =  msgHeight
            //set the frame correctly
            self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50)
            //print(self.avatarImage.frame )
            self.addSubview(self.avatarImage)
            
            let delta =  self.frame.size.height - (insets.top + insets.bottom + self.customView.frame.size.height)
            //print("delta:\(delta)")
            if (delta > 0)
            {
                y = delta
            }
            if (type == ChatType.Incoming)
            {
                x += 54
                //backgroundColor = UIColor.blueColor()
            }
            if (type == ChatType.Outgoing)
            {
                x -= 54
                //backgroundColor = UIColor.redColor()
            }
        }
        //print("Y:\(y)")
        //self.customView.removeFromSuperview()
        
        //self.customView = self.msgItem.view
        
        self.customView.frame = CGRectMake(x + insets.left, y + insets.top, msgWidth, msgHeight)
        self.addSubview(self.customView)
        
        //depending on the ChatType a bubble image on the left or right
        if (type == ChatType.Incoming)
        {
            self.bubbleImage.image = UIImage(named:("yoububble.png"))!.stretchableImageWithLeftCapWidth(21,topCapHeight:14)
            
        }
        else {
            self.bubbleImage.image = UIImage(named:"mebubble.png")!.stretchableImageWithLeftCapWidth(15, topCapHeight:14)
        }
        self.bubbleImage.frame = CGRectMake(x, y, msgWidth + insets.left + insets.right, msgHeight + insets.top + insets.bottom)
    }
    
    //让单元格宽度始终为屏幕宽
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.size.width = UIScreen.mainScreen().bounds.width
            super.frame = frame
        }
    }
}

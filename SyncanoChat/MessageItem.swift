import UIKit

enum ChatType
{
    case Outgoing
    case Incoming
}

enum MessageContent
{
    case text(NSString)
    case image(UIImage)
}

class MessageItem
{
    var user:UserInfo
    var date:NSDate
    var mtype:ChatType
    
    //var view:UIView
    //var insets:UIEdgeInsets
    
    var content:MessageContent
    
    /*
    class func getTextInsetsOutgoing() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:10, bottom:11, right:17)
    }
    
    class func getTextInsetsIncoming() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:15, bottom:11, right:10)
    }
    class func getImageInsetsMine() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:11, left:13, bottom:16, right:22)
    }
    class func getImageInsetsSomeone() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:11, left:13, bottom:16, right:22)
    }
 */
    
    init(user:UserInfo, date:NSDate, mtype:ChatType, content:MessageContent)
    {
        //self.view = view
        self.user = user
        self.date = date
        self.mtype = mtype
        //self.insets = insets
        self.content = content
    }
    
    //文字类型消息
    convenience init(body:MessageContent, user:UserInfo, date:NSDate, mtype:ChatType)
    {
        /*
        let font =  UIFont.boldSystemFontOfSize(12)
        
        let width =  225, height = 10000.0
        
        let atts =  [NSFontAttributeName: font]
        
        let size =  body.boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat(height))  ,     options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes:atts ,     context:nil)
        
        let label =  UILabel(frame:CGRectMake(0, 0, size.size.width, size.size.height))
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.text = (body.length != 0 ? body as String : "")
        label.font = font
        label.backgroundColor = UIColor.clearColor()
        */
        /*
        let insets:UIEdgeInsets =  (mtype == ChatType.Outgoing ? MessageItem.getTextInsetsOutgoing() : MessageItem.getTextInsetsIncoming())
 */
        
        self.init(user:user, date:date, mtype:mtype, content: body)
    }    
    
    //图片类型消息
    /*
    convenience init(image:UIImage, user:UserInfo,  date:NSDate, mtype:ChatType)
    {
        var size = image.size
        //等比缩放
        if (size.width > 220)
        {
            size.height /= (size.width / 220);
            size.width = 220;
        }
        let imageView = UIImageView(frame:CGRectMake(0, 0, size.width, size.height))
        imageView.image = image
        imageView.layer.cornerRadius = 5.0
        imageView.layer.masksToBounds = true
        
        let insets:UIEdgeInsets =  (mtype == ChatType.Mine ? MessageItem.getImageInsetsMine() : MessageItem.getImageInsetsSomeone())
        
        self.init(user:user,  date:date, mtype:mtype, view:imageView, insets:insets)
    }
 */
}
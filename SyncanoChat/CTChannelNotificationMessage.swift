//
//  CTChannelNotificationMessage.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit

public class CTChannelNotificationMessage : NSObject {
    
    @NSCopying public var identifier: NSNumber?
    @NSCopying public var createdAt: NSDate?
    public var author: [NSObject : AnyObject]?
    public var action: CTChannelNotificationMessageAction
    public var payload: [NSObject : AnyObject]?
    public var metadata: [NSObject : AnyObject]?
    
    public init(JSONObject: AnyObject){
        action = .None
    }
}
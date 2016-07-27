//
//  Message.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/21.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import syncano_ios

class Message: SCDataObject {
    var text = ""
    var senderId = ""
    
    override class func extendedPropertiesMapping() -> [NSObject: AnyObject] {
        return [
            "senderId":"senderid"
        ]
    }
}

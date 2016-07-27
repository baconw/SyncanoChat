//
//  RequestClient.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/23.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import AFNetworking

class RequestClient: AFHTTPSessionManager {
    class var sharedInstance : RequestClient {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : RequestClient? = nil
        }
        
        dispatch_once(&Static.onceToken,{ () -> Void in
            let url : NSURL = NSURL(string: "")!
            Static.instance = RequestClient(baseURL:url)
        })
        
        return Static.instance!
    }
}

//
//  Constants.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import Foundation

//typedef void (^SCDataObjectsCompletionBlock)(NSArray * _Nullable objects, NSError * _Nullable error);

public enum CTChannelNotificationMessageAction : UInt {
    
    case None
    case Create
    case Update
    case Delete
}

public var SERVER_IP = "104.200.21.219"
//public var SERVER_IP = "192.168.3.2"
public var SERVER_PORT = "3000"

public var SERVER_NOT_RESPONSE = "服务器挂了，努力抢救中"

public var ME = "me"
public var SERVER = "server"
    
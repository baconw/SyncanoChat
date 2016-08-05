//
//  CTChannelDelegate.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit

public protocol CTChannelDelegate : NSObjectProtocol {
    func channelDidReceiveNotificationMessage(notificationMessage: CTChannelNotificationMessage)
}
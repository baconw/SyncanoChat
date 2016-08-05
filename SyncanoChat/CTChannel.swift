//
//  CTChannel.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//


import UIKit

public class CTChannel : NSObject {
    
    /**
     *  Channel name
     */
    public var name: String?
    
    /**
     *  Last message identifier
     */
    public var lastId: NSNumber?
    
    /**
     *  Room name
     */
    public var room: String?
    
    /**
     *  Channel delegate
     */
    public var delegate: CTChannelDelegate?
    
    /**
     *  Initializes channel
     *
     *  @param channelName channel name
     *
     *  @return SCChannel instance
     */
    public init(name channelName: String){
        
    }
    
    
    /**
     *  Subscribes to channel using singletone Syncano instance
     */
    public func subscribeToChannel(){
        
    }
    
    
}

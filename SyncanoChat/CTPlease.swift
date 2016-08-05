//
//  CTPlease.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


/**
 *  Class to make queries on Syncano API
 */
public class CTPlease : NSObject {
    
    
    
    /**
     * You can also get the Data Objects count estimation when getting the Data Objects list. Syncano shows estimate count for Classes that have more than 1000 Data Objects. This is because we can't provide a precise count without affecting the performance of the platform.
     */
    public var objectsCount: NSNumber?
    
    public override init(){
        
    }
    
    /**
     *  Initializes new empty SCPlease object for provided SCDataObject class
     *
     *  @param dataObjectClass SCDataObject scope class
     *
     *  @return SCPlease object
     */
    public init(dataObjectClass: AnyClass){
        
    }
    
    
    /**
     *  Creates and runs a simple request without any query parameters or statements
     *
     *  @param completion completion block
     */
    func giveMeDataObjectsWithCompletion(completion: (objects : [Message]?, error : NSError?) -> ()){
        //todo 
        
        var messages:[Message]?
        var error:NSError?
        
        if(CTUser.currentUser() == nil){
            error = NSError(coder: NSCoder())
            completion(objects: messages,error: error)
        } else {
            let username = (CTUser.currentUser()?.username)! as String
            let params = ["uname":username]
            Alamofire.request(.POST, "https://" + SERVER_IP + ":" + SERVER_PORT + "/messages", parameters: params)
                .responseString{response in
                    print(response)
                    //let error:NSError = NSError(forUnknownProperty: "MY ERROR")
                    //finished(error)
                    let message = Message()
                    message.text = "hello from server"
                    messages = [message]
                    
                    completion(objects: messages,error: error)
            }
        }
    }
    
}

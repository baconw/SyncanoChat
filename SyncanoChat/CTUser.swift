//
//  CTUser.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/27.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CTUser {
    
    var username:String = ""
    
    static var user : CTUser?
    
    static var isServerRunning : Bool = false
    
    class func currentUser() -> CTUser? {
        return user
    }
    
    class func startChatSession(username:String, finished: (Bool) -> ()) {
        /*
        let params = ["uname":username,
                      "upwd":password]
        Alamofire.request(.POST, "https://" + SERVER_IP + ":" + SERVER_PORT + "/login", parameters: params)
            .responseString{response in
                let responseResult = response.result
                switch responseResult{
                case .Success(let value):
                    print("value: \(value)")
                    user = CTUser()
                    user?.username = username
                    finished(nil)
                case .Failure(let error):
                    print("\(SERVER_NOT_RESPONSE) error: \(error.code)")
                }
        }
        */
        Alamofire.request(.GET, "https://" + SERVER_IP + ":" + SERVER_PORT + "/chat?deviceType=1&user=" + username)
            .responseJSON{response in
                let responseResult = response.result
                switch responseResult{
                case .Success(let value):
                    print("value: \(value)")
                    let swiftyJsonVar = JSON(value)
                    print(swiftyJsonVar["status"])
                    if("Succeed" == swiftyJsonVar["status"]){
                        user = CTUser()
                        user?.username = username
                        isServerRunning = true
                        print("username:\(username)")
                        finished(true)
                    } else {
                        print("login failed")
                        finished(false)
                    }
                case .Failure(let error):
                    print("\(SERVER_NOT_RESPONSE) error: \(error.code)")
                    finished(false)
                }
        }
    }
    
    class func registerWithUsername(username:String, password:String, finished: (NSError!) -> ()) {
        
    }
    
    class func logout() {
        user = nil
    }
}
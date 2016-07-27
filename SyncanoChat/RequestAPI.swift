//
//  RequestAPI.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/23.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import Foundation

typealias Succeed = (NSURLSessionDataTask!, AnyObject!) -> Void
typealias Failure = (NSURLSessionDataTask!, NSError!) -> Void
typealias Progress = (NSProgress!) -> Void

class RequestAPI : NSObject {
    
    class func GET(url:String!, body:AnyObject? , progress:Progress, succeed:Succeed, failed:Failure) {
        let mySucceed:Succeed = succeed
        let myFailure:Failure = failed
        let myProgress:Progress = progress
        /*
        RequestClient.sharedInstance.GET(url, parameters: body, success: { (task:NSURLSessionDataTask, response:AnyObject?) in
                mySucceed(task,response)
        },failure:  { (task:NSURLSessionDataTask?, error:NSError) in
                myFailure(task,error)
        })
        */
        RequestClient.sharedInstance.GET(url, parameters: body, progress: { (progress:NSProgress) in
            myProgress(progress)
            //print("progress")
            }, success: { (task:NSURLSessionDataTask, response:AnyObject?) in
            mySucceed(task,response)
        }) { (task:NSURLSessionDataTask?, error:NSError) in
                myFailure(task,error)
        }
 
    }
}
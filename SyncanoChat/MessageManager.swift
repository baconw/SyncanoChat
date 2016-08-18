//
//  Message.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/21.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class MessageManager {

    var managedObjectContext: NSManagedObjectContext
    
    init(){
        self.managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func getAllMessages() -> [Message] {
        let fetchRequest = NSFetchRequest(entityName: "Message")
        return (try! managedObjectContext.executeFetchRequest(fetchRequest)) as! [Message]
    }
    
    func saveMessage(message:String, sender:String) -> Message {
        print("saveMessage 1")
        
        let ms = NSEntityDescription.insertNewObjectForEntityForName("Message", inManagedObjectContext: managedObjectContext) as! Message
        print("saveMessage 2")
        ms.create_at = NSDate()
        ms.text = message
        ms.senderid = sender
        
        self.saveContext()
        
        return ms
    }

    func sendMsgWithCompletionBlock(message:String, username:String, finished: (Message, NSError!) -> ()) {
        let text = message
        let params = ["msg":text,"user":username]
        
        Alamofire.request(.POST, "https://" + SERVER_IP + ":" + SERVER_PORT + "/chat/sendMsg", parameters: params)
            .responseJSON{response in
                var responseText:String
                
                print(response.result)
                print(response.data)
                switch response.result{
                case .Success(let value):
                    print("Value:\(value)")
                    let swiftyJsonVar = JSON(value)
                    print(swiftyJsonVar["response"])
                    if(swiftyJsonVar["status"] == "Failed"){
                        CTUser.isServerRunning = false
                        responseText = SERVER_NOT_RESPONSE
                    }else{
                        responseText = String(swiftyJsonVar["response"])
                    }
                case .Failure(let error):
                    print("error \(error)")
                    responseText = SERVER_NOT_RESPONSE
                }
                
                let responeMessage = self.saveMessage(responseText, sender:SERVER)
                
                
                finished(responeMessage ,nil)
        }
    }
    
    func sendCmdWithCompletionBlock(cmd:String, username:String, finished: (Message, NSError!) -> ()) {
        let text = cmd
        let params = ["cmd":text,"user":username]
        
        Alamofire.request(.POST, "https://" + SERVER_IP + ":" + SERVER_PORT + "/chat/sendCmd", parameters: params)
            .responseJSON{response in
                var responseText:String
                
                print(response.result)
                print(response.data)
                switch response.result{
                case .Success(let value):
                    print("Value:\(value)")
                    let swiftyJsonVar = JSON(value)
                    print(swiftyJsonVar["response"])
                    if(swiftyJsonVar["status"] == "Failed"){
                        //print(swiftyJsonVar["response"])
                    }else{
                        responseText = String(swiftyJsonVar["response"])
                        let responeMessage = self.saveMessage(responseText, sender:SERVER)
                        finished(responeMessage ,nil)
                    }
                case .Failure(let error):
                    print("error \(error)")
                }
        }
    }
    
    
    func saveContext () {
                do {
                    try managedObjectContext.save()
                } catch let error as NSError {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
        
    }
    
    /**
     *  Returns SCPlease instance for singleton Syncano
     *
     *  @return SCPlease instance
     */
    class func please() -> CTPlease {
        return CTPlease()
    }
}

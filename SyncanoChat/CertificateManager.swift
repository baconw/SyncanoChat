//
//  LoginViewController.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/22.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentityRef
    var trust:SecTrustRef
    var certArray:AnyObject
}

class CertificateManager {
    
    class func initCertificate(){
        print("initCertificate")
        //认证相关设置
        let manager = Alamofire.Manager.sharedInstance
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            //认证服务器证书
            if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust {
                print("服务端证书认证！")
                let serverTrust:SecTrustRef = challenge.protectionSpace.serverTrust!
                let credential = NSURLCredential(forTrust: serverTrust)
                challenge.sender?.useCredential(credential,
                                                forAuthenticationChallenge: challenge)
                return (NSURLSessionAuthChallengeDisposition.UseCredential,
                        NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
            }
                //认证客户端证书
            else if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodClientCertificate
            {
                print("客户端证书认证！")
                //获取客户端证书相关信息
                let identityAndTrust:IdentityAndTrust = self.extractIdentity()
                
                let urlCredential:NSURLCredential = NSURLCredential(
                    identity: identityAndTrust.identityRef,
                    certificates: identityAndTrust.certArray as? [AnyObject],
                    persistence: NSURLCredentialPersistence.ForSession);
                
                return (.UseCredential, urlCredential);
            }
                // 其它情况（不接受认证）
            else {
                print("其它情况（不接受认证）")
                return (.CancelAuthenticationChallenge, nil)
            }
        }
    }
    
    //获取客户端证书相关信息
    class func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = NSBundle.mainBundle().pathForResource("client", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "Password06"] //客户端证书密码
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentityRef = identityPointer as! SecIdentityRef!;
                print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrustRef = trustPointer as! SecTrustRef;
                print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"];
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!);
            }
        }
        return identityAndTrust;
    }

}


/*
extension LoginViewController {
    func succeed(task:NSURLSessionDataTask!, responseObject:AnyObject!) -> Void {
        print("Received from server : \(responseObject)")
    }
    
    func failed(task:NSURLSessionDataTask!, error:NSError!) -> Void {
        print("Error from server : \(error)")
    }
    
    func progress(progress:NSProgress!) -> Void {
        print("Sending request to server...")
    }
}
*/






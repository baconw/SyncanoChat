//
//  LoginViewController.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/22.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import syncano_ios
import Alamofire

let loginViewControllerIdentifier = "LoginViewController"

protocol LoginDelegate {
    func didSignUp()
    func didLogin()
}

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentityRef
    var trust:SecTrustRef
    var certArray:AnyObject
}

class LoginViewController: UIViewController {
    
    /*
    @IBOutlet weak var emailTextField: UITextField!
    */
    @IBOutlet weak var emailTextField: UITextField!
    /*
    @IBOutlet weak var passwordTextField: UITextField!
    */
    @IBOutlet weak var passwordTextField: UITextField!
    var delegate : LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                /*
                let serverTrust:SecTrustRef = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let remoteCertificateData
                    = CFBridgingRetain(SecCertificateCopyData(certificate))!
                
                print("load server cert")
                
                let cerPath = NSBundle.mainBundle().pathForResource("server",
                                                                ofType: "cer")!
                let PKCS12Data = NSData(contentsOfFile:cerPath)!
                let key:NSString = kSecImportExportPassphrase as NSString
                let options:NSDictionary = [key:"Password06"]
                var items:CFArray?
                var securityError:OSStatus = errSecSuccess
                securityError = SecPKCS12Import(PKCS12Data, options, &items)
                
                if securityError == errSecSuccess {
                    print("server cert import success")
                    let credential = NSURLCredential(forTrust: serverTrust)
                    challenge.sender?.useCredential(credential,
                                                    forAuthenticationChallenge: challenge)
                    return (NSURLSessionAuthChallengeDisposition.UseCredential,
                            NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))

                }else{
                    print("server cert import failed")
                    return (.CancelAuthenticationChallenge, nil)
                }
                */
                //let localCertificateData = NSData(contentsOfFile:cerPath)!
            
                
                
                /*
                if (remoteCertificateData.isEqualToData(localCertificateData) == true) {
                    let credential = NSURLCredential(forTrust: serverTrust)
                    challenge.sender?.useCredential(credential,
                                                forAuthenticationChallenge: challenge)
                    return (NSURLSessionAuthChallengeDisposition.UseCredential,
                        NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
                
                } else {
                    print("服务器证书不同")
                    return (.CancelAuthenticationChallenge, nil)
                }
 */
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
    func extractIdentity() -> IdentityAndTrust {
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController {
    
    @IBAction func loginPresses(sender:UIButton) {
        if self.areBothUsernameAndPasswordFilled() {
            self.login(self.getUserName()!, password: self.getPassword()!, finished: { error in
                if (error != nil) {
                    print("Login error: \(error)")
                } else {
                    self.cleanTextFields()
                    self.delegate?.didLogin()
                }
            })
        }
    }
    
    @IBAction func signUpPressed(sender:UIButton) {
        if self.areBothUsernameAndPasswordFilled() {
            self.signUp(self.getUserName()!, password: self.getPassword()!, finished: { error in
                if (error != nil) {
                    print("Sign Up error: \(error)")
                } else {
                    self.cleanTextFields()
                    self.delegate?.didSignUp()
                }
            })
        }
    }
    
    func getUserName() -> String? {
        return self.emailTextField.text
    }
    
    func getPassword() -> String? {
        return self.passwordTextField.text
    }
    
    func areBothUsernameAndPasswordFilled() -> Bool {
        if let username = self.emailTextField.text, password = self.passwordTextField.text {
            if (username.characters.count > 0 && password.characters.count > 0 ) {
                return true
            }
        }
        return false
    }
    
    func cleanTextFields() {
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
}

extension LoginViewController {
    func login(username:String, password:String, finished: (NSError!) -> ()) {
        
        SCUser.loginWithUsername(username, password:password) { error in
            finished(error)
        }
 
        let params = ["uname":username,
                      "upwd":password]
        Alamofire.request(.POST, "https://192.168.1.110:3000/login", parameters: params)
            .responseString{response in print(response)
        }
    }
    
    //func doLogin()
    
    func signUp(username:String, password:String, finished: (NSError!) -> ()) {
        /*
        SCUser.registerWithUsername(username, password:password) { error in
            finished(error)
        }*/
        /*
        let url = "https://192.168.1.110:3000/chat"
        RequestAPI.GET(url, body: nil, progress:progress, succeed: succeed, failed: failed)
        */
        Alamofire.request(.GET, "https://192.168.1.110:3000/chat").responseString{response in print(response) }
    }
}

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






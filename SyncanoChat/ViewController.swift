//
//  ViewController.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/20.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ViewController: JSQMessagesViewController {
    
    var messageManager = MessageManager()
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    //let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(loginViewControllerIdentifier) as! LoginViewController
    
    //let syncano = Syncano.sharedInstanceWithApiKey(syncanoApiKey, instanceName: syncanoInstaneName)
    //let channel = SCChannel(name: syncanoChannelName)
    let channel = CTChannel(name: syncanoChannelName)
    
    var messages = [JSQMessage]()
    
    var uid:String = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var iFlySpeechSynthesizer:IFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        
        self.setupIFly()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessageView() {
        self.collectionView?.reloadData()
    }
    @IBAction func editPressed(sender: UIBarButtonItem) {
        print("editPressed")
    }
}

extension ViewController {
    
    func setup() {
        print("setup")
        CertificateManager.initCertificate()
        
        self.title = "Cattie ChatApp"
        self.senderId = ME
        
        self.senderDisplayName = ME
        self.prepareAppForNewUser()
        
        self.beginChat({ isSucceed in
            //self.prepareAppForNewUser()
            self.sendCommandToCattie("1")
        })
        
        //initTimer()
        
    }
    
    func prepareAppForNewUser() {
        print("prepareAppForNewUser")
        //self.setupSenderData()
        self.reloadAllMessages()
    }
    
    func reloadAllMessages() {
        self.messages = []
        self.reloadMessageView()
        self.retriveMessagesFromStorage()
    }
    
    /*
    func setupSenderData() {
        let sender = (CTUser.currentUser() != nil) ? CTUser.currentUser()!.username : ""
        self.senderId = sender
        self.senderDisplayName = sender
    }
 */
    
    //data
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        //print("sender:\(data.senderId)")
        switch(data.senderId) {
        case SERVER:
            return self.incomingBubble
        default:
            return self.outgoingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let image:UIImage
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case SERVER:
            image = UIImage(named: "cat-face")!
        default:
            image = UIImage(named: "me-face")!
        }
        
        let diameter = UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        let avatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: diameter)
        return avatarImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        /*
        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if (self.senderDisplayName == data.senderDisplayName()) {
            return NSAttributedString(string: ME)
        }
        return NSAttributedString(string: data.senderDisplayName())
         */
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        /*
        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if(self.senderDisplayName == data.senderDisplayName()){
            return 0.0
        }
        */
        //return kJSQMessagesCollectionViewCellLabelHeightDefault
        return 0.0
    }
    
    //toolbar
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.sendMessageToCattie(message)
        self.finishSendingMessage()
    }
    
    
    override func didPressAccessoryButton(sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .Default) { (action) in
            /**
             *  Create fake photo
             */
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
            self.addMedia(photoItem)
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .Default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .Default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()
            
            self.addMedia(audioItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = NSURL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = NSBundle.mainBundle().pathForResource("jsq_messages_sample", ofType: "m4a")
        let audioData = NSData(contentsOfFile: sample!)
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessageAnimated(true)
    }
    
    //syncano
    func sendMessageToCattie(message:JSQMessage){
        print("sendMessageToCattie 1")
        
        messageManager.saveMessage(message.text, sender: self.senderId)
        
        if(CTUser.isServerRunning){
            self.doSendMessageToCattie(message)
        }else{
            self.beginChat({isSucceed in self.doSendMessageToCattie(message)})
        }
    }
    
    func sendCommandToCattie(commandStr:String){
        print("sendCommandToCattie 1")
        
        if(CTUser.isServerRunning){
            self.doSendCommandToCattie(commandStr)
        }else{
            self.beginChat({isSucceed in self.doSendCommandToCattie(commandStr)})
        }
    }
    
    func doSendMessageToCattie(message:JSQMessage){
        print("doSendMessageToCattie 1")
        messageManager.sendMsgWithCompletionBlock(message.text, username:uid) {responseMessage, error in
            if (error == nil) {
                //self.messages.append(self.jsqMessageFromSyncanoMessage(message!))
                self.messages.append(self.jsqMessageFromSyncanoMessage(responseMessage))
                //self.iFlySpeechSynthesizer.startSpeaking(responseMessage.text)
                self.finishReceivingMessage()
            }else{
                print("chat error \(error)")
            }
        }
    }
    
    func doSendCommandToCattie(command:String){
        print("doSendCommandToCattie 1")
        messageManager.sendCmdWithCompletionBlock(command, username:uid) {responseMessage, error in
            if (error == nil) {
                //self.messages.append(self.jsqMessageFromSyncanoMessage(message!))
                self.messages.append(self.jsqMessageFromSyncanoMessage(responseMessage))
                self.finishReceivingMessage()
            }else{
                print("chat error \(error)")
            }
        }
    }
    
    //todo: save msg to internal storage , and display it when logged in
    func retriveMessagesFromStorage() {
        let messages:[Message] = messageManager.getAllMessages()
        print("messages count: \(messages.count)")
        if(messages.count > 0){
            self.messages = self.jsqMessagesFromSyncanoMessages(messages)
            self.finishReceivingMessage()
        }
    }
    
    func jsqMessageFromSyncanoMessage(message:Message)->JSQMessage{
        let jsqMessage = JSQMessage(senderId: message.senderid, senderDisplayName: message.senderid, date: message.create_at, text: message.text)
        self.iFlySpeechSynthesizer.startSpeaking(message.text)
        return jsqMessage
    }
    
    func jsqMessagesFromSyncanoMessages(messages:[Message]) -> [JSQMessage] {
        
        var jsqMessage:[JSQMessage] = []
        for message in messages {
            jsqMessage.append(self.jsqMessageFromSyncanoMessage(message))
        }
        return jsqMessage
    }
    
}


extension ViewController {
    
    func beginChat(finished: (Bool) -> ()){
        print("beginChat")
        //let uid = UIDevice.currentDevice().identifierForVendor!.UUIDString
        CTUser.startChatSession(uid, finished: finished)
    }
}

extension ViewController {
    
    func initTimer(){
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
    }
    
    func timerAction(){
        print(NSDate())
    }
}

extension ViewController {
    func setupIFly(){
        iFlySpeechSynthesizer.delegate = self
        iFlySpeechSynthesizer.setParameter(IFlySpeechConstant.TYPE_CLOUD(),forKey: IFlySpeechConstant.ENGINE_TYPE())
        iFlySpeechSynthesizer.setParameter("50", forKey: IFlySpeechConstant.VOLUME())
        iFlySpeechSynthesizer.setParameter("xiaoyan", forKey: IFlySpeechConstant.VOICE_NAME())
        iFlySpeechSynthesizer.setParameter("tts.pcm", forKey: IFlySpeechConstant.TTS_AUDIO_PATH())
        //iFlySpeechSynthesizer.startSpeaking("你好，我是科大讯飞的小燕")
        
    }
}

extension ViewController:IFlySpeechSynthesizerDelegate {
    func onCompleted(error: IFlySpeechError!) {
        print("onCompleted")
    }
    
    func onSpeakBegin() {
        print("onSpeakBegin")
    }
    
    func onBufferProgress(progress: Int32, message msg: String!) {
        print("onBufferProgress")
    }
    
    func onSpeakProgress(progress: Int32, beginPos: Int32, endPos: Int32) {
        
    }
}





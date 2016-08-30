//
//  ViewController.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/20.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ChatDataSource,UITextFieldDelegate {
    
    var messageManager = MessageManager()
    /*
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    */
    
    //let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(loginViewControllerIdentifier) as! LoginViewController
    
    //let syncano = Syncano.sharedInstanceWithApiKey(syncanoApiKey, instanceName: syncanoInstaneName)
    //let channel = SCChannel(name: syncanoChannelName)
    let channel = CTChannel(name: syncanoChannelName)
    
    //var messages = [JSQMessage]()
    
    var uid:String = UIDevice.currentDevice().identifierForVendor!.UUIDString
    var iFlySpeechSynthesizer:IFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
    
    
    //huangge
    var Chats:NSMutableArray!
    var tableView:TableView!
    var me:UserInfo!
    var you:UserInfo!
    var txtMsg:UITextField!
    //huangge end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.setupIFly()
        
        //huangge
        setupChatTable()
        setupSendPanel()
        //huangge end
    }
    
    //hunagge
    func setupSendPanel()
    {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let sendView = UIView(frame:CGRectMake(0,self.view.frame.size.height - 56,screenWidth,56))
        
        sendView.backgroundColor=UIColor.lightGrayColor()
        sendView.alpha=0.9
        
        txtMsg = UITextField(frame:CGRectMake(7,10,screenWidth - 95,36))
        txtMsg.backgroundColor = UIColor.whiteColor()
        txtMsg.textColor=UIColor.blackColor()
        txtMsg.font=UIFont.boldSystemFontOfSize(12)
        txtMsg.layer.cornerRadius = 10.0
        txtMsg.returnKeyType = UIReturnKeyType.Send
        
        //Set the delegate so you can respond to user input
        txtMsg.delegate=self
        sendView.addSubview(txtMsg)
        self.view.addSubview(sendView)
        
        let sendButton = UIButton(frame:CGRectMake(screenWidth - 80,10,72,36))
        sendButton.backgroundColor=UIColor(red: 0x37/255, green: 0xba/255, blue: 0x46/255, alpha: 1)
        sendButton.addTarget(self, action:#selector(ViewController.sendMessage) ,
                             forControlEvents:UIControlEvents.TouchUpInside)
        sendButton.layer.cornerRadius=6.0
        sendButton.setTitle("发送", forState:UIControlState.Normal)
        sendView.addSubview(sendButton)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        sendMessage()
        return true
    }
    
    func sendMessage()
    {
        //composing=false
        let sender = txtMsg
        let thisChat =  MessageItem(body:sender.text!, user:me, date:NSDate(), mtype:ChatType.Mine)
        let thatChat =  MessageItem(body:"你说的是：\(sender.text!)", user:you, date:NSDate(), mtype:ChatType.Someone)
        
        Chats.addObject(thisChat)
        Chats.addObject(thatChat)
        self.tableView.chatDataSource = self
        self.tableView.reloadData()
        
        //self.showTableView()
        sender.resignFirstResponder()
        sender.text = ""
    }
    
    func setupChatTable()
    {
        self.tableView = TableView(frame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 76), style: .Plain)
        
        //创建一个重用的单元格
        self.tableView!.registerClass(TableViewCell.self, forCellReuseIdentifier: "ChatCell")
        me = UserInfo(name:"Xiaoming" ,logo:("xiaoming.png"))
        you  = UserInfo(name:"Xiaohua", logo:("xiaohua.png"))
        
        
        let first =  MessageItem(body:"嘿，这张照片咋样，我在泸沽湖拍的呢！", user:me,  date:NSDate(timeIntervalSinceNow:-600), mtype:ChatType.Mine)
        
        let second =  MessageItem(image:UIImage(named:"luguhu.jpeg")!,user:me, date:NSDate(timeIntervalSinceNow:-290), mtype:ChatType.Mine)
        
        let third =  MessageItem(body:"太赞了，我也想去那看看呢！",user:you, date:NSDate(timeIntervalSinceNow:-60), mtype:ChatType.Someone)
        
        let fouth =  MessageItem(body:"嗯，下次我们一起去吧！",user:me, date:NSDate(timeIntervalSinceNow:-20), mtype:ChatType.Mine)
        
        let fifth =  MessageItem(body:"好的，一定！",user:you, date:NSDate(timeIntervalSinceNow:0), mtype:ChatType.Someone)
        
        let zero =  MessageItem(body:"最近去哪玩了？", user:you,  date:NSDate(timeIntervalSinceNow:-96400), mtype:ChatType.Someone)
        
        let zero1 =  MessageItem(body:"去了趟云南，明天发照片给你哈？", user:me,  date:NSDate(timeIntervalSinceNow:-86400), mtype:ChatType.Mine)
        
        Chats = NSMutableArray()
        Chats.addObjectsFromArray([first,second, third, fouth, fifth, zero, zero1])
        
        //set the chatDataSource
        self.tableView.chatDataSource = self
        
        //call the reloadData, this is actually calling your override method
        self.tableView.reloadData()
        
        self.view.addSubview(self.tableView)
    }
    
    func rowsForChatTable(tableView:TableView) -> Int
    {
        return self.Chats.count
    }
    
    func chatTableView(tableView:TableView, dataForRow row:Int) -> MessageItem
    {
        return Chats[row] as! MessageItem
    }
    //huangge end
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessageView() {
        //huangge self.collectionView?.reloadData()
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
        //huangge self.senderId = ME
        
        //huangge self.senderDisplayName = ME
        self.prepareAppForNewUser()
        
        self.beginChat({ isSucceed in
            //self.prepareAppForNewUser()
            //huangge self.sendCommandToCattie("1")
        })
        
        //initTimer()
        
    }
    
    func prepareAppForNewUser() {
        print("prepareAppForNewUser")
        //self.setupSenderData()
        self.reloadAllMessages()
    }
    
    func reloadAllMessages() {
        //self.messages = []
        self.reloadMessageView()
        //huangge self.retriveMessagesFromStorage()
    }
    
    /*huangge
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

            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
            self.addMedia(photoItem)
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .Default) { (action) in

            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .Default) { (action) in

            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .Default) { (action) in

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
 */
    
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






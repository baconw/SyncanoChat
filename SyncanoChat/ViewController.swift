//
//  ViewController.swift
//  SyncanoChat
//
//  Created by dongyi228 on 16/7/20.
//  Copyright © 2016年 dongyi228. All rights reserved.
//

import UIKit

enum InputType
{
    case Text
    case Audio
}

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
    var iFlySpeechRecognizer:IFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance()
    
    var inputTypeButton:UIButton!
    var inputType = InputType.Text
    var sendView:UIView!
    var audioView:UIView!
    var audioCancelTips:UILabel!
    
    //huangge
    var Chats:NSMutableArray!
    var tableView:TableView!
    var me:UserInfo!
    var you:UserInfo!
    var txtMsg:UITextField!
    //huangge end
    
    var txtButton:UIButton!
    var curResult:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //print("11111")
        self.setup()
        //print("22222")
        self.setupIFly()
        //print("33333")
        //huangge
        setupChatTable()
        //print("44444")
        setupSendPanel()
        //print("55555")
        //huangge end
    }
    
    //hunagge
    func setupSendPanel()
    {
        let screenWidth = UIScreen.mainScreen().bounds.width
        sendView = UIView(frame:CGRectMake(0,self.view.frame.size.height - 56,screenWidth,56))
        
        sendView.backgroundColor=UIColor.lightGrayColor()
        sendView.alpha=0.9
        
        inputTypeButton = UIButton(frame: CGRectMake(5,10,72,36))
        inputTypeButton.backgroundColor=UIColor(red: 0x37/255, green: 0xba/255, blue: 0x46/255, alpha: 1)
        inputTypeButton.addTarget(self, action:#selector(ViewController.changeInputType) , forControlEvents:UIControlEvents.TouchUpInside)
        inputTypeButton.layer.cornerRadius=6.0
        inputTypeButton.setTitle("说话", forState:UIControlState.Normal)
        sendView.addSubview(inputTypeButton)
        
        
        txtMsg = UITextField(frame:CGRectMake(80,10,screenWidth - 180,36))
        txtMsg.backgroundColor = UIColor.whiteColor()
        txtMsg.textColor=UIColor.blackColor()
        txtMsg.font=UIFont.boldSystemFontOfSize(12)
        txtMsg.layer.cornerRadius = 10.0
        txtMsg.returnKeyType = UIReturnKeyType.Send
        
        //Set the delegate so you can respond to user input
        txtMsg.delegate=self
        sendView.addSubview(txtMsg)
        
        txtButton = UIButton(frame:CGRectMake(80,10,screenWidth - 180,36))
        txtButton.backgroundColor = UIColor.whiteColor()
        txtButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        txtButton.addTarget(self, action:#selector(ViewController.startSpeaking) , forControlEvents:UIControlEvents.TouchDown)
        txtButton.addTarget(self, action:#selector(ViewController.finishSpeaking) , forControlEvents:UIControlEvents.TouchUpInside)
        txtButton.addTarget(self, action:#selector(ViewController.cancelSpeaking) , forControlEvents:UIControlEvents.TouchUpOutside)
        txtButton.setTitle("按住说话", forState: UIControlState.Normal)
        //sendView.addSubview(txtButton)
        
        
        
        let sendButton = UIButton(frame:CGRectMake(screenWidth - 80,10,72,36))
        sendButton.backgroundColor=UIColor(red: 0x37/255, green: 0xba/255, blue: 0x46/255, alpha: 1)
        sendButton.addTarget(self, action:#selector(ViewController.onSendButtonTouchDown) ,forControlEvents:UIControlEvents.TouchUpInside)
        sendButton.layer.cornerRadius=6.0
        sendButton.setTitle("发送", forState:UIControlState.Normal)
        sendView.addSubview(sendButton)
        
        self.view.addSubview(sendView)
        
        let audioBackgroundImg = UIImageView(image: UIImage(named:"blackblock"))
        audioView = UIView(frame:CGRectMake(self.view.frame.size.width/2-audioBackgroundImg.frame.size.width/2,self.view.frame.size.height/2-audioBackgroundImg.frame.size.height/2 ,audioBackgroundImg.frame.size.width,audioBackgroundImg.frame.size.height))
        audioView.addSubview(audioBackgroundImg)
        self.view.addSubview(audioView)
        audioView.hidden = true
        
        audioCancelTips = UILabel(frame:CGRectMake(3,audioBackgroundImg.frame.size.height-40,140,36))
        //audioCancelTips.backgroundColor = UIColor.whiteColor()
        audioCancelTips.textColor=UIColor.whiteColor()
        audioCancelTips.font=UIFont.boldSystemFontOfSize(14)
        audioCancelTips.text = "手指上滑，取消发送"
        audioView.addSubview(audioCancelTips)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        onSendButtonTouchDown()
        return true
    }
    
    func startSpeaking(){
        print("startSpeaking")
        txtButton.backgroundColor=UIColor.grayColor()
        audioView.hidden = false
        
        curResult = ""
        iFlySpeechRecognizer.startListening()
    }
    
    func finishSpeaking(){
        print("finishSpeaking")
        txtButton.backgroundColor=UIColor.whiteColor()
        audioView.hidden = true
        
        iFlySpeechRecognizer.stopListening()
    }
    
    func cancelSpeaking(){
        print("cancelSpeaking")
        txtButton.backgroundColor=UIColor.whiteColor()
        audioView.hidden = true
        
        iFlySpeechRecognizer.cancel()
    }
    
    func changeInputType(){
        print("changeInputType origin value: \(inputType)")
        var title = "说话"
        switch inputType {
        case InputType.Text:
            inputType = .Audio
            title = "打字"
            txtMsg.removeFromSuperview()
            sendView.addSubview(txtButton)
        default:
            inputType = .Text
            txtButton.removeFromSuperview()
            sendView.addSubview(txtMsg)
        }
        self.inputTypeButton.setTitle(title, forState: UIControlState.Normal)
    }
    
    func onSendButtonTouchDown()
    {
        //composing=false
        let sender = txtMsg
        
        /*
        let thisChat =  MessageItem(body:.text(sender.text!), user:me, date:NSDate(), mtype:ChatType.Outgoing)
        
        //let thatChat =  MessageItem(body:.text("你说的是：\(sender.text!)"), user:you, date:NSDate(), mtype:ChatType.Incoming)
        
        Chats.addObject(thisChat)
        self.sendMessageToCattie(thisChat)
        
        //Chats.addObject(thatChat)
        self.tableView.chatDataSource = self
        self.tableView.reloadData()
        */
        sendMessage(sender.text!)
        
        //self.showTableView()
        sender.resignFirstResponder()
        sender.text = ""
    }
    
    func sendMessage(txt:String){
        let thisChat =  MessageItem(body:.text(txt), user:me, date:NSDate(), mtype:ChatType.Outgoing)
        
        //let thatChat =  MessageItem(body:.text("你说的是：\(sender.text!)"), user:you, date:NSDate(), mtype:ChatType.Incoming)
        
        Chats.addObject(thisChat)
        self.sendMessageToCattie(thisChat)
        
        //Chats.addObject(thatChat)
        self.tableView.chatDataSource = self
        self.tableView.reloadData()
        
        
    }
    
    func setupChatTable()
    {
        self.tableView = TableView(frame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 76), style: .Plain)
        
        //创建一个重用的单元格
        self.tableView!.registerClass(TableViewCell.self, forCellReuseIdentifier: "ChatCell")
        
        me = UserInfo(name:ME ,logo:("me-face"))
        you  = UserInfo(name:SERVER, logo:("cat-face"))

        loadMsgs()
        
        print("setupChatTable 1")
        //set the chatDataSource
        self.tableView.chatDataSource = self
        
        print("setupChatTable 2")
        
        //call the reloadData, this is actually calling your override method
        self.tableView.reloadData()
        
        print("setupChatTable 3")
        
        self.view.addSubview(self.tableView)
        
        print("setupChatTable 4")
    }
    
    func loadMsgs(){
        print("loadMsgs 1")
        /*
        let first =  MessageItem(body:.text("嘿，这张照片咋样，我在泸沽湖拍的呢！"), user:me,  date:NSDate(timeIntervalSinceNow:-600), mtype:ChatType.Outgoing)
        
        let second =  MessageItem(body:.image(UIImage(named:"luguhu.jpeg")!),user:me, date:NSDate(timeIntervalSinceNow:-290), mtype:ChatType.Outgoing)
        */
        let messages:[Message] = messageManager.getAllMessages()
        //print("messages count: \(messages.count)")
        Chats = NSMutableArray()
        
        print("loadMsgs 2")
        
        
        for message in messages {
            let userInfo = (message.senderid == ME) ? me : you
            let mtype = (message.senderid == ME) ? ChatType.Outgoing : ChatType.Incoming
            let msg = MessageItem(body:.text(message.text!),user:userInfo, date:message.create_at!,mtype:mtype)
            Chats.addObject(msg)
        }
        
        print("loadMsgs 3")
        /*Chats.addObjectsFromArray([first, second, third, fouth, fifth, zero, zero1])*/
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
    */
    
    //syncano
    func sendMessageToCattie(message:MessageItem){
        print("sendMessageToCattie 1")
        
        switch (message.content) {
        case .image(let img):
            print("sendMessageToCattie img \(img)")
        case .text(let text):
            messageManager.saveMessage(text as String, sender: message.user.username)
            
            if(CTUser.isServerRunning){
                self.doSendMessageToCattie(message)
            }else{
                self.beginChat({isSucceed in self.doSendMessageToCattie(message)})
            }
        }
        
    }
    
    /*
    func sendCommandToCattie(commandStr:String){
        print("sendCommandToCattie 1")
        
        if(CTUser.isServerRunning){
            self.doSendCommandToCattie(commandStr)
        }else{
            self.beginChat({isSucceed in self.doSendCommandToCattie(commandStr)})
        }
    }
    */
    
    func doSendMessageToCattie(message:MessageItem){
        print("doSendMessageToCattie 1")
        switch (message.content) {
        case .image(let img):
            print("doSendMessageToCattie img \(img)")
        case .text(let text):
            messageManager.sendMsgWithCompletionBlock(text as String, username:uid) {responseMessage, error in
                if (error == nil) {
                    //self.messages.append(self.jsqMessageFromSyncanoMessage(message!))
                    let thatChat =  MessageItem(body:.text(responseMessage.text!), user:self.you, date:NSDate(), mtype:ChatType.Incoming)
                    self.Chats.addObject(thatChat)
                    self.tableView.reloadData()
                    //self.iFlySpeechSynthesizer.startSpeaking(responseMessage.text)
                    
                }else{
                    print("chat error \(error)")
                }
            }
        }
        
    }
    
    /*
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
 */
    
     /*
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
        iFlySpeechSynthesizer.setParameter("xiaojing", forKey: IFlySpeechConstant.VOICE_NAME())//xiaojing
        iFlySpeechSynthesizer.setParameter("tts.pcm", forKey: IFlySpeechConstant.TTS_AUDIO_PATH())
        //iFlySpeechSynthesizer.startSpeaking("你好，我是科大讯飞的小燕")
        
        iFlySpeechRecognizer.delegate = self
        iFlySpeechRecognizer.setParameter("iat", forKey: IFlySpeechConstant.IFLY_DOMAIN())
        iFlySpeechRecognizer.setParameter("asrview.pcm", forKey: IFlySpeechConstant.ASR_AUDIO_PATH())
        iFlySpeechRecognizer.setParameter("json", forKey: IFlySpeechConstant.RESULT_TYPE())
        
        curResult = ""
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

extension ViewController:IFlySpeechRecognizerDelegate {
    
    
    
    func onBeginOfSpeech() {
        print("onBeginOfSpeech")
    }
    
    func onEndOfSpeech() {
        print("onEndOfSpeech")
    }
    
    func onSpeakCancel() {
        print("onSpeakCancel")
    }
    
    func onVolumeChanged(volume: Int32) {
        print("onVolumeChanged \(volume)")
    }
    
    func onError(errorCode: IFlySpeechError!) {
        print("onError")
    }
    
    func onResults(results: [AnyObject]!, isLast: Bool) {
        print("onResults")
        //var result = NSMutableString.init()
        var result = ""
        var resultString = ""
        
        if(results != nil && results.count>0){
        let dic = results[0] as! Dictionary<String, String>
        
        for key in dic{
            //print("key:\(key)")
            //result.appendFormat("%@",key.0,key.1)
            result.appendContentsOf(key.0)
            //result = result.stringByAppendingFormat("%@", key.0)
            //result.appendContentsOf(key.1)
            //let resultFromJson = ISRDataHelper.stringFromABNFJson(result)
            let resultFromJson = ISRDataHelper.stringFromJson(result)
            resultString.appendContentsOf(resultFromJson)
        }
        
        curResult.appendContentsOf(resultString)
        if(isLast){
            print("result is : \(curResult)")
            sendMessage(curResult)
        }
        }
    }
}




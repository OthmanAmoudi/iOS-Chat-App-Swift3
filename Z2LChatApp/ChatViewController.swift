//
//  ChatViewController.swift
//  Z2LChatApp
//
//  Created by Othman Mashaab on 05/04/2017.
//  Copyright © 2017 Othman Mashaab. All rights reserved.
//
import AVKit
import MobileCoreServices
import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import Firebase

class ChatViewController: JSQMessagesViewController {

    var messages = [JSQMessage]()
    var messageRef = FIRDatabase.database().reference().child("messages")
    var avatarDict = [String: JSQMessagesAvatarImage]()

    @IBAction func logoutDidTapped(_ sender: Any) {
        do{
            try FIRAuth.auth()?.signOut()
        } catch let error{
            print(error)
        }
        
        print(FIRAuth.auth()?.currentUser)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier:"loginVC") as! LoginViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser{
    
        self.senderId = currentUser.uid
        
            if currentUser.isAnonymous == true {
            self.senderDisplayName = "Anonymouse"
            }
        
            else{
            self.senderDisplayName = "\(currentUser.displayName!)"
            }

        }
            
       observeMessages()
  //      observeUsers()
       
    }
    
    func observeUsers(id: String){
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                print("@@@@@\(dict)")
                let avatarUrl = dict["profileUrl"] as! String
                
                self.setupAvatar(url: avatarUrl, messageId: id)
            }
        })
    }
    
    func setupAvatar(url: String, messageId: String){
        if url != ""{
            let fileUrl = NSURL(string: url)
            let data = NSData(contentsOf: fileUrl! as URL)
            let image = UIImage(data: data! as Data)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatarDict[messageId] = userImg
            }
            
            else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView.reloadData()
    }
    func observeMessages(){
        messageRef.observe(.childAdded, with: {snapshot in
            if let dict = snapshot.value as? [String: AnyObject]{
                // let mediaType = dict["MediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                let text = dict["text"] as? String
                
                self.observeUsers(id: senderId)
                
                self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                
                /*
                 if let text = dict["text"] as? String{
                 self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                 } else {
                 let fileUrl = dict["fileUrl"]  as! String
                 let data = NSURL(contentsOfURL: (NSURL(string: fileUrl) as URL?)!)
                 let picture = UIImage(data: data!)
                 }
                 */
                /*
                 switch mediaType{
                 
                 case "text":
                 let text = dict["text"] as! String
                 self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                 
                 case "photo":
                 let fileUrl = dict["fileUrl"]  as! String
                 let data = NSData(contentsOfURL: (NSURL(string: fileUrl) as? URL)!)
                 let picture = UIImage(data: data!)
                 let photo = JSQPhotoMediaItem(image: picture)
                 self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: photo)
                 
                 if self.senderId == senderId{
                 photo.appliesMediaViewMaskAsOutgoing = true
                 }else{
                 
                 }
                 } */
                
                
                self.collectionView.reloadData()
            }
        })
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()

        if message.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .magenta)
        }
        
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        return avatarDict[message.senderId]
        
        //return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
    }
    
        override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("didPressSendButton")
        print("XXXXXXXXXXXXXX\(text)")
        print(senderId)
        print(senderDisplayName)
        
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
//        print(messages)
        
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "Media Type": "text message"]
        
        let newMessage = messageRef.childByAutoId()
        newMessage.setValue(messageData)
        self.finishSendingMessage()
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("didPressAccessoryButton")
       
        let sheet = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancel = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel){
            (alert:UIAlertAction) in
        }
        
        let photoLibrary = UIAlertAction(title: "Photos Library", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
            self.getMedia(type: kUTTypeImage)
        }
        
        let videoLibrary = UIAlertAction(title: "Videos Library", style: UIAlertActionStyle.default) { (alert:UIAlertAction) in
            self.getMedia(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func getMedia(type: CFString){
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        print("did Tapped buble at indexpath: \(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage{
            if let mediaItem = message.media as? JSQVideoMediaItem{
            let player = AVPlayer(url: mediaItem.fileURL)
            let playerViewController = AVPlayerViewController()
                playerViewController.player = player
            self.present(playerViewController, animated: true, completion: nil)
         }
      }
   }
}

extension ChatViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Did finish picking media")
        print(info)
        
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage{
        let photo = JSQPhotoMediaItem(image: picture)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? NSURL{
            let videoItem = JSQVideoMediaItem(fileURL: video as URL!, isReadyToPlay:true)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

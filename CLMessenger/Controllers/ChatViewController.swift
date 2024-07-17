//
//  ChatViewController.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/7/15.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
//    var kind: MessageKit.MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var message = [Message]()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "Joe Smith")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        message.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("Hello World message")))
        
        message.append(Message(sender: selfSender,
                               messageId: "1",
                               sentDate: Date(),
                               kind: .text("Hello World message, Hello World message")))
        
        view.backgroundColor = .cyan
        messageInputBar.sendButton.title = "發送"
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return message[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return message.count
    }
    
    
}

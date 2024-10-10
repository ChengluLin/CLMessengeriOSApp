//
//  ConversationsModels.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/10/8.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

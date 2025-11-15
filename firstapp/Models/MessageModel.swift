//
//  MessageModel.swift
//  firstapp
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Message Model
struct Message: Identifiable, Codable, Hashable {
    let id: String
    let conversationId: String
    let senderId: String
    let text: String
    let createdAt: Date
    let isRead: Bool
    let messageType: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case product
    }
    
    init(
        id: String = UUID().uuidString,
        conversationId: String,
        senderId: String,
        text: String,
        createdAt: Date = Date(),
        isRead: Bool = false,
        messageType: MessageType = .text
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.text = text
        self.createdAt = createdAt
        self.isRead = isRead
        self.messageType = messageType
    }
}

// MARK: - Conversation Model
struct Conversation: Identifiable, Codable, Hashable {
    let id: String
    let participantIds: [String]
    let lastMessage: Message?
    let lastMessageAt: Date
    let unreadCount: Int
    
    init(
        id: String = UUID().uuidString,
        participantIds: [String],
        lastMessage: Message? = nil,
        lastMessageAt: Date = Date(),
        unreadCount: Int = 0
    ) {
        self.id = id
        self.participantIds = participantIds
        self.lastMessage = lastMessage
        self.lastMessageAt = lastMessageAt
        self.unreadCount = unreadCount
    }
    
    func otherParticipantId(currentUserId: String) -> String? {
        participantIds.first { $0 != currentUserId }
    }
}


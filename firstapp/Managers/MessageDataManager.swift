//
//  MessageDataManager.swift
//  firstapp
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MessageDataManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [String: [Message]] = [:] // Keyed by conversationId
    
    private let userManager: UserDataManager
    
    init(userManager: UserDataManager) {
        self.userManager = userManager
        createMockConversations()
    }
    
    private func createMockConversations() {
        guard let currentUser = userManager.currentUser else { return }
        
        // Create conversations with different users
        let otherUsers = userManager.users.filter { $0.id != currentUser.id }
        
        for (index, user) in otherUsers.prefix(4).enumerated() {
            let conversationId = UUID().uuidString
            
            // Create some mock messages
            let mockMessages: [Message] = [
                Message(
                    conversationId: conversationId,
                    senderId: user.id,
                    text: "Hey! I saw your post about that product. Is it still available?",
                    createdAt: Date().addingTimeInterval(-Double(3600 * (index + 1))),
                    isRead: index > 0
                ),
                Message(
                    conversationId: conversationId,
                    senderId: currentUser.id,
                    text: "Yes! It's still available. Would you like to know more about it?",
                    createdAt: Date().addingTimeInterval(-Double(3500 * (index + 1))),
                    isRead: true
                ),
                Message(
                    conversationId: conversationId,
                    senderId: user.id,
                    text: "That would be great! Can you tell me more about the condition?",
                    createdAt: Date().addingTimeInterval(-Double(3400 * (index + 1))),
                    isRead: index > 0
                )
            ]
            
            messages[conversationId] = mockMessages
            
            let conversation = Conversation(
                id: conversationId,
                participantIds: [currentUser.id, user.id],
                lastMessage: mockMessages.last,
                lastMessageAt: mockMessages.last?.createdAt ?? Date(),
                unreadCount: index == 0 ? 1 : 0
            )
            
            conversations.append(conversation)
        }
        
        // Sort by most recent
        conversations.sort { $0.lastMessageAt > $1.lastMessageAt }
    }
    
    // MARK: - Conversation Methods
    
    func getConversation(with userId: String) -> Conversation? {
        guard let currentUser = userManager.currentUser else { return nil }
        return conversations.first { conversation in
            conversation.participantIds.contains(currentUser.id) &&
            conversation.participantIds.contains(userId)
        }
    }
    
    func getOrCreateConversation(with userId: String) -> Conversation {
        if let existing = getConversation(with: userId) {
            return existing
        }
        
        guard let currentUser = userManager.currentUser else {
            fatalError("No current user")
        }
        
        let newConversation = Conversation(
            participantIds: [currentUser.id, userId]
        )
        conversations.insert(newConversation, at: 0)
        messages[newConversation.id] = []
        return newConversation
    }
    
    func getMessages(for conversationId: String) -> [Message] {
        return messages[conversationId] ?? []
    }
    
    func getTotalUnreadCount() -> Int {
        return conversations.reduce(0) { $0 + $1.unreadCount }
    }
    
    // MARK: - Message Methods
    
    func sendMessage(to conversationId: String, text: String) {
        guard let currentUser = userManager.currentUser else { return }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            conversationId: conversationId,
            senderId: currentUser.id,
            text: text,
            createdAt: Date(),
            isRead: false
        )
        
        // Add message
        if messages[conversationId] != nil {
            messages[conversationId]?.append(newMessage)
        } else {
            messages[conversationId] = [newMessage]
        }
        
        // Update conversation
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            let conversation = conversations[index]
            let updatedConversation = Conversation(
                id: conversation.id,
                participantIds: conversation.participantIds,
                lastMessage: newMessage,
                lastMessageAt: newMessage.createdAt,
                unreadCount: 0
            )
            conversations[index] = updatedConversation
            
            // Move to top
            conversations.remove(at: index)
            conversations.insert(updatedConversation, at: 0)
        }
        
        // Simulate response after a delay (in a real app, this would come from the server)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.simulateResponse(conversationId: conversationId)
        }
    }
    
    private func simulateResponse(conversationId: String) {
        guard let conversation = conversations.first(where: { $0.id == conversationId }),
              let currentUser = userManager.currentUser,
              let otherUserId = conversation.otherParticipantId(currentUserId: currentUser.id) else {
            return
        }
        
        let responses = [
            "Thanks for getting back to me!",
            "That sounds great!",
            "I'm definitely interested.",
            "When can we arrange the details?",
            "Perfect! Let me know.",
            "Awesome, thanks!"
        ]
        
        let responseMessage = Message(
            conversationId: conversationId,
            senderId: otherUserId,
            text: responses.randomElement() ?? "Great!",
            createdAt: Date(),
            isRead: false
        )
        
        messages[conversationId]?.append(responseMessage)
        
        // Update conversation with unread count
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            let conversation = conversations[index]
            let updatedConversation = Conversation(
                id: conversation.id,
                participantIds: conversation.participantIds,
                lastMessage: responseMessage,
                lastMessageAt: responseMessage.createdAt,
                unreadCount: conversation.unreadCount + 1
            )
            conversations[index] = updatedConversation
            
            // Move to top
            conversations.remove(at: index)
            conversations.insert(updatedConversation, at: 0)
        }
    }
    
    func markConversationAsRead(_ conversationId: String) {
        guard let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        let conversation = conversations[index]
        let updatedConversation = Conversation(
            id: conversation.id,
            participantIds: conversation.participantIds,
            lastMessage: conversation.lastMessage,
            lastMessageAt: conversation.lastMessageAt,
            unreadCount: 0
        )
        conversations[index] = updatedConversation
        
        // Mark all messages as read
        if var conversationMessages = messages[conversationId] {
            conversationMessages = conversationMessages.map { message in
                Message(
                    id: message.id,
                    conversationId: message.conversationId,
                    senderId: message.senderId,
                    text: message.text,
                    createdAt: message.createdAt,
                    isRead: true,
                    messageType: message.messageType
                )
            }
            messages[conversationId] = conversationMessages
        }
    }
    
    func deleteConversation(_ conversationId: String) {
        conversations.removeAll { $0.id == conversationId }
        messages.removeValue(forKey: conversationId)
    }
}


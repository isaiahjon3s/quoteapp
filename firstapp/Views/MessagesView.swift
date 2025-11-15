//
//  MessagesView.swift
//  firstapp
//
//  Created by AI Assistant
//

import SwiftUI

struct MessagesView: View {
    @ObservedObject var messageManager: MessageDataManager
    @ObservedObject var userManager: UserDataManager
    @State private var searchText = ""
    @State private var showNewMessage = false
    
    var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return messageManager.conversations }
        
        return messageManager.conversations.filter { conversation in
            guard let currentUser = userManager.currentUser,
                  let otherUserId = conversation.otherParticipantId(currentUserId: currentUser.id),
                  let otherUser = userManager.getUser(by: otherUserId) else {
                return false
            }
            
            return otherUser.displayName.localizedCaseInsensitiveContains(searchText) ||
                   otherUser.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search messages", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Button(action: {
                    showNewMessage = true
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Conversations List
            if filteredConversations.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "message")
                        .font(.system(size: 60, weight: .thin))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("No messages yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("Start a conversation with someone!")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary.opacity(0.7))
                    
                    Button(action: {
                        showNewMessage = true
                    }) {
                        Text("New Message")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredConversations) { conversation in
                            ConversationRow(
                                conversation: conversation,
                                messageManager: messageManager,
                                userManager: userManager
                            )
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Messages")
        .sheet(isPresented: $showNewMessage) {
            NewMessageView(
                messageManager: messageManager,
                userManager: userManager
            )
        }
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    @ObservedObject var messageManager: MessageDataManager
    @ObservedObject var userManager: UserDataManager
    @State private var showConversation = false
    
    var otherUser: User? {
        guard let currentUser = userManager.currentUser,
              let otherUserId = conversation.otherParticipantId(currentUserId: currentUser.id) else {
            return nil
        }
        return userManager.getUser(by: otherUserId)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: conversation.lastMessageAt, relativeTo: Date())
    }
    
    var body: some View {
        Button(action: {
            messageManager.markConversationAsRead(conversation.id)
            showConversation = true
        }) {
            HStack(spacing: 12) {
                // Profile Image
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .medium))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(otherUser?.displayName ?? "Unknown")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if otherUser?.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                        }
                        
                        Spacer()
                        
                        Text(timeAgo)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Text(conversation.lastMessage?.text ?? "Start a conversation")
                            .font(.system(size: 14))
                            .foregroundColor(conversation.unreadCount > 0 ? .primary : .secondary)
                            .fontWeight(conversation.unreadCount > 0 ? .semibold : .regular)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if conversation.unreadCount > 0 {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("\(conversation.unreadCount)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {
                messageManager.markConversationAsRead(conversation.id)
            }) {
                Label("Mark as Read", systemImage: "checkmark.circle")
            }
            
            Button(role: .destructive, action: {
                messageManager.deleteConversation(conversation.id)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showConversation) {
            if let otherUser = otherUser {
                ConversationView(
                    conversation: conversation,
                    otherUser: otherUser,
                    messageManager: messageManager,
                    userManager: userManager
                )
            }
        }
    }
}

// MARK: - New Message View
struct NewMessageView: View {
    @ObservedObject var messageManager: MessageDataManager
    @ObservedObject var userManager: UserDataManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredUsers: [User] {
        guard let currentUser = userManager.currentUser else { return [] }
        
        let otherUsers = userManager.users.filter { $0.id != currentUser.id }
        
        guard !searchText.isEmpty else { return otherUsers }
        
        return otherUsers.filter { user in
            user.displayName.localizedCaseInsensitiveContains(searchText) ||
            user.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search users", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Users List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredUsers) { user in
                            Button(action: {
                                let conversation = messageManager.getOrCreateConversation(with: user.id)
                                dismiss()
                                // Navigation will be handled by the parent view
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 22, weight: .medium))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Text(user.displayName)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.primary)
                                            
                                            if user.isVerified {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 12))
                                            }
                                        }
                                        
                                        Text("@\(user.username)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        MessagesView(
            messageManager: MessageDataManager(userManager: UserDataManager()),
            userManager: UserDataManager()
        )
    }
}


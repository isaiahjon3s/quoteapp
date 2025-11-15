//
//  ConversationView.swift
//  firstapp
//
//  Created by AI Assistant
//

import SwiftUI

struct ConversationView: View {
    let conversation: Conversation
    let otherUser: User
    @ObservedObject var messageManager: MessageDataManager
    @ObservedObject var userManager: UserDataManager
    
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var messages: [Message] {
        messageManager.getMessages(for: conversation.id)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == userManager.currentUser?.id,
                                    otherUser: otherUser
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }
                .background(Color(.systemGray6).opacity(0.3))
                
                // Message Input
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // Camera button
                        Button(action: {
                            // In a real app, this would open camera/photo picker
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.blue)
                        }
                        
                        // Text Field
                        HStack(spacing: 8) {
                            TextField("Message...", text: $messageText, axis: .vertical)
                                .font(.system(size: 16))
                                .lineLimit(1...5)
                                .focused($isTextFieldFocused)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        
                        // Send Button
                        Button(action: sendMessage) {
                            Image(systemName: messageText.isEmpty ? "heart" : "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(messageText.isEmpty ? .secondary : .blue)
                                .symbolEffect(.bounce, value: !messageText.isEmpty)
                        }
                        .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !messageText.isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle(otherUser.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                            )
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 4) {
                                Text(otherUser.displayName)
                                    .font(.system(size: 14, weight: .semibold))
                                
                                if otherUser.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 10))
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // View profile
                        }) {
                            Label("View Profile", systemImage: "person")
                        }
                        
                        Button(action: {
                            // Mute conversation
                        }) {
                            Label("Mute", systemImage: "bell.slash")
                        }
                        
                        Button(role: .destructive, action: {
                            messageManager.deleteConversation(conversation.id)
                            dismiss()
                        }) {
                            Label("Delete Conversation", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                    }
                }
            }
            .onAppear {
                messageManager.markConversationAsRead(conversation.id)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        messageManager.sendMessage(to: conversation.id, text: messageText)
        messageText = ""
        
        // Scroll to bottom after sending
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let proxy = scrollProxy, let lastMessage = messages.last {
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let otherUser: User
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !isCurrentUser {
                // Other user's profile picture
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .medium))
                    )
            } else {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isCurrentUser {
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [Color(.systemGray5), Color(.systemGray6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        }
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isCurrentUser ? Color.clear : Color(.separator).opacity(0.2),
                                lineWidth: 0.5
                            )
                    )
                
                // Timestamp
                Text(timeString)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 260, alignment: isCurrentUser ? .trailing : .leading)
            
            if isCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    ConversationView(
        conversation: Conversation(
            participantIds: ["user1", "user2"]
        ),
        otherUser: User(
            username: "sarah_style",
            displayName: "Sarah Chen",
            isVerified: true
        ),
        messageManager: MessageDataManager(userManager: UserDataManager()),
        userManager: UserDataManager()
    )
}


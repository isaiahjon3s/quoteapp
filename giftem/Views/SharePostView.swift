//
//  SharePostView.swift
//  giftem
//
//  Created by Isaiah Jones on 12/8/25.
//

import SwiftUI

struct SharePostView: View {
    let post: Post
    let product: Product?
    @ObservedObject var messageManager: MessageDataManager
    @ObservedObject var userManager: UserDataManager
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedUsers: Set<String> = []
    @State private var isSending = false
    @State private var showSentConfirmation = false
    
    var filteredUsers: [User] {
        let otherUsers = userManager.users.filter { $0.id != userManager.currentUser?.id }
        if searchText.isEmpty {
            return otherUsers
        }
        return otherUsers.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider()
                
                // User list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredUsers) { user in
                            ShareUserRow(
                                user: user,
                                isSelected: selectedUsers.contains(user.id)
                            ) {
                                toggleUser(user.id)
                            }
                            
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
                
                // Send button
                if !selectedUsers.isEmpty {
                    VStack(spacing: 0) {
                        Divider()
                        
                        Button(action: sendPost) {
                            HStack {
                                if isSending {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send to \(selectedUsers.count) \(selectedUsers.count == 1 ? "person" : "people")")
                                        .fontWeight(.semibold)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(isSending)
                        .padding(16)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Share Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if showSentConfirmation {
                    sentConfirmationOverlay
                }
            }
        }
    }
    
    private var sentConfirmationOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Sent!")
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func toggleUser(_ userId: String) {
        if selectedUsers.contains(userId) {
            selectedUsers.remove(userId)
        } else {
            selectedUsers.insert(userId)
        }
    }
    
    private func sendPost() {
        isSending = true
        
        // Create the share message text
        let productName = product?.name ?? "a product"
        let shareText = "Check out this post: \(productName) 🎁"
        
        // Send to all selected users
        for userId in selectedUsers {
            let conversation = messageManager.getOrCreateConversation(with: userId)
            messageManager.sendSharedPost(
                to: conversation.id,
                postId: post.id,
                productId: post.productId,
                text: shareText
            )
        }
        
        // Show confirmation
        withAnimation(.spring(response: 0.3)) {
            showSentConfirmation = true
        }
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }
}

// MARK: - Share User Row
struct ShareUserRow: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Profile image
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
                            .font(.system(size: 22))
                    )
                
                // User info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 16, weight: .semibold))
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
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color(.systemGray3), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}




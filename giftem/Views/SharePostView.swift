//
//  SharePostView.swift
//  giftem
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
    @State private var messageText = ""
    @State private var isSending = false
    @State private var showSentConfirmation = false
    @FocusState private var isMessageFocused: Bool

    var filteredUsers: [User] {
        var others = userManager.users.filter { $0.id != userManager.currentUser?.id }
        // Fran Peters always appears first
        others.sort { a, _ in a.username == "mamapeters75" }
        if searchText.isEmpty { return others }
        return others.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Product preview (content — no glass)
                if let product = product {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(product.category.color.opacity(0.85))
                                .frame(width: 52, height: 52)
                            if let firstImageURL = product.imageURLs.first {
                                Image(firstImageURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 52, height: 52)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: product.category.symbol)
                                    .font(.system(size: 22, weight: .thin))
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(product.name)
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                            Text("$\(product.formattedPrice)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "gift.fill")
                            .foregroundStyle(.purple)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    
                    Divider()
                }
                
                // Search bar (system gets glass automatically in iOS 26 sheets)
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 15))
                    TextField("Search people...", text: $searchText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                Divider()
                
                // User list (content — no glass)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredUsers) { user in
                            userRow(user: user)
                            if user.id != filteredUsers.last?.id {
                                Divider().padding(.leading, 72)
                            }
                        }
                    }
                }
                
                // Message input + send button (visible when recipients are selected)
                if !selectedUsers.isEmpty {
                    Divider()

                    VStack(spacing: 10) {
                        // Instagram-style message field
                        HStack(spacing: 10) {
                            if let currentUser = userManager.currentUser {
                                UserAvatarView(user: currentUser, size: 32)
                            }
                            TextField("Write a message...", text: $messageText)
                                .font(.system(size: 15))
                                .focused($isMessageFocused)
                                .submitLabel(.send)
                                .onSubmit { if !selectedUsers.isEmpty { sendPost() } }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 9)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                        .padding(.horizontal, 16)

                        Button(action: sendPost) {
                            Group {
                                if isSending {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Label(
                                        "Send to \(selectedUsers.count) \(selectedUsers.count == 1 ? "person" : "people")",
                                        systemImage: "paperplane.fill"
                                    )
                                    .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.blue)
                        .disabled(isSending)
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if showSentConfirmation {
                    sentConfirmationOverlay
                }
            }
        }
    }
    
    private func userRow(user: User) -> some View {
        let isSelected = selectedUsers.contains(user.id)
        
        return Button(action: { toggleUser(user.id) }) {
            HStack(spacing: 12) {
                UserAvatarView(user: user, size: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)
                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.system(size: 12))
                        }
                    }
                    Text("@\(user.username)")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Selection circle
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 26, height: 26)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Circle()
                            .stroke(Color(.systemGray3), lineWidth: 1.5)
                            .frame(width: 26, height: 26)
                    }
                }
                .animation(.bouncy(duration: 0.25), value: isSelected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? Color(.systemBlue).opacity(0.05) : Color.clear)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private var sentConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("Sent!")
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(40)
            .glassEffect(.regular, in: .rect(cornerRadius: 24, style: .continuous))
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }
    
    private func toggleUser(_ userId: String) {
        withAnimation(.bouncy(duration: 0.25)) {
            if selectedUsers.contains(userId) {
                selectedUsers.remove(userId)
            } else {
                selectedUsers.insert(userId)
            }
        }
    }
    
    private func sendPost() {
        isSending = true
        isMessageFocused = false
        let productName = product?.name ?? "a product"
        let defaultText = "Check out this post: \(productName) 🎁"
        let shareText = messageText.trimmingCharacters(in: .whitespaces).isEmpty ? defaultText : messageText.trimmingCharacters(in: .whitespaces)
        for userId in selectedUsers {
            let conversation = messageManager.getOrCreateConversation(with: userId)
            messageManager.sendSharedPost(to: conversation.id, postId: post.id, productId: post.productId, text: shareText)
        }
        withAnimation(.bouncy) { showSentConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
    }
}

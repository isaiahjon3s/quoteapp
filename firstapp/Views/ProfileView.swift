//
//  ProfileView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    @ObservedObject var userManager: UserDataManager
    @ObservedObject var productManager: ProductDataManager
    var messageManager: MessageDataManager?
    
    @StateObject private var feedManager: FeedDataManager
    @State private var showFollowers = false
    @State private var showMessageComposer = false
    
    var userPosts: [Post] {
        feedManager.getPostsForUser(user.id)
    }
    
    init(user: User, userManager: UserDataManager, productManager: ProductDataManager, messageManager: MessageDataManager? = nil) {
        self.user = user
        self.userManager = userManager
        self.productManager = productManager
        self.messageManager = messageManager
        
        let feedManager = FeedDataManager(productManager: productManager, userManager: userManager)
        _feedManager = StateObject(wrappedValue: feedManager)
    }
    
    var isCurrentUser: Bool {
        userManager.currentUser?.id == user.id
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    // Enhanced Profile Image
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 48, weight: .medium))
                        )
                    
                    // User Info
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text(user.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        Text("@\(user.username)")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 4)
                        }
                    }
                    
                    // Stats
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            Text("\(user.postCount)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Posts")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 0.5, height: 40)
                        
                        Button(action: {
                            showFollowers = true
                        }) {
                            VStack(spacing: 4) {
                                Text("\(user.followerCount)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Followers")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 0.5, height: 40)
                        
                        VStack(spacing: 4) {
                            Text("\(user.followingCount)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Following")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 12)
                    
                    // Enhanced Action Buttons
                    if !isCurrentUser {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    userManager.followUser(user.id)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Follow")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            if let messageManager = messageManager {
                                Button(action: {
                                    showMessageComposer = true
                                }) {
                                    HStack {
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Message")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 16)
                
                Divider()
                    .padding(.horizontal, 16)
                
                // Posts Grid
                if userPosts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50, weight: .light))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("No posts yet")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2)
                    ], spacing: 2) {
                        ForEach(userPosts.prefix(9)) { post in
                            if let product = productManager.getProduct(by: post.productId) {
                                NavigationLink(destination: ProductDetailView(
                                    product: product,
                                    postId: post.id,
                                    productManager: productManager,
                                    userManager: userManager,
                                    cartManager: CartDataManager(productManager: productManager)
                                )) {
                                    ZStack {
                                        Rectangle()
                                            .fill(categoryColor(for: product.category))
                                            .aspectRatio(1, contentMode: .fit)
                                        
                                        Image(systemName: categorySymbol(for: product.category))
                                            .font(.system(size: 40, weight: .thin))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFollowers) {
            // In a real app, this would show followers list
            Text("Followers: \(user.followerCount)")
        }
        .sheet(isPresented: $showMessageComposer) {
            if let messageManager = messageManager {
                let conversation = messageManager.getOrCreateConversation(with: user.id)
                ConversationView(
                    conversation: conversation,
                    otherUser: user,
                    messageManager: messageManager,
                    userManager: userManager
                )
            }
        }
    }
    
    // Helper functions for product image colors
    func categoryColor(for category: ProductCategory) -> Color {
        switch category {
        case .electronics: return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .fashion: return Color(red: 0.9, green: 0.4, blue: 0.5)
        case .home: return Color(red: 0.4, green: 0.7, blue: 0.5)
        case .beauty: return Color(red: 0.9, green: 0.6, blue: 0.7)
        case .sports: return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .books: return Color(red: 0.6, green: 0.4, blue: 0.3)
        case .toys: return Color(red: 0.9, green: 0.7, blue: 0.3)
        case .food: return Color(red: 0.8, green: 0.5, blue: 0.3)
        case .other: return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }
    
    func categorySymbol(for category: ProductCategory) -> String {
        switch category {
        case .electronics: return "airpodspro"
        case .fashion: return "tshirt"
        case .home: return "lamp.floor"
        case .beauty: return "sparkles"
        case .sports: return "figure.run"
        case .books: return "book"
        case .toys: return "gamecontroller"
        case .food: return "cup.and.saucer"
        case .other: return "square.grid.2x2"
        }
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    NavigationView {
        ProfileView(
            user: User(username: "test", displayName: "Test User"),
            userManager: UserDataManager(),
            productManager: ProductDataManager()
        )
    }
}







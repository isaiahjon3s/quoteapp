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
    
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var cartManager: CartDataManager
    @State private var showFollowers = false
    @State private var showMessageComposer = false
    @State private var showSettings = false
    @Environment(\.isDarkMode) private var isDarkMode
    
    var userPosts: [Post] {
        feedManager.getPostsForUser(user.id)
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
                    UserAvatarView(user: user, size: 100)
                        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
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
                    
                    // Action Buttons — Apple Liquid Glass
                    if !isCurrentUser {
                        GlassEffectContainer(spacing: 12) {
                            HStack(spacing: 12) {
                                // Primary action: .glassProminent with blue tint
                                Button {
                                    withAnimation(.bouncy(duration: 0.3)) {
                                        userManager.followUser(user.id)
                                    }
                                } label: {
                                    Label("Follow", systemImage: "person.badge.plus")
                                        .font(.system(size: 15, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 4)
                                }
                                .buttonStyle(.glassProminent)
                                .tint(.blue)
                                
                                // Secondary action: .glass (no tint)
                                if messageManager != nil {
                                    Button {
                                        showMessageComposer = true
                                    } label: {
                                        Label("Message", systemImage: "message.fill")
                                            .font(.system(size: 15, weight: .semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 4)
                                    }
                                    .buttonStyle(.glass)
                                }
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
                                    cartManager: cartManager
                                )) {
                                    GeometryReader { geometry in
                                        ZStack {
                                            // Show product image if available
                                            if let firstImageURL = product.imageURLs.first {
                                                Image(firstImageURL)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geometry.size.width, height: geometry.size.width)
                                                    .clipped()
                                        } else {
                                            Rectangle()
                                                .fill(product.category.color)
                                            
                                            Image(systemName: product.category.symbol)
                                                .font(.system(size: 40, weight: .thin))
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        }
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                    }
                                    .aspectRatio(1, contentMode: .fit)
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
                NavigationView {
                    ConversationView(
                        conversation: conversation,
                        otherUser: user,
                        messageManager: messageManager,
                        userManager: userManager
                    )
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(isDarkMode: isDarkMode)
        }
        .toolbar {
            if isCurrentUser {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
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
    let userMgr = UserDataManager()
    let prodMgr = ProductDataManager()
    NavigationView {
        ProfileView(
            user: User(username: "test", displayName: "Test User"),
            userManager: userMgr,
            productManager: prodMgr
        )
        .environmentObject(FeedDataManager(productManager: prodMgr, userManager: userMgr))
        .environmentObject(CartDataManager(productManager: prodMgr))
    }
}







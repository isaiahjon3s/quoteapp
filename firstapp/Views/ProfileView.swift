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
    
    @StateObject private var feedManager: FeedDataManager
    @State private var showFollowers = false
    
    var userPosts: [Post] {
        feedManager.getPostsForUser(user.id)
    }
    
    init(user: User, userManager: UserDataManager, productManager: ProductDataManager) {
        self.user = user
        self.userManager = userManager
        self.productManager = productManager
        
        let feedManager = FeedDataManager(productManager: productManager, userManager: userManager)
        _feedManager = StateObject(wrappedValue: feedManager)
    }
    
    var isCurrentUser: Bool {
        userManager.currentUser?.id == user.id
    }
    
    var body: some View {
        LiquidGlassBackground {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Image
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.system(size: 50))
                            )
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 3)
                            )
                        
                        // User Info
                        VStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Text(user.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if user.isVerified {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let bio = user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Stats
                        HStack(spacing: 32) {
                            VStack(spacing: 4) {
                                Text("\(user.postCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Posts")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button(action: {
                                showFollowers = true
                            }) {
                                VStack(spacing: 4) {
                                    Text("\(user.followerCount)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(user.followingCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text("Following")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 8)
                        
                        // Action Button
                        if !isCurrentUser {
                            LiquidGlassButton(
                                "Follow",
                                icon: "person.badge.plus",
                                style: .primary,
                                size: .medium
                            ) {
                                userManager.followUser(user.id)
                            }
                        }
                    }
                    .padding(.top)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Posts Grid
                    if userPosts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No posts yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 8) {
                            ForEach(userPosts.prefix(9)) { post in
                                if let product = productManager.getProduct(by: post.productId) {
                                    NavigationLink(destination: ProductDetailView(
                                        product: product,
                                        productManager: productManager,
                                        userManager: userManager,
                                        cartManager: CartDataManager(productManager: productManager)
                                    )) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .aspectRatio(1, contentMode: .fit)
                                            
                                            VStack(spacing: 8) {
                                                Image(systemName: product.category.icon)
                                                    .font(.title)
                                                    .foregroundColor(.white.opacity(0.6))
                                                Text(product.name)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.8))
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                            }
                                            .padding(8)
                                        }
                                        .liquidGlass(blur: 0.5, reflection: 0.3)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFollowers) {
            // In a real app, this would show followers list
            Text("Followers: \(user.followerCount)")
        }
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


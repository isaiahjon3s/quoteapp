//
//  FeedView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var productManager: ProductDataManager
    @EnvironmentObject var userManager: UserDataManager
    
    @State private var feedManager: FeedDataManager?
    @State private var cartManager: CartDataManager?
    @State private var selectedCategory: ProductCategory?
    
    var filteredPosts: [Post] {
        guard let feedManager = feedManager else { return [] }
        guard let category = selectedCategory else { return feedManager.posts }
        return feedManager.posts.filter { post in
            guard let product = productManager.getProduct(by: post.productId) else { return false }
            return product.category == category
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // All category
                        CategoryChip(
                            title: "All",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        // Category chips
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Posts Feed
                if let feedManager = feedManager, let cartManager = cartManager {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredPosts) { post in
                            PostCard(
                                post: post,
                                productManager: productManager,
                                userManager: userManager,
                                feedManager: feedManager,
                                cartManager: cartManager
                            )
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            if feedManager == nil {
                feedManager = FeedDataManager(productManager: productManager, userManager: userManager)
            }
            if cartManager == nil {
                cartManager = CartDataManager(productManager: productManager)
            }
        }
    }
}

// MARK: - Post Card
struct PostCard: View {
    let post: Post
    @ObservedObject var productManager: ProductDataManager
    @ObservedObject var userManager: UserDataManager
    @ObservedObject var feedManager: FeedDataManager
    @ObservedObject var cartManager: CartDataManager
    
    @State private var showProductDetail = false
    
    var product: Product? {
        productManager.getProduct(by: post.productId)
    }
    
    var user: User? {
        userManager.getUser(by: post.userId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // User Header
            HStack(spacing: 12) {
                // Profile Image - solid gradient circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(user?.displayName ?? "Unknown")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        if user?.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                        }
                    }
                    Text("@\(user?.username ?? "unknown")")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            // Product Image - Cleaner solid background
            if let product = product {
                ZStack {
                    // Solid color background based on category
                    Rectangle()
                        .fill(categoryColor(for: product.category))
                        .frame(height: 400)
                    
                    // Large SF Symbol for product
                    Image(systemName: categorySymbol(for: product.category))
                        .font(.system(size: 120, weight: .thin))
                        .foregroundColor(.white.opacity(0.8))
                }
                .onTapGesture {
                    showProductDetail = true
                }
                
                // Actions Bar (Instagram-style)
                HStack(spacing: 16) {
                    Button(action: {
                        feedManager.toggleLike(for: post.id)
                    }) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(post.isLiked ? .red : .primary)
                    }
                    
                    NavigationLink(destination: ProductDetailView(product: product, postId: post.id, productManager: productManager, userManager: userManager, cartManager: cartManager)) {
                        Image(systemName: "message")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showProductDetail = true
                    }) {
                        Image(systemName: "cart")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        cartManager.addToCart(productId: product.id, isForGift: true)
                    }) {
                        Image(systemName: "gift")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Product Info
                VStack(alignment: .leading, spacing: 8) {
                    // Likes count
                    if post.likeCount > 0 {
                        Text("\(post.likeCount) likes")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    // Product name and price
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 6) {
                                Text("$\(product.formattedPrice)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                if let originalPrice = product.originalPrice {
                                    Text("$\(String(format: "%.2f", originalPrice))")
                                        .font(.system(size: 13))
                                        .strikethrough()
                                        .foregroundColor(.secondary)
                                }
                                
                                if let discount = product.discountPercentage {
                                    Text("\(discount)% OFF")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Rating
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 12))
                            Text(String(format: "%.1f", product.rating))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Caption
                    Text(post.caption)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // View comments
                    if post.commentCount > 0 {
                        NavigationLink(destination: ProductDetailView(product: product, postId: post.id, productManager: productManager, userManager: userManager, cartManager: cartManager)) {
                            Text("View all \(post.commentCount) comments")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(0)
        .overlay(
            Rectangle()
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .padding(.bottom, 8)
        .sheet(isPresented: $showProductDetail) {
            if let product = product {
                ProductDetailView(product: product, postId: post.id, productManager: productManager, userManager: userManager, cartManager: cartManager)
            }
        }
    }
    
    // Helper functions for product image colors
    func categoryColor(for category: ProductCategory) -> Color {
        switch category {
        case .electronics:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .fashion:
            return Color(red: 0.9, green: 0.4, blue: 0.5)
        case .home:
            return Color(red: 0.4, green: 0.7, blue: 0.5)
        case .beauty:
            return Color(red: 0.9, green: 0.6, blue: 0.7)
        case .sports:
            return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .books:
            return Color(red: 0.6, green: 0.4, blue: 0.3)
        case .toys:
            return Color(red: 0.9, green: 0.7, blue: 0.3)
        case .food:
            return Color(red: 0.8, green: 0.5, blue: 0.3)
        case .other:
            return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }
    
    func categorySymbol(for category: ProductCategory) -> String {
        switch category {
        case .electronics:
            return "airpodspro"
        case .fashion:
            return "tshirt"
        case .home:
            return "lamp.floor"
        case .beauty:
            return "sparkles"
        case .sports:
            return "figure.run"
        case .books:
            return "book"
        case .toys:
            return "gamecontroller"
        case .food:
            return "cup.and.saucer"
        case .other:
            return "square.grid.2x2"
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.black : Color(.systemGray6)
            )
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        FeedView()
            .environmentObject(ProductDataManager())
            .environmentObject(UserDataManager())
    }
}

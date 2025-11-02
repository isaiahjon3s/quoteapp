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
        LiquidGlassBackground {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
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
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 12)
                    
                    // Posts Feed
                    if let feedManager = feedManager, let cartManager = cartManager {
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
                .padding(.vertical)
            }
        }
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
        LiquidGlassCard(padding: 0, isInteractive: true) {
            VStack(alignment: .leading, spacing: 0) {
                // User Header
                HStack(spacing: 12) {
                    // Profile Image
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 20))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(user?.displayName ?? "Unknown")
                                .font(.headline)
                            if user?.isVerified == true {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                        Text("@\(user?.username ?? "unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
                .padding(16)
                
                // Product Image
                if let product = product {
                    ZStack {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 300)
                        
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .onTapGesture {
                        showProductDetail = true
                    }
                    
                    // Product Info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 8) {
                                    Text("$\(product.formattedPrice)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    if let originalPrice = product.originalPrice {
                                        Text("$\(String(format: "%.2f", originalPrice))")
                                            .font(.body)
                                            .strikethrough()
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if let discount = product.discountPercentage {
                                        Text("\(discount)% OFF")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(.red.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Rating
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text(String(format: "%.1f", product.rating))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                Text("\(product.reviewCount) reviews")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Caption
                        Text(post.caption)
                            .font(.body)
                            .lineLimit(3)
                    }
                    .padding(16)
                    
                    // Actions
                    HStack(spacing: 24) {
                        Button(action: {
                            feedManager.toggleLike(for: post.id)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(post.isLiked ? .red : .secondary)
                                Text("\(post.likeCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        NavigationLink(destination: ProductDetailView(product: product, productManager: productManager, userManager: userManager, cartManager: cartManager)) {
                            HStack(spacing: 6) {
                                Image(systemName: "message")
                                    .foregroundColor(.secondary)
                                Text("\(post.commentCount)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Buy Button
                        LiquidGlassButton(
                            "Buy Now",
                            icon: "cart.fill",
                            style: .primary,
                            size: .small
                        ) {
                            showProductDetail = true
                        }
                        
                        // Gift Button
                        LiquidGlassButton(
                            "Gift",
                            icon: "gift.fill",
                            style: .accent,
                            size: .small
                        ) {
                            cartManager.addToCart(productId: product.id, isForGift: true)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showProductDetail) {
            if let product = product {
                ProductDetailView(product: product, productManager: productManager, userManager: userManager, cartManager: cartManager)
            }
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
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(20)
        }
        .liquidGlass(blur: isSelected ? 0.5 : 0.3, reflection: isSelected ? 0.3 : 0.1)
    }
}

#Preview {
    NavigationView {
        FeedView()
            .environmentObject(ProductDataManager())
            .environmentObject(UserDataManager())
    }
}

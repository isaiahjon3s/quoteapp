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
    @EnvironmentObject var feedManager: FeedDataManager
    @EnvironmentObject var cartManager: CartDataManager
    @EnvironmentObject var messageManager: MessageDataManager

    @State private var selectedCategory: ProductCategory?
    @State private var showAddProduct = false
    
    var filteredPosts: [Post] {
        guard let category = selectedCategory else { return feedManager.posts }
        return feedManager.posts.filter { post in
            guard let product = productManager.getProduct(by: post.productId) else { return false }
            return product.category == category
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // LOGO HEADER with Action Buttons
                HStack(spacing: 0) {
                    // Logo on the left
                    Image("giftem-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 25)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Header action buttons — glass on floating controls
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 8) {
                            // Plus button (Add Product) — .glass, interactive
                            Button(action: { showAddProduct = true }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .padding(8)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                            .buttonStyle(.plain)
                            
                            // Notification button — .glass, interactive
                            Button(action: {}) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(8)
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 2, y: 2)
                                }
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, 12)
                }
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                Divider()
                    .padding(.bottom, 1)
                
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
                LazyVStack(spacing: 0) {
                    ForEach(filteredPosts) { post in
                        PostCard(
                            post: post,
                            productManager: productManager,
                            userManager: userManager,
                            feedManager: feedManager,
                            cartManager: cartManager,
                            messageManager: messageManager
                        )
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showAddProduct) {
            AddProductView(productManager: productManager)
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
    @ObservedObject var messageManager: MessageDataManager
    
    @StateObject private var commentManager: CommentDataManager
    @State private var showProductDetail = false
    @State private var showComments = false
    @State private var showShareSheet = false
    
    init(post: Post, productManager: ProductDataManager, userManager: UserDataManager, feedManager: FeedDataManager, cartManager: CartDataManager, messageManager: MessageDataManager) {
        self.post = post
        self.productManager = productManager
        self.userManager = userManager
        self.feedManager = feedManager
        self.cartManager = cartManager
        self.messageManager = messageManager
        
        let commentMgr = CommentDataManager(userManager: userManager)
        _commentManager = StateObject(wrappedValue: commentMgr)
    }
    
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
                if let user = user {
                    UserAvatarView(user: user, size: 40)
                } else {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 40, height: 40)
                }
                
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
            
            // Enhanced Product Image
            if let product = product {
                ZStack {
                    // Product Image
                    if let firstImageURL = product.imageURLs.first {
                        GeometryReader { geometry in
                            Image(firstImageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: 400)
                                .clipped()
                        }
                        .frame(height: 400)
                        .background(Color(.systemGray6))
                    } else {
                        // Fallback gradient background if no image
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            product.category.color,
                                            product.category.color.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 400)
                            
                            Image(systemName: product.category.symbol)
                                .font(.system(size: 120, weight: .thin))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                    }
                }
                .onTapGesture {
                    showProductDetail = true
                }
                
                // Actions Bar (Instagram-style with enhanced animations)
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            feedManager.toggleLike(for: post.id)
                        }
                    }) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(post.isLiked ? .red : .primary)
                            .symbolEffect(.bounce, value: post.isLiked)
                            .scaleEffect(post.isLiked ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: post.isLiked)
                    }
                    
                    Button(action: {
                        showComments = true
                    }) {
                        Image(systemName: "message")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .hoverEffect(.lift)
                    
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "paperplane")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .hoverEffect(.lift)
                    
                    Button(action: {
                        showProductDetail = true
                    }) {
                        Image(systemName: "cart")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .hoverEffect(.lift)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cartManager.addToCart(productId: product.id, isForGift: true)
                        }
                    }) {
                        Image(systemName: "gift")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .hoverEffect(.lift)
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
                NavigationView {
                    ProductDetailView(product: product, postId: post.id, productManager: productManager, userManager: userManager, cartManager: cartManager)
                }
            }
        }
        .sheet(isPresented: $showComments) {
            NavigationView {
                CommentsView(postId: post.id, commentManager: commentManager, userManager: userManager)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            SharePostView(
                post: post,
                product: product,
                messageManager: messageManager,
                userManager: userManager
            )
        }
    }
    
}

// MARK: - Enhanced Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .symbolEffect(.bounce, value: isSelected)
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [Color.black, Color.black.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        } else {
                            LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .cornerRadius(25)
                .shadow(
                    color: isSelected ? Color.black.opacity(0.3) : Color.clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    let userMgr = UserDataManager()
    let prodMgr = ProductDataManager()
    NavigationView {
        FeedView()
            .environmentObject(userMgr)
            .environmentObject(prodMgr)
            .environmentObject(FeedDataManager(productManager: prodMgr, userManager: userMgr))
            .environmentObject(CartDataManager(productManager: prodMgr))
            .environmentObject(MessageDataManager(userManager: userMgr))
    }
}

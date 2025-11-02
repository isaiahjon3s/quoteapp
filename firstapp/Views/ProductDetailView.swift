//
//  ProductDetailView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @ObservedObject var productManager: ProductDataManager
    @ObservedObject var userManager: UserDataManager
    @ObservedObject var cartManager: CartDataManager
    
    @StateObject private var commentManager: CommentDataManager
    @State private var showComments = false
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    
    var seller: User? {
        userManager.getUser(by: product.sellerId)
    }
    
    init(product: Product, productManager: ProductDataManager, userManager: UserDataManager, cartManager: CartDataManager) {
        self.product = product
        self.productManager = productManager
        self.userManager = userManager
        self.cartManager = cartManager
        
        let commentManager = CommentDataManager(userManager: userManager)
        _commentManager = StateObject(wrappedValue: commentManager)
    }
    
    var body: some View {
        LiquidGlassBackground {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Product Images
                    TabView(selection: $selectedImageIndex) {
                        ForEach(0..<max(1, product.imageURLs.count), id: \.self) { index in
                            ZStack {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 400)
                                
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                    }
                    .frame(height: 400)
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Product Info
                        VStack(alignment: .leading, spacing: 12) {
                            // Category Badge
                            HStack {
                                Image(systemName: product.category.icon)
                                    .font(.caption)
                                Text(product.category.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.regularMaterial)
                            )
                            
                            // Title
                            Text(product.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            // Price
                            HStack(alignment: .firstTextBaseline, spacing: 12) {
                                Text("$\(product.formattedPrice)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.blue)
                                
                                if let originalPrice = product.originalPrice {
                                    Text("$\(String(format: "%.2f", originalPrice))")
                                        .font(.title3)
                                        .strikethrough()
                                        .foregroundColor(.secondary)
                                }
                                
                                if let discount = product.discountPercentage {
                                    Text("\(discount)% OFF")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(.red)
                                        )
                                }
                            }
                            
                            // Rating
                            HStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                                Text(String(format: "%.1f", product.rating))
                                    .fontWeight(.semibold)
                                Text("(\(product.reviewCount) reviews)")
                                    .foregroundColor(.secondary)
                            }
                            .font(.subheadline)
                        }
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            Text(product.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Seller Info
                        if let seller = seller {
                            NavigationLink(destination: ProfileView(user: seller, userManager: userManager, productManager: productManager)) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white.opacity(0.8))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Text(seller.displayName)
                                                .font(.headline)
                                            if seller.isVerified {
                                                Image(systemName: "checkmark.seal.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.caption)
                                            }
                                        }
                                        Text("@\(seller.username)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Divider()
                        
                        // Quantity Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantity")
                                .font(.headline)
                            HStack(spacing: 16) {
                                Button(action: {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(quantity > 1 ? .blue : .secondary)
                                }
                                
                                Text("\(quantity)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(minWidth: 40)
                                
                                Button(action: {
                                    quantity += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Tags
                        if !product.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tags")
                                    .font(.headline)
                                FlowLayout(spacing: 8) {
                                    ForEach(product.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(.regularMaterial)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            LiquidGlassButton(
                                "Add to Cart",
                                icon: "cart.fill",
                                style: .primary,
                                size: .large
                            ) {
                                cartManager.addToCart(productId: product.id, quantity: quantity)
                            }
                            
                            HStack(spacing: 12) {
                                LiquidGlassButton(
                                    "Buy Now",
                                    icon: "creditcard.fill",
                                    style: .accent,
                                    size: .large
                                ) {
                                    // In real app, would navigate to checkout
                                }
                                
                                LiquidGlassButton(
                                    "Gift",
                                    icon: "gift.fill",
                                    style: .secondary,
                                    size: .large
                                ) {
                                    cartManager.addToCart(productId: product.id, quantity: quantity, isForGift: true)
                                }
                            }
                            
                            Button(action: {
                                if cartManager.isInWishlist(productId: product.id) {
                                    cartManager.removeFromWishlist(productId: product.id)
                                } else {
                                    cartManager.addToWishlist(productId: product.id)
                                }
                            }) {
                                HStack {
                                    Image(systemName: cartManager.isInWishlist(productId: product.id) ? "heart.fill" : "heart")
                                        .foregroundColor(cartManager.isInWishlist(productId: product.id) ? .red : .secondary)
                                    Text(cartManager.isInWishlist(productId: product.id) ? "Remove from Wishlist" : "Add to Wishlist")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
            .navigationTitle(product.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showComments = true
                    }) {
                        Image(systemName: "message")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showComments) {
                CommentsView(postId: product.id, commentManager: commentManager, userManager: userManager)
            }
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? .infinity,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(
            product: Product(
                name: "Test Product",
                description: "Test description",
                price: 99.99,
                imageURLs: [],
                category: .electronics,
                sellerId: "seller1"
            ),
            productManager: ProductDataManager(),
            userManager: UserDataManager(),
            cartManager: CartDataManager(productManager: ProductDataManager())
        )
    }
}


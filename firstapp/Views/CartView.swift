//
//  CartView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var productManager: ProductDataManager
    @State private var cartManager: CartDataManager?
    @State private var selectedTab: CartTab = .cart
    
    var currentCartManager: CartDataManager {
        if let cartManager = cartManager {
            return cartManager
        }
        let manager = CartDataManager(productManager: productManager)
        cartManager = manager
        return manager
    }
    
    var body: some View {
        LiquidGlassBackground {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Cart Tab", selection: $selectedTab) {
                    Text("Cart").tag(CartTab.cart)
                    Text("Wishlist").tag(CartTab.wishlist)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Content
                if selectedTab == .cart {
                    cartContent
                } else {
                    wishlistContent
                }
            }
        }
        .navigationTitle("My Shopping")
        .onAppear {
            if cartManager == nil {
                cartManager = CartDataManager(productManager: productManager)
            }
        }
    }
    
    // MARK: - Cart Content
    private var cartContent: some View {
        Group {
            if currentCartManager.cartItems.isEmpty {
                EmptyCartView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Cart Items
                        ForEach(currentCartManager.cartItems) { item in
                            if let product = productManager.getProduct(by: item.productId) {
                                CartItemRow(
                                    item: item,
                                    product: product,
                                    cartManager: currentCartManager
                                )
                            }
                        }
                        
                        // Total
                        LiquidGlassCard(cornerRadius: 20, padding: 20) {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("$\(String(format: "%.2f", currentCartManager.totalPrice))")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                
                                LiquidGlassButton(
                                    "Checkout",
                                    icon: "creditcard.fill",
                                    style: .primary,
                                    size: .large
                                ) {
                                    // In real app, would navigate to checkout
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    // MARK: - Wishlist Content
    private var wishlistContent: some View {
        Group {
            if currentCartManager.wishlistItems.isEmpty {
                EmptyWishlistView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(currentCartManager.wishlistItems) { wishlistItem in
                            if let product = productManager.getProduct(by: wishlistItem.productId) {
                                WishlistItemRow(
                                    product: product,
                                    productManager: productManager,
                                    userManager: UserDataManager(),
                                    cartManager: currentCartManager
                                )
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

// MARK: - Cart Tab
enum CartTab {
    case cart
    case wishlist
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    let product: Product
    @ObservedObject var cartManager: CartDataManager
    
    var body: some View {
        LiquidGlassCard(padding: 0, isInteractive: true) {
            HStack(spacing: 16) {
                // Image
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: product.category.icon)
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("$\(product.formattedPrice)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    if item.isForGift {
                        HStack(spacing: 4) {
                            Image(systemName: "gift.fill")
                                .font(.caption)
                                .foregroundColor(.purple)
                            Text("Gift")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Quantity Selector
                    HStack(spacing: 12) {
                        Button(action: {
                            cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            cartManager.updateQuantity(for: item.id, quantity: item.quantity + 1)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Remove Button
                Button(action: {
                    cartManager.removeFromCart(itemId: item.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            .padding(16)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Wishlist Item Row
struct WishlistItemRow: View {
    let product: Product
    @ObservedObject var productManager: ProductDataManager
    @ObservedObject var userManager: UserDataManager
    @ObservedObject var cartManager: CartDataManager
    
    var body: some View {
        NavigationLink(destination: ProductDetailView(
            product: product,
            productManager: productManager,
            userManager: userManager,
            cartManager: cartManager
        )) {
            LiquidGlassCard(padding: 0, isInteractive: true) {
                HStack(spacing: 16) {
                    // Image
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: product.category.icon)
                                .font(.title)
                                .foregroundColor(.white.opacity(0.5))
                        )
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Text("$\(product.formattedPrice)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            cartManager.removeFromWishlist(productId: product.id)
                        }) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .padding(8)
                        }
                        
                        Button(action: {
                            cartManager.addToCart(productId: product.id)
                        }) {
                            Image(systemName: "cart.fill")
                                .foregroundColor(.blue)
                                .padding(8)
                        }
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Cart View
struct EmptyCartView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Start shopping to add items to your cart")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Empty Wishlist View
struct EmptyWishlistView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Your wishlist is empty")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Save products you love for later")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationView {
        CartView()
    }
}


//
//  CartView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject var productManager: ProductDataManager
    @EnvironmentObject var cartManager: CartDataManager
    @EnvironmentObject var userManager: UserDataManager
    @State private var selectedTab: CartTab = .cart
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("Cart Tab", selection: $selectedTab) {
                Text("Cart").tag(CartTab.cart)
                Text("Wishlist").tag(CartTab.wishlist)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Content
            if selectedTab == .cart {
                cartContent
            } else {
                wishlistContent
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("My Shopping")
    }
    
    // MARK: - Cart Content
    private var cartContent: some View {
        Group {
            if cartManager.cartItems.isEmpty {
                EmptyCartView()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        // Cart Items
                        ForEach(cartManager.cartItems) { item in
                            if let product = productManager.getProduct(by: item.productId) {
                                CartItemRow(
                                    item: item,
                                    product: product,
                                    cartManager: cartManager
                                )
                            }
                        }
                        
                        // Total
                        VStack(spacing: 16) {
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("$\(String(format: "%.2f", cartManager.totalPrice))")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                            
                            // Primary action — .glassProminent
                            Button {
                                // navigate to checkout
                            } label: {
                                Label("Checkout", systemImage: "creditcard.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.glassProminent)
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    // MARK: - Wishlist Content
    private var wishlistContent: some View {
        Group {
            if cartManager.wishlistItems.isEmpty {
                EmptyWishlistView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(cartManager.wishlistItems) { wishlistItem in
                            if let product = productManager.getProduct(by: wishlistItem.productId) {
                                WishlistItemRow(
                                    product: product,
                                    productManager: productManager,
                                    userManager: userManager,
                                    cartManager: cartManager
                                )
                            }
                        }
                    }
                    .padding(16)
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
        HStack(spacing: 12) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(product.category.color)
                    .frame(width: 80, height: 80)
                if let firstImageURL = product.imageURLs.first {
                    Image(firstImageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: product.category.symbol)
                        .font(.system(size: 32, weight: .thin))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("$\(product.formattedPrice)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                if item.isForGift {
                    HStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.purple)
                        Text("Gift")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.purple)
                    }
                }
                
                // Quantity Selector
                HStack(spacing: 12) {
                    Button(action: {
                        cartManager.updateQuantity(for: item.id, quantity: item.quantity - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(minWidth: 30)
                    
                    Button(action: {
                        cartManager.updateQuantity(for: item.id, quantity: item.quantity + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
            
            // Remove Button
            Button(action: {
                cartManager.removeFromCart(itemId: item.id)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
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
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(product.category.color)
                        .frame(width: 80, height: 80)
                    if let firstImageURL = product.imageURLs.first {
                        Image(firstImageURL)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: product.category.symbol)
                            .font(.system(size: 32, weight: .thin))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(product.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text("$\(product.formattedPrice)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        cartManager.removeFromWishlist(productId: product.id)
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                            .padding(8)
                    }
                    
                    Button(action: {
                        cartManager.addToCart(productId: product.id)
                    }) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .padding(8)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
            )
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
    let prodMgr = ProductDataManager()
    let userMgr = UserDataManager()
    NavigationView {
        CartView()
            .environmentObject(prodMgr)
            .environmentObject(CartDataManager(productManager: prodMgr))
            .environmentObject(userMgr)
    }
}


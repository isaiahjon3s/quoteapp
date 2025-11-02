//
//  SearchView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var productManager: ProductDataManager
    @EnvironmentObject var userManager: UserDataManager
    
    @State private var cartManager: CartDataManager?
    @State private var searchText = ""
    @State private var searchCategory: SearchCategory = .products
    
    var currentCartManager: CartDataManager {
        if let cartManager = cartManager {
            return cartManager
        }
        let manager = CartDataManager(productManager: productManager)
        cartManager = manager
        return manager
    }
    
    var filteredProducts: [Product] {
        productManager.searchProducts(query: searchText)
    }
    
    var filteredUsers: [User] {
        guard !searchText.isEmpty else { return [] }
        return userManager.users.filter { user in
            user.username.localizedCaseInsensitiveContains(searchText) ||
            user.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        LiquidGlassBackground {
            VStack(spacing: 0) {
                // Search Bar
                LiquidGlassTextField(
                    "Search products or users...",
                    text: $searchText,
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Category Toggle
                Picker("Search Category", selection: $searchCategory) {
                    ForEach(SearchCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Search Results
                if searchText.isEmpty {
                    // Trending/Suggestions
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Trending Products
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trending Products")
                                    .font(.headline)
                                    .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                    ForEach(productManager.products.prefix(5)) { product in
                                        TrendingProductCard(product: product, cartManager: currentCartManager)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            
                            // Categories
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Browse Categories")
                                    .font(.headline)
                                    .padding(.horizontal, 24)
                                
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(ProductCategory.allCases, id: \.self) { category in
                                        CategoryCard(category: category)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    ScrollView {
                        if searchCategory == .products {
                            if filteredProducts.isEmpty {
                                EmptyStateView(
                                    icon: "magnifyingglass",
                                    title: "No products found",
                                    message: "Try a different search term"
                                )
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredProducts) { product in
                                        ProductSearchCard(
                                            product: product,
                                            productManager: productManager,
                                            userManager: userManager,
                                            cartManager: currentCartManager
                                        )
                                    }
                                }
                                .padding(24)
                            }
                        } else {
                            if filteredUsers.isEmpty {
                                EmptyStateView(
                                    icon: "person",
                                    title: "No users found",
                                    message: "Try a different search term"
                                )
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(filteredUsers) { user in
                                        UserSearchCard(
                                            user: user,
                                            userManager: userManager
                                        )
                                    }
                                }
                                .padding(24)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search")
        .onAppear {
            if cartManager == nil {
                cartManager = CartDataManager(productManager: productManager)
            }
        }
    }
}

// MARK: - Search Category
enum SearchCategory: String, CaseIterable {
    case products = "Products"
    case users = "Users"
}

// MARK: - Trending Product Card
struct TrendingProductCard: View {
    let product: Product
    @ObservedObject var cartManager: CartDataManager
    @State private var showDetail = false
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 20, padding: 0, isInteractive: true) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 150)
                    
                    Image(systemName: product.category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text("$\(product.formattedPrice)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(12)
            }
            .frame(width: 200)
        }
        .onTapGesture {
            showDetail = true
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: ProductCategory
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 16, padding: 20, isInteractive: true) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                Text(category.rawValue)
                    .font(.headline)
            }
        }
    }
}

// MARK: - Product Search Card
struct ProductSearchCard: View {
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
                        
                        HStack {
                            Text("$\(product.formattedPrice)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            if let originalPrice = product.originalPrice {
                                Text("$\(String(format: "%.2f", originalPrice))")
                                    .font(.caption)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - User Search Card
struct UserSearchCard: View {
    let user: User
    @ObservedObject var userManager: UserDataManager
    
    var body: some View {
        NavigationLink(destination: ProfileView(
            user: user,
            userManager: userManager,
            productManager: ProductDataManager()
        )) {
            LiquidGlassCard(padding: 16, isInteractive: true) {
                HStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.8))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(user.displayName)
                                .font(.headline)
                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let bio = user.bio {
                            Text(bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

#Preview {
    NavigationView {
        SearchView()
    }
}


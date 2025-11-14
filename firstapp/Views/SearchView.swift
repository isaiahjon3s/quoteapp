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
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Search", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            
            // Category Toggle
            Picker("Search Category", selection: $searchCategory) {
                ForEach(SearchCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .background(Color(.systemBackground))
            
            Divider()
            
            // Search Results
            if searchText.isEmpty {
                // Trending/Suggestions
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Trending Products
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trending Products")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(productManager.products.prefix(5)) { product in
                                        TrendingProductCard(product: product, cartManager: currentCartManager)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // Categories
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Browse Categories")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(ProductCategory.allCases, id: \.self) { category in
                                    CategoryCard(category: category)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 16)
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
                            LazyVStack(spacing: 12) {
                                ForEach(filteredProducts) { product in
                                    ProductSearchCard(
                                        product: product,
                                        productManager: productManager,
                                        userManager: userManager,
                                        cartManager: currentCartManager
                                    )
                                }
                            }
                            .padding(16)
                        }
                    } else {
                        if filteredUsers.isEmpty {
                            EmptyStateView(
                                icon: "person",
                                title: "No users found",
                                message: "Try a different search term"
                            )
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredUsers) { user in
                                    UserSearchCard(
                                        user: user,
                                        userManager: userManager
                                    )
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
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
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryColor(for: product.category))
                    .frame(width: 160, height: 160)
                
                Image(systemName: categorySymbol(for: product.category))
                    .font(.system(size: 60, weight: .thin))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text("$\(product.formattedPrice)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.top, 8)
            .frame(width: 160, alignment: .leading)
        }
        .onTapGesture {
            showDetail = true
        }
    }
    
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

// MARK: - Category Card
struct CategoryCard: View {
    let category: ProductCategory
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(categoryColor(for: category))
                .cornerRadius(10)
            
            Text(category.rawValue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
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
            HStack(spacing: 12) {
                // Image
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryColor(for: product.category))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: categorySymbol(for: product.category))
                            .font(.system(size: 32, weight: .thin))
                            .foregroundColor(.white.opacity(0.8))
                    )
                
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
                    
                    HStack(spacing: 6) {
                        Text("$\(product.formattedPrice)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        if let originalPrice = product.originalPrice {
                            Text("$\(String(format: "%.2f", originalPrice))")
                                .font(.system(size: 13))
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
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
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 22, weight: .medium))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                        }
                    }
                    
                    Text("@\(user.username)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if let bio = user.bio {
                        Text(bio)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
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


//
//  ContentView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// Tab enum for navigation
enum AppTab: String, CaseIterable {
    case feed = "house.fill"
    case search = "magnifyingglass"
    case cart = "cart.fill"
    case messages = "message.fill"
    case profile = "person.fill"
    
    var title: String {
        switch self {
        case .feed: return "Feed"
        case .search: return "Search"
        case .cart: return "Cart"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }
}

struct ContentView: View {
    @StateObject private var userManager: UserDataManager
    @StateObject private var productManager: ProductDataManager
    @StateObject private var feedManager: FeedDataManager
    @StateObject private var cartManager: CartDataManager
    @StateObject private var messageManager: MessageDataManager
    @StateObject private var notificationManager = NotificationManager()
    @State private var selectedTab: AppTab = .feed
    
    init() {
        let userMgr = UserDataManager()
        let prodMgr = ProductDataManager()
        let feedMgr = FeedDataManager(productManager: prodMgr, userManager: userMgr)
        let cartMgr = CartDataManager(productManager: prodMgr)
        let msgMgr = MessageDataManager(userManager: userMgr)
        
        _userManager = StateObject(wrappedValue: userMgr)
        _productManager = StateObject(wrappedValue: prodMgr)
        _feedManager = StateObject(wrappedValue: feedMgr)
        _cartManager = StateObject(wrappedValue: cartMgr)
        _messageManager = StateObject(wrappedValue: msgMgr)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area — all tabs share the same manager instances via environment
            Group {
                switch selectedTab {
                case .feed:
                    NavigationView {
                        FeedView()
                    }
                    .environmentObject(userManager)
                    .environmentObject(productManager)
                    .environmentObject(feedManager)
                    .environmentObject(cartManager)
                    .environmentObject(messageManager)
                case .search:
                    NavigationView {
                        SearchView()
                    }
                    .environmentObject(userManager)
                    .environmentObject(productManager)
                    .environmentObject(cartManager)
                    .environmentObject(messageManager)
                case .cart:
                    NavigationView {
                        CartView()
                    }
                    .environmentObject(productManager)
                    .environmentObject(cartManager)
                    .environmentObject(userManager)
                case .messages:
                    NavigationView {
                        MessagesView(
                            messageManager: messageManager,
                            userManager: userManager
                        )
                    }
                    .environmentObject(productManager)
                case .profile:
                    NavigationView {
                        if let currentUser = userManager.currentUser {
                            ProfileView(
                                user: currentUser,
                                userManager: userManager,
                                productManager: productManager,
                                messageManager: messageManager
                            )
                        } else {
                            Text("No user found")
                                .foregroundColor(.secondary)
                        }
                    }
                    .environmentObject(feedManager)
                    .environmentObject(cartManager)
                    .environmentObject(userManager)
                    .environmentObject(productManager)
                    .environmentObject(messageManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            
            // Liquid Glass Tab Bar
            LiquidGlassTabBar(selectedTab: $selectedTab, unreadCount: messageManager.getTotalUnreadCount())
        }
    }
}

// MARK: - Apple Liquid Glass Tab Bar (iOS 26)
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: AppTab
    let unreadCount: Int
    @Namespace private var glassNamespace
    
    var body: some View {
        // GlassEffectContainer allows multiple glass elements to share the same
        // background sampling region — required when nesting glass inside glass
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            // The entire tab bar pill — one glass element
            .glassEffect(.regular, in: .rect(cornerRadius: 28, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.bouncy(duration: 0.3)) {
                selectedTab = tab
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                        .symbolEffect(.bounce, value: selectedTab == tab)
                        .frame(width: 26, height: 26)
                    
                    if tab == .messages && unreadCount > 0 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -2)
                    }
                }
                
                Text(tab.title)
                    .font(.system(size: 9.5, weight: selectedTab == tab ? .semibold : .regular))
            }
            .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            // Per-tab glass selection indicator — morphs between tabs via glassEffectID
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                        .glassEffect(
                            .regular.interactive(),
                            in: .rect(cornerRadius: 16, style: .continuous)
                        )
                        .glassEffectID("tab_selection", in: glassNamespace)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}

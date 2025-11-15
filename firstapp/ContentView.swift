//
//  ContentView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userManager = UserDataManager()
    @StateObject private var productManager = ProductDataManager()
    @StateObject private var messageManager: MessageDataManager
    @StateObject private var notificationManager = NotificationManager()
    @State private var selectedTab = 0
    
    init() {
        let userMgr = UserDataManager()
        let prodMgr = ProductDataManager()
        let msgMgr = MessageDataManager(userManager: userMgr)
        
        _userManager = StateObject(wrappedValue: userMgr)
        _productManager = StateObject(wrappedValue: prodMgr)
        _messageManager = StateObject(wrappedValue: msgMgr)
    }
    
    let tabs = [
        LiquidGlassTabItem(title: "Feed", icon: "house.fill", accent: .blue),
        LiquidGlassTabItem(title: "Search", icon: "magnifyingglass", accent: .green),
        LiquidGlassTabItem(title: "Messages", icon: "message.fill", accent: .pink),
        LiquidGlassTabItem(title: "Cart", icon: "cart.fill", accent: .orange),
        LiquidGlassTabItem(title: "Profile", icon: "person.fill", accent: .purple)
    ]
    
    var body: some View {
        NavigationView {
            LiquidGlassTabView(
                selectedTab: selectedTab,
                onTabSelected: { selectedTab = $0 },
                tabs: tabs
            ) {
                Group {
                    switch selectedTab {
                    case 0:
                        FeedView()
                            .environmentObject(userManager)
                            .environmentObject(productManager)
                    case 1:
                        SearchView()
                            .environmentObject(userManager)
                            .environmentObject(productManager)
                    case 2:
                        MessagesView(
                            messageManager: messageManager,
                            userManager: userManager
                        )
                        .overlay(
                            messageManager.getTotalUnreadCount() > 0 ?
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Text("\(messageManager.getTotalUnreadCount())")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 150, y: -400)
                                : nil
                        )
                    case 3:
                        CartView()
                            .environmentObject(productManager)
                    case 4:
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
                    default:
                        FeedView()
                            .environmentObject(userManager)
                            .environmentObject(productManager)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    ContentView()
}

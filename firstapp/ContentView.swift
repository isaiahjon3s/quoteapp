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
    @State private var selectedTab = 0
    
    let tabs = [
        LiquidGlassTabItem(title: "Feed", icon: "house.fill", accent: .blue),
        LiquidGlassTabItem(title: "Search", icon: "magnifyingglass", accent: .green),
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
                        CartView()
                            .environmentObject(productManager)
                    case 3:
                        if let currentUser = userManager.currentUser {
                            ProfileView(
                                user: currentUser,
                                userManager: userManager,
                                productManager: productManager
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

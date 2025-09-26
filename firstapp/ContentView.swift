//
//  ContentView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        LiquidGlassTabView(
            selectedTab: selectedTab,
            onTabSelected: { selectedTab = $0 },
            tabs: [
                LiquidGlassTabView.TabItem(title: "Feed", icon: "quote.bubble.fill", accent: .cyan),
                LiquidGlassTabView.TabItem(title: "Profile", icon: "person.fill", accent: .purple)
            ]
        ) {
            switch selectedTab {
            case 0:
                QuoteFeedView()
            case 1:
                MyProfileRootView()
            default:
                QuoteFeedView()
            }
        }
    }
}

private struct MyProfileRootView: View {
    @StateObject private var dataManager = QuoteDataManager()
    
    var body: some View {
        NavigationView {
            if let me = dataManager.currentUser {
                ProfileQuotesView(profile: me, dataManager: dataManager)
            } else {
                LiquidGlassBackground {
                    Text("No profile available")
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Profile")
            }
        }
    }
}

#Preview {
    ContentView()
}

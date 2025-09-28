//
//  ContentView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSearch = false
    
    var body: some View {
        LiquidGlassBackground {
            ZStack(alignment: .bottom) {
                Group {
            switch selectedTab {
            case 0:
                QuoteFeedView()
            case 1:
                MyProfileRootView()
            default:
                QuoteFeedView()
            }
                }
                .padding(.bottom, 100)
                
                LiquidGlassMenuBarWithSearch(
                    tabs: [
                        LiquidGlassTabItem(title: "Home", icon: "leaf.fill"),
                        LiquidGlassTabItem(title: "All", icon: "line.3.horizontal")
                    ],
                    selectedIndex: $selectedTab,
                    searchPlaceholder: "Search",
                    searchText: Binding(get: { "" }, set: { _ in }),
                    onSearchTap: {
                        showSearch = true
                    }
                )
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 32, trailing: 24))
            }
        }
        .sheet(isPresented: $showSearch) {
            NavigationView {
                Text("Search coming soon")
                    .navigationTitle("Search")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { showSearch = false }
                        }
                    }
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

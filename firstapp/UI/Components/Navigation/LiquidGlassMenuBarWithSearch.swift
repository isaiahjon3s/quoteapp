//
//  LiquidGlassMenuBarWithSearch.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Menu Bar with Search Component
// This is a specialized menu bar that combines tab navigation with a search button.
// It's designed for the bottom of the screen and provides easy access to search functionality.

struct LiquidGlassMenuBarWithSearch: View {
    // MARK: - Properties
    let tabs: [LiquidGlassTabItem]  // Array of tab items
    @Binding var selectedIndex: Int // Currently selected tab index
    let searchPlaceholder: String   // Placeholder text for search
    @Binding var searchText: String // Search text (two-way binding)
    let onSearchTap: () -> Void     // Callback when search button is tapped
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Tab strip
            LiquidGlassTabViewTabStrip(
                tabs: tabs,
                selectedIndex: $selectedIndex
            )
            
            // Search button
            Button(action: onSearchTap) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Liquid Glass Tab View Tab Strip
// This is the internal tab strip component used by the menu bar.

private struct LiquidGlassTabViewTabStrip: View {
    // MARK: - Properties
    let tabs: [LiquidGlassTabItem]  // Array of tab items
    @Binding var selectedIndex: Int // Currently selected tab index
    
    // MARK: - State
    @Namespace private var namespace  // For smooth indicator animation
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    // Don't trigger if already selected
                    guard selectedIndex != index else { return }
                    
                    // Animate tab selection
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedIndex = index
                    }
                } label: {
                    HStack(spacing: 8) {
                        // Tab icon
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))
                        
                        // Tab title
                        Text(tab.title)
                            .font(.footnote.weight(.semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .foregroundStyle(selectedIndex == index ? tab.accent : .secondary)
                    .background(
                        Group {
                            if selectedIndex == index {
                                // Selected tab background
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(tab.accent.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .stroke(tab.accent.opacity(0.35), lineWidth: 1)
                                    )
                                    .matchedGeometryEffect(id: "activeSegment", in: namespace)
                            } else {
                                // Unselected tab background
                                Color.clear
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            // Tab strip background
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassMenuBarWithSearch:
 
 1. Basic Menu Bar:
    @State private var selectedTab = 0
    @State private var searchText = ""
    @State private var showingSearchSheet = false
    
    let tabs = [
        LiquidGlassTabItem(title: "Home", icon: "house.fill", accent: .blue),
        LiquidGlassTabItem(title: "Profile", icon: "person.fill", accent: .purple)
    ]
    
    LiquidGlassMenuBarWithSearch(
        tabs: tabs,
        selectedIndex: $selectedTab,
        searchPlaceholder: "Search...",
        searchText: $searchText,
        onSearchTap: {
            showingSearchSheet = true
        }
    )
 
 2. In ContentView:
    struct ContentView: View {
        @State private var selectedTab = 0
        @State private var searchText = ""
        @State private var showingSearchSheet = false
        
        var body: some View {
            ZStack(alignment: .bottom) {
                // Main content
                Group {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: ProfileView()
                    default: HomeView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                
                // Menu bar
                LiquidGlassMenuBarWithSearch(
                    tabs: [
                        LiquidGlassTabItem(title: "Home", icon: "house.fill", accent: .blue),
                        LiquidGlassTabItem(title: "Profile", icon: "person.fill", accent: .purple)
                    ],
                    selectedIndex: $selectedTab,
                    searchPlaceholder: "Search quotes...",
                    searchText: $searchText,
                    onSearchTap: {
                        showingSearchSheet = true
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .sheet(isPresented: $showingSearchSheet) {
                SearchView(searchText: $searchText)
            }
        }
    }
 
 3. With Custom Styling:
    LiquidGlassMenuBarWithSearch(
        tabs: tabs,
        selectedIndex: $selectedTab,
        searchPlaceholder: "Search...",
        searchText: $searchText,
        onSearchTap: {
            // Custom search action
        }
    )
    .padding(.horizontal, 20)
    .padding(.bottom, 20)
*/

// MARK: - Design Notes
/*
 MENU BAR WITH SEARCH DESIGN PRINCIPLES:
 
 1. LAYOUT:
    - Horizontal layout with tabs and search button
    - Tabs take up most of the space
    - Search button is compact and accessible
    - Consistent spacing and alignment
 
 2. TAB STRIP:
    - Smooth selection animation
    - Clear visual feedback
    - Matched geometry effect for indicator
    - Responsive to different tab counts
 
 3. SEARCH BUTTON:
    - Circular design for easy tapping
    - Clear magnifying glass icon
    - Subtle shadow and border
    - Consistent with tab styling
 
 4. INTERACTION:
    - Smooth animations
    - Clear selection states
    - Easy access to search
    - Intuitive navigation
 
 5. CUSTOMIZATION:
    - Flexible tab configuration
    - Custom colors and icons
    - Adjustable spacing
    - Liquid Glass effects
*/

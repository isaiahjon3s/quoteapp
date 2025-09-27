//
//  LiquidGlassMenuBar.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Menu Bar Component
// This is a comprehensive menu bar that combines search, filtering, and action buttons.
// It provides a complete interface for content discovery and management.

struct LiquidGlassMenuBar: View {
    // MARK: - Properties
    @Binding var searchText: String      // Search text (two-way binding)
    @Binding var threshold: Double       // Filter threshold (two-way binding)
    let highlightedTags: [String]        // Tags to highlight
    let activeTag: String?               // Currently selected tag
    let suggestions: [String]            // Search suggestions
    let onSubmitSearch: () -> Void       // Callback when search is submitted
    let onClearFilters: () -> Void       // Callback when filters are cleared
    let onCreate: () -> Void             // Callback when create button is tapped
    let onSelectTag: (String?) -> Void   // Callback when tag is selected
    let sliderRange: ClosedRange<Double> // Range for the threshold slider
    let sliderStep: Double               // Step size for the slider
    let sliderLabel: String              // Label for the slider
    let sliderIcon: String               // Icon for the slider
    let sliderUnit: String?              // Unit for the slider value
    let sliderAccent: Color              // Accent color for the slider
    let actionTitle: String              // Title for the action button
    let actionIcon: String               // Icon for the action button
    let actionStyle: LiquidGlassButton.ButtonStyle  // Style for the action button
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Menu Bar
    /// - Parameters:
    ///   - searchText: Binding to the search text
    ///   - threshold: Binding to the filter threshold
    ///   - highlightedTags: Tags to highlight (default: [])
    ///   - activeTag: Currently selected tag (default: nil)
    ///   - suggestions: Search suggestions (default: [])
    ///   - sliderRange: Range for the threshold slider
    ///   - sliderStep: Step size for the slider (default: 1)
    ///   - sliderLabel: Label for the slider
    ///   - sliderIcon: Icon for the slider
    ///   - sliderUnit: Unit for the slider value (default: nil)
    ///   - sliderAccent: Accent color for the slider (default: .purple)
    ///   - actionTitle: Title for the action button
    ///   - actionIcon: Icon for the action button
    ///   - actionStyle: Style for the action button (default: .accent)
    ///   - onSubmitSearch: Callback when search is submitted (default: {})
    ///   - onClearFilters: Callback when filters are cleared (default: {})
    ///   - onCreate: Callback when create button is tapped (default: {})
    ///   - onSelectTag: Callback when tag is selected (default: { _ in })
    init(
        searchText: Binding<String>,
        threshold: Binding<Double>,
        highlightedTags: [String] = [],
        activeTag: String? = nil,
        suggestions: [String] = [],
        sliderRange: ClosedRange<Double>,
        sliderStep: Double = 1,
        sliderLabel: String,
        sliderIcon: String,
        sliderUnit: String? = nil,
        sliderAccent: Color = .purple,
        actionTitle: String,
        actionIcon: String,
        actionStyle: LiquidGlassButton.ButtonStyle = .accent,
        onSubmitSearch: @escaping () -> Void = {},
        onClearFilters: @escaping () -> Void = {},
        onCreate: @escaping () -> Void = {},
        onSelectTag: @escaping (String?) -> Void = { _ in }
    ) {
        self._searchText = searchText
        self._threshold = threshold
        self.highlightedTags = highlightedTags
        self.activeTag = activeTag
        self.suggestions = suggestions
        self.onSubmitSearch = onSubmitSearch
        self.onClearFilters = onClearFilters
        self.onCreate = onCreate
        self.onSelectTag = onSelectTag
        self.sliderRange = sliderRange
        self.sliderStep = sliderStep
        self.sliderLabel = sliderLabel
        self.sliderIcon = sliderIcon
        self.sliderUnit = sliderUnit
        self.sliderAccent = sliderAccent
        self.actionTitle = actionTitle
        self.actionIcon = actionIcon
        self.actionStyle = actionStyle
    }
    
    // MARK: - Body
    var body: some View {
        LiquidGlassCard(cornerRadius: 32, padding: 22) {
            VStack(spacing: 18) {
                // Search field
                LiquidGlassSearchField(
                    placeholder: "Search",
                    text: $searchText,
                    icon: "magnifyingglass",
                    suggestions: suggestions,
                    onSubmit: onSubmitSearch,
                    onClear: onClearFilters
                )
                
                // Tag pills (if any)
                if !highlightedTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            // "All" tag
                            LiquidGlassTagPill(title: "All", isSelected: activeTag == nil) {
                                onSelectTag(nil)
                            }
                            
                            // Individual tags
                            ForEach(highlightedTags.unique(), id: \.self) { tag in
                                LiquidGlassTagPill(title: "#\(tag)", isSelected: activeTag == tag) {
                                    onSelectTag(tag)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                // Threshold slider
                LiquidGlassSlider(
                    label: sliderLabel,
                    value: $threshold,
                    range: sliderRange,
                    step: sliderStep,
                    leadingIcon: sliderIcon,
                    unit: sliderUnit,
                    accent: sliderAccent
                )
                
                // Action buttons
                HStack(spacing: 12) {
                    // Clear filters button
                    LiquidGlassButton("Clear Filters", icon: "line.3.horizontal.decrease.circle", style: .secondary) {
                        onClearFilters()
                    }
                    
                    Spacer()
                    
                    // Create button
                    LiquidGlassButton(actionTitle, icon: actionIcon, style: actionStyle) {
                        onCreate()
                    }
                }
            }
        }
    }
}

// MARK: - Liquid Glass Tag Pill Component
// This is a small pill-shaped button for displaying and selecting tags.

struct LiquidGlassTagPill: View {
    // MARK: - Properties
    let title: String      // Text to display on the pill
    let isSelected: Bool   // Whether the pill is selected
    let action: () -> Void // Action to perform when tapped
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(
                                    Color.white.opacity(isSelected ? 0.5 : 0.25),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .foregroundColor(isSelected ? .white : .primary)
                .shadow(
                    color: Color.black.opacity(isSelected ? 0.18 : 0.08),
                    radius: isSelected ? 12 : 6,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Array Extension for Unique Elements
private extension Array where Element: Hashable {
    /// Returns an array with only unique elements
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassMenuBar:
 
 1. Basic Menu Bar:
    @State private var searchText = ""
    @State private var threshold: Double = 0
    
    LiquidGlassMenuBar(
        searchText: $searchText,
        threshold: $threshold,
        sliderRange: 0...100,
        sliderLabel: "Minimum likes",
        sliderIcon: "hand.thumbsup.fill",
        actionTitle: "New Quote",
        actionIcon: "plus"
    )
 
 2. With Tags and Suggestions:
    @State private var searchText = ""
    @State private var threshold: Double = 50
    @State private var selectedTag: String? = nil
    
    let tags = ["inspiration", "motivation", "success"]
    let suggestions = ["daily", "work", "life"]
    
    LiquidGlassMenuBar(
        searchText: $searchText,
        threshold: $threshold,
        highlightedTags: tags,
        activeTag: selectedTag,
        suggestions: suggestions,
        sliderRange: 0...100,
        sliderStep: 5,
        sliderLabel: "Minimum likes",
        sliderIcon: "hand.thumbsup.fill",
        sliderUnit: "likes",
        sliderAccent: .pink,
        actionTitle: "Create Quote",
        actionIcon: "sparkles",
        actionStyle: .accent,
        onSubmitSearch: {
            performSearch()
        },
        onClearFilters: {
            searchText = ""
            threshold = 0
            selectedTag = nil
        },
        onCreate: {
            showCreateSheet = true
        },
        onSelectTag: { tag in
            selectedTag = tag
        }
    )
 
 3. In a ScrollView:
    ScrollView {
        VStack(spacing: 20) {
            // Content
            ForEach(items) { item in
                ItemView(item)
            }
            
            // Menu bar at bottom
            LiquidGlassMenuBar(
                searchText: $searchText,
                threshold: $threshold,
                sliderRange: 0...100,
                sliderLabel: "Filter",
                sliderIcon: "slider.horizontal.3",
                actionTitle: "Add",
                actionIcon: "plus"
            )
        }
    }
*/

// MARK: - Design Notes
/*
 MENU BAR DESIGN PRINCIPLES:
 
 1. LAYOUT:
    - Vertical stack of components
    - Consistent spacing
    - Responsive to content
    - Clear visual hierarchy
 
 2. FUNCTIONALITY:
    - Search with suggestions
    - Tag filtering
    - Threshold filtering
    - Action buttons
    - Clear filters option
 
 3. INTERACTION:
    - Smooth animations
    - Clear feedback
    - Intuitive controls
    - Accessible design
 
 4. CUSTOMIZATION:
    - Flexible configuration
    - Custom colors and icons
    - Optional components
    - Liquid Glass parameters
 
 5. ACCESSIBILITY:
    - Clear labels
    - Appropriate contrast
    - VoiceOver support
    - Keyboard navigation
*/

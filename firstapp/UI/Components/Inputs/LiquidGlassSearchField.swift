//
//  LiquidGlassSearchField.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Search Field Component
// This is a specialized text field for search functionality with suggestions and keyboard toolbar.

struct LiquidGlassSearchField: View {
    // MARK: - Properties
    @Binding var text: String        // The search text (two-way binding)
    let placeholder: String          // Placeholder text
    let icon: String                 // SF Symbol icon
    let suggestions: [String]        // Search suggestions
    let onSubmit: () -> Void         // Callback when search is submitted
    let onClear: () -> Void          // Callback when search is cleared
    
    // MARK: - State
    @FocusState private var isFocused: Bool  // Focus state for the text field
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Search Field
    /// - Parameters:
    ///   - placeholder: Placeholder text
    ///   - text: Binding to the search text
    ///   - icon: SF Symbol icon name (default: "magnifyingglass")
    ///   - suggestions: Array of search suggestions (default: [])
    ///   - onSubmit: Callback when search is submitted (default: {})
    ///   - onClear: Callback when search is cleared (default: {})
    init(
        placeholder: String,
        text: Binding<String>,
        icon: String = "magnifyingglass",
        suggestions: [String] = [],
        onSubmit: @escaping () -> Void = {},
        onClear: @escaping () -> Void = {}
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.suggestions = suggestions
        self.onSubmit = onSubmit
        self.onClear = onClear
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            // Search icon
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundColor(isFocused ? .blue : .secondary)
                .padding(.leading, 4)
            
            // Text field
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textInputAutocapitalization(.never)  // Don't capitalize search terms
                .disableAutocorrection(true)          // Don't auto-correct search terms
                .submitLabel(.search)                 // Show search button on keyboard
                .onSubmit {
                    onSubmit()  // Call submit callback
                }
            
            // Clear button (only shown when there's text)
            if !text.isEmpty {
                Button {
                    text = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            // Search field background
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            Color.white.opacity(isFocused ? 0.45 : 0.25),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
                .shadow(
                    color: .black.opacity(0.15),
                    radius: isFocused ? 18 : 10,
                    x: 0,
                    y: 10
                )
        )
        // Apply the Liquid Glass effect
        .liquidGlass(blur: 0.6, reflection: 0.5, motionSensitivity: 0.8)
        .padding(.horizontal, -4)
        .toolbar {
            // Keyboard toolbar with suggestions
            ToolbarItem(placement: .keyboard) {
                LiquidGlassKeyboardToolbar(
                    suggestions: suggestions,
                    onSuggestion: { suggestion in
                        text = suggestion
                        onSubmit()
                        isFocused = false
                    },
                    onDismiss: {
                        isFocused = false
                    }
                )
            }
        }
    }
}

// MARK: - Liquid Glass Keyboard Toolbar
// This provides search suggestions above the keyboard

struct LiquidGlassKeyboardToolbar: View {
    // MARK: - Properties
    let suggestions: [String]        // Array of suggestions
    let onSuggestion: (String) -> Void  // Callback when suggestion is tapped
    let onDismiss: () -> Void        // Callback when keyboard is dismissed
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            // Suggestions scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions.unique(), id: \.self) { suggestion in
                        Button {
                            onSuggestion(suggestion)
                        } label: {
                            Text("#\(suggestion)")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color.blue.opacity(0.18))
                                )
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 6)
            }
            
            // Dismiss keyboard button
            Button(action: onDismiss) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            // Toolbar background
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        // Apply the Liquid Glass effect
        .liquidGlass(blur: 0.5, reflection: 0.35, motionSensitivity: 0.5)
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
 HOW TO USE LiquidGlassSearchField:
 
 1. Basic Search Field:
    @State private var searchText = ""
    LiquidGlassSearchField(
        placeholder: "Search...",
        text: $searchText
    )
 
 2. With Suggestions:
    @State private var searchText = ""
    let suggestions = ["apple", "banana", "cherry"]
    
    LiquidGlassSearchField(
        placeholder: "Search fruits...",
        text: $searchText,
        suggestions: suggestions,
        onSubmit: {
            // Handle search submission
        }
    )
 
 3. Custom Icon and Callbacks:
    LiquidGlassSearchField(
        placeholder: "Search users...",
        text: $searchText,
        icon: "person.circle",
        suggestions: userSuggestions,
        onSubmit: {
            performSearch()
        },
        onClear: {
            clearSearch()
        }
    )
 
 4. In a Navigation View:
    NavigationView {
        VStack {
            LiquidGlassSearchField(
                placeholder: "Search...",
                text: $searchText,
                suggestions: suggestions
            )
            .padding()
            
            // Search results
            List(searchResults) { result in
                Text(result.title)
            }
        }
    }
*/

// MARK: - Design Notes
/*
 SEARCH FIELD DESIGN PRINCIPLES:
 
 1. VISUAL FEEDBACK:
    - Clear focus states
    - Dynamic border and shadow
    - Icon color changes
    - Smooth transitions
 
 2. FUNCTIONALITY:
    - Search-specific keyboard settings
    - Clear button when text is present
    - Submit handling
    - Suggestion support
 
 3. ACCESSIBILITY:
    - Clear placeholder text
    - Appropriate contrast ratios
    - VoiceOver support
    - Keyboard navigation
 
 4. CUSTOMIZATION:
    - Custom icons
    - Suggestion support
    - Callback handling
    - Liquid Glass parameters
 
 5. KEYBOARD INTEGRATION:
    - Custom toolbar
    - Suggestion pills
    - Dismiss button
    - Smooth animations
*/

//
//  LiquidGlassTextField.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Text Field Component
// This is a customizable text input field that uses the Liquid Glass design system.
// It provides focus states, icons, and secure text entry options.

struct LiquidGlassTextField: View {
    // MARK: - Properties
    @Binding var text: String          // The text content (two-way binding)
    let placeholder: String            // Placeholder text to show when empty
    let icon: String?                  // Optional SF Symbol icon
    let isSecure: Bool                 // Whether to use secure text entry
    let blur: CGFloat                  // Liquid Glass blur intensity
    let reflection: CGFloat            // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat     // Liquid Glass motion sensitivity
    
    // MARK: - State
    @State private var isFocused = false        // Tracks if the field is focused
    @FocusState private var isTextFieldFocused: Bool  // SwiftUI focus state
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Text Field
    /// - Parameters:
    ///   - placeholder: Placeholder text to show when empty
    ///   - text: Binding to the text content
    ///   - icon: Optional SF Symbol icon name
    ///   - isSecure: Whether to use secure text entry (default: false)
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Icon (if provided)
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .blue : .gray)  // Color changes when focused
                    .font(.body.weight(.medium))
                    .symbolEffect(.bounce, value: isFocused)     // Bounce animation when focused
            }
            
            // Text input field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)  // Secure text entry
                } else {
                    TextField(placeholder, text: $text)    // Regular text entry
                }
            }
            .focused($isTextFieldFocused)  // Connect to focus state
            .font(.body)
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)  // Horizontal padding
        .padding(.vertical, 16)    // Vertical padding
        .background(
            // Translucent background
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20)
        )
        .overlay(
            // Dynamic border that changes when focused
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isFocused ? .blue : .white.opacity(0.3),  // Blue when focused, white when not
                    lineWidth: isFocused ? 2.0 : 1.0         // Thicker border when focused
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            // Dynamic shadow that changes when focused
            color: isFocused ? .blue.opacity(0.2) : .black.opacity(0.1),
            radius: isFocused ? 15 : 10,
            x: 0,
            y: isFocused ? 8 : 5
        )
        .onChange(of: isTextFieldFocused) { _, newValue in
            // Animate focus state changes
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                isFocused = newValue
            }
        }
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassTextField:
 
 1. Basic Text Field:
    @State private var username = ""
    LiquidGlassTextField("Enter username", text: $username)
 
 2. Text Field with Icon:
    @State private var email = ""
    LiquidGlassTextField("Enter email", text: $email, icon: "envelope")
 
 3. Password Field:
    @State private var password = ""
    LiquidGlassTextField("Enter password", text: $password, isSecure: true, icon: "lock")
 
 4. Custom Styling:
    @State private var searchText = ""
    LiquidGlassTextField(
        "Search...",
        text: $searchText,
        icon: "magnifyingglass",
        blur: 0.8,
        reflection: 0.5
    )
 
 5. In a Form:
    VStack(spacing: 16) {
        LiquidGlassTextField("First Name", text: $firstName, icon: "person")
        LiquidGlassTextField("Last Name", text: $lastName, icon: "person")
        LiquidGlassTextField("Email", text: $email, icon: "envelope")
        LiquidGlassTextField("Password", text: $password, isSecure: true, icon: "lock")
    }
*/

// MARK: - Design Notes
/*
 TEXT FIELD DESIGN PRINCIPLES:
 
 1. FOCUS STATES:
    - Clear visual feedback when focused
    - Border color changes to blue
    - Border thickness increases
    - Shadow becomes more prominent
    - Icon color changes to blue
 
 2. ACCESSIBILITY:
    - Clear placeholder text
    - Appropriate contrast ratios
    - Support for VoiceOver
    - Keyboard types can be customized
 
 3. SECURITY:
    - Secure text entry option
    - Text is hidden for passwords
    - Uses system security features
 
 4. CUSTOMIZATION:
    - Optional icons for context
    - Customizable Liquid Glass parameters
    - Flexible placeholder text
    - Two-way data binding
 
 5. ANIMATIONS:
    - Smooth focus transitions
    - Icon bounce effects
    - Spring animations for natural feel
*/

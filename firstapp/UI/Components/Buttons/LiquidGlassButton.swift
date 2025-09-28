//
//  LiquidGlassButton.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Button Component
// This is a customizable button that uses the Liquid Glass design system.
// It provides different styles, sizes, and visual effects.

struct LiquidGlassButton: View {
    // MARK: - Properties
    let title: String              // Text to display on the button
    let icon: String?              // Optional SF Symbol icon
    let action: () -> Void         // Action to perform when tapped
    let style: ButtonStyle         // Visual style of the button
    let size: ButtonSize           // Size of the button
    let blur: CGFloat              // Liquid Glass blur intensity
    let reflection: CGFloat        // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat // Liquid Glass motion sensitivity
    
    // MARK: - State
    @State private var isPressed = false  // Tracks if the button is being pressed
    
    // MARK: - Button Styles
    /// Different visual styles for the button
    enum ButtonStyle {
        case primary      // System blue color scheme
        case secondary    // System gray color scheme
        case accent       // System accent color scheme
        case destructive  // System red color scheme
        case ghost        // Transparent with primary text
    }
    
    // MARK: - Button Sizes
    /// Different sizes for the button
    enum ButtonSize {
        case small
        case medium
        case large
        
        /// Padding for each size
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .medium: return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            case .large: return EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)
            }
        }
        
        /// Font for each size
        var font: Font {
            switch self {
            case .small: return .caption.weight(.bold)
            case .medium: return .body.weight(.bold)
            case .large: return .title3.weight(.bold)
            }
        }
        
        /// Corner radius for each size
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Button
    /// - Parameters:
    ///   - title: Text to display on the button
    ///   - icon: Optional SF Symbol icon name
    ///   - style: Visual style of the button (default: .primary)
    ///   - size: Size of the button (default: .medium)
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    ///   - action: Action to perform when tapped
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon (if provided)
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.font)
                        .symbolEffect(.bounce, value: isPressed)  // Bounce animation when pressed
                }
                
                // Title text
                Text(title)
                    .font(size.font)
            }
            .foregroundColor(textColor)  // Color based on button style
            .padding(size.padding)       // Padding based on button size
            .background(
                // Use solid colors for primary, accent, and destructive
                backgroundColor,
                in: RoundedRectangle(cornerRadius: size.cornerRadius)
            )
            .overlay(
                // Subtle border for definition
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(style == .ghost ? Color.clear : Color.white.opacity(0.2), lineWidth: style == .ghost ? 0 : 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        }
        .buttonStyle(PlainButtonStyle())  // Remove default button styling
        .scaleEffect(isPressed ? 0.94 : 1.0)  // Press animation
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing  // Track press state
        }, perform: {})
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
    
    // MARK: - Computed Properties
    /// Returns the appropriate text color based on button style
    private var textColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .primary
        case .accent: return .white
        case .destructive: return .white
        case .ghost: return .primary
        }
    }
    
    /// Returns the appropriate background color based on button style
    private var backgroundColor: Color {
        switch style {
        case .primary: return .blue
        case .secondary: return Color(.systemGray5)
        case .accent: return .accentColor
        case .destructive: return .red
        case .ghost: return .clear
        }
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassButton:
 
 1. Basic Button:
    LiquidGlassButton("Save") {
        // Save action
    }
 
 2. Button with Icon:
    LiquidGlassButton("Add Item", icon: "plus") {
        // Add action
    }
 
 3. Different Styles:
    LiquidGlassButton("Delete", style: .destructive) {
        // Delete action
    }
 
    LiquidGlassButton("Cancel", style: .secondary) {
        // Cancel action
    }
 
 4. Different Sizes:
    LiquidGlassButton("Small", size: .small) { }
    LiquidGlassButton("Medium", size: .medium) { }
    LiquidGlassButton("Large", size: .large) { }
 
 5. Custom Liquid Glass Effect:
    LiquidGlassButton("Custom", blur: 0.9, reflection: 0.6) {
        // Custom action
    }
*/

// MARK: - Design Notes
/*
 BUTTON DESIGN PRINCIPLES:
 
 1. VISUAL HIERARCHY:
    - Different colors for different actions
    - Primary: Blue (main actions)
    - Secondary: Gray (secondary actions)
    - Accent: Purple (special actions)
    - Destructive: Red (dangerous actions)
    - Ghost: Transparent (subtle actions)
 
 2. INTERACTION FEEDBACK:
    - Scale animation when pressed
    - Icon bounce effect
    - Spring animation for natural feel
 
 3. ACCESSIBILITY:
    - Clear text labels
    - Appropriate contrast ratios
    - Touch targets meet minimum size requirements
 
 4. CUSTOMIZATION:
    - Multiple sizes for different contexts
    - Optional icons for visual clarity
    - Full Liquid Glass parameter control
*/

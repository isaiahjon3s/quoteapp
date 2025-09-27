//
//  LiquidGlassMenu.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Menu Component
// This is a collapsible menu that uses the Liquid Glass design system.
// It provides a way to show/hide additional content with smooth animations.

struct LiquidGlassMenu<Content: View>: View {
    // MARK: - Properties
    let content: Content             // The content to display when expanded
    let isExpanded: Bool            // Whether the menu is currently expanded
    let onToggle: () -> Void        // Callback when the menu is toggled
    let blur: CGFloat               // Liquid Glass blur intensity
    let reflection: CGFloat         // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat  // Liquid Glass motion sensitivity
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Menu
    /// - Parameters:
    ///   - isExpanded: Whether the menu is currently expanded
    ///   - onToggle: Callback when the menu is toggled
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    ///   - content: The content to display when expanded
    init(
        isExpanded: Bool,
        onToggle: @escaping () -> Void,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6,
        @ViewBuilder content: () -> Content
    ) {
        self.isExpanded = isExpanded
        self.onToggle = onToggle
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if isExpanded {
                content
                    .background(
                        // Translucent background
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .overlay(
                        // White border for glass effect
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(
                        // Smooth expand/collapse animation
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        )
                    )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isExpanded)
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassMenu:
 
 1. Basic Menu:
    @State private var isMenuExpanded = false
    
    LiquidGlassMenu(
        isExpanded: isMenuExpanded,
        onToggle: {
            isMenuExpanded.toggle()
        }
    ) {
        VStack(spacing: 12) {
            Button("Option 1") { }
            Button("Option 2") { }
            Button("Option 3") { }
        }
        .padding()
    }
 
 2. With Toggle Button:
    @State private var isMenuExpanded = false
    
    VStack {
        // Toggle button
        Button("Toggle Menu") {
            isMenuExpanded.toggle()
        }
        
        // Menu content
        LiquidGlassMenu(
            isExpanded: isMenuExpanded,
            onToggle: {
                isMenuExpanded.toggle()
            }
        ) {
            VStack(spacing: 16) {
                Text("Menu Options")
                    .font(.headline)
                
                Button("Edit") { }
                Button("Delete") { }
                Button("Share") { }
            }
            .padding()
        }
    }
 
 3. Custom Styling:
    LiquidGlassMenu(
        isExpanded: isMenuExpanded,
        onToggle: { isMenuExpanded.toggle() },
        blur: 0.8,
        reflection: 0.5,
        motionSensitivity: 0.7
    ) {
        // Custom content
    }
 
 4. In a Card:
    LiquidGlassCard {
        VStack {
            HStack {
                Text("Settings")
                Spacer()
                Button("More") {
                    isMenuExpanded.toggle()
                }
            }
            
            LiquidGlassMenu(
                isExpanded: isMenuExpanded,
                onToggle: { isMenuExpanded.toggle() }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Advanced Settings")
                    Toggle("Option 1", isOn: $option1)
                    Toggle("Option 2", isOn: $option2)
                }
                .padding()
            }
        }
    }
 
 5. With Animation:
    @State private var isMenuExpanded = false
    
    var body: some View {
        VStack {
            Button("Show Menu") {
                withAnimation(.spring()) {
                    isMenuExpanded.toggle()
                }
            }
            
            LiquidGlassMenu(
                isExpanded: isMenuExpanded,
                onToggle: { isMenuExpanded.toggle() }
            ) {
                // Menu content
            }
        }
    }
*/

// MARK: - Design Notes
/*
 MENU DESIGN PRINCIPLES:
 
 1. ANIMATION:
    - Smooth expand/collapse transitions
    - Scale and opacity effects
    - Spring animations for natural feel
    - Asymmetric transitions for polish
 
 2. LAYOUT:
    - Content-driven sizing
    - Consistent padding and spacing
    - Rounded corners for modern look
    - Proper content hierarchy
 
 3. INTERACTION:
    - Clear toggle mechanism
    - Smooth state changes
    - Visual feedback
    - Intuitive behavior
 
 4. CUSTOMIZATION:
    - Flexible content support
    - Liquid Glass parameters
    - Custom animations
    - Responsive design
 
 5. ACCESSIBILITY:
    - Clear state indication
    - Appropriate contrast
    - VoiceOver support
    - Keyboard navigation
*/

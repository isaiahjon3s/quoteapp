//
//  LiquidGlassBackground.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Background Component
// This is a customizable background that uses the Liquid Glass design system.
// It provides animated floating elements and gradient backgrounds.

struct LiquidGlassBackground<Content: View>: View {
    // MARK: - Properties
    let content: Content             // The content to display over the background
    let shouldAnimate: Bool          // Whether to animate the floating elements
    let blur: CGFloat                // Liquid Glass blur intensity
    let reflection: CGFloat          // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat   // Liquid Glass motion sensitivity
    
    // MARK: - State
    @State private var animate = false  // Controls the animation state
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Background
    /// - Parameters:
    ///   - animate: Whether to animate the floating elements (default: true)
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    ///   - content: The content to display over the background
    init(
        animate: Bool = true,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6,
        @ViewBuilder content: () -> Content
    ) {
        self.shouldAnimate = animate
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Base gradient background
            baseGradient
            
            // Animated floating orbs
            if shouldAnimate {
                floatingOrbs
            }
            
            // Main content
            content
        }
        .onAppear {
            if shouldAnimate {
                self.animate = true
            }
        }
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
    
    // MARK: - Base Gradient
    /// Creates the base gradient background
    private var baseGradient: some View {
        LinearGradient(
            colors: [
                .blue.opacity(0.1),      // Subtle blue tint
                .purple.opacity(0.1),    // Subtle purple tint
                .pink.opacity(0.1)       // Subtle pink tint
            ],
            startPoint: .topLeading,     // Starts from top-left
            endPoint: .bottomTrailing    // Ends at bottom-right
        )
        .ignoresSafeArea()  // Extend to all edges
    }
    
    // MARK: - Floating Orbs
    /// Creates the animated floating orbs
    private var floatingOrbs: some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.1),  // Bright center
                            .clear                // Transparent edges
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 1)  // Soft blur for ethereal effect
                .offset(
                    x: animate ? CGFloat.random(in: -50...50) : 0,
                    y: animate ? CGFloat.random(in: -50...50) : 0
                )
                .scaleEffect(animate ? CGFloat.random(in: 0.8...1.2) : 1.0)
                .animation(
                    .spring(response: 4, dampingFraction: 0.6, blendDuration: 0)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 1.0),  // Stagger the animations
                    value: animate
                )
        }
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassBackground:
 
 1. Basic Background:
    LiquidGlassBackground {
        VStack {
            Text("Hello World")
            Button("Action") { }
        }
    }
 
 2. Static Background (No Animation):
    LiquidGlassBackground(animate: false) {
        Text("Static Content")
    }
 
 3. Custom Styling:
    LiquidGlassBackground(
        animate: true,
        blur: 0.8,
        reflection: 0.5,
        motionSensitivity: 0.7
    ) {
        Text("Custom Styled Content")
    }
 
 4. With Navigation:
    NavigationView {
        LiquidGlassBackground {
            List {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
        }
    }
 
 5. Full Screen Content:
    LiquidGlassBackground {
        VStack {
            Spacer()
            Text("Centered Content")
            Spacer()
        }
    }
*/

// MARK: - Design Notes
/*
 BACKGROUND DESIGN PRINCIPLES:
 
 1. LAYERING:
    - Base gradient for color foundation
    - Floating orbs for movement and interest
    - Content layer on top
    - Liquid Glass effect applied to everything
 
 2. ANIMATION:
    - Subtle floating movement
    - Staggered timing for natural feel
    - Spring animations for smooth motion
    - Optional animation for performance
 
 3. COLORS:
    - Subtle, non-distracting colors
    - Blue, purple, and pink tints
    - Low opacity to not interfere with content
    - Gradient for depth and interest
 
 4. PERFORMANCE:
    - Optional animation for battery life
    - Efficient rendering with blur effects
    - Minimal impact on content performance
    - Smooth 60fps animations
 
 5. CUSTOMIZATION:
    - Adjustable animation
    - Liquid Glass parameters
    - Flexible content support
    - Responsive to different screen sizes
*/

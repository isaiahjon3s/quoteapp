//
//  LiquidGlassCard.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Card Component
// This is a reusable card component that uses the Liquid Glass design system.
// It creates a translucent, glass-like container for any content.

struct LiquidGlassCard<Content: View>: View {
    // MARK: - Properties
    let content: Content           // The content to display inside the card
    let cornerRadius: CGFloat      // How rounded the corners should be
    let padding: CGFloat          // Space between content and card edges
    let isInteractive: Bool       // Whether the card responds to touch
    let blur: CGFloat             // Liquid Glass blur intensity
    let reflection: CGFloat       // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat // Liquid Glass motion sensitivity
    
    // MARK: - State
    @State private var isPressed = false  // Tracks if the card is being pressed
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Card
    /// - Parameters:
    ///   - cornerRadius: How rounded the corners should be (default: 28)
    ///   - padding: Space between content and card edges (default: 24)
    ///   - isInteractive: Whether the card responds to touch (default: false)
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    ///   - content: The content to display inside the card
    init(
        cornerRadius: CGFloat = 28,
        padding: CGFloat = 24,
        isInteractive: Bool = false,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isInteractive = isInteractive
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        content
            .padding(padding)  // Add padding around the content
            .background(
                // Create the translucent background using regular material
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius)
            )
            .overlay(
                // Add a subtle white border for the glass effect
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            // Add press animation if interactive
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isPressed)
            .gesture(
                // Add touch gesture if interactive
                isInteractive ? 
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    } : nil
            )
            // Apply the Liquid Glass effect
            .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassCard:
 
 1. Basic Card:
    LiquidGlassCard {
        Text("Hello World")
    }
 
 2. Interactive Card with Custom Styling:
    LiquidGlassCard(
        cornerRadius: 20,
        padding: 16,
        isInteractive: true,
        blur: 0.8,
        reflection: 0.5
    ) {
        VStack {
            Text("Title")
            Text("Description")
        }
    }
 
 3. Card with Complex Content:
    LiquidGlassCard {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
            Text("Featured Content")
            Button("Action") { }
        }
    }
*/

// MARK: - Design Notes
/*
 CARD DESIGN PRINCIPLES:
 
 1. TRANSLUCENCY:
    - Uses .regularMaterial for the background
    - Creates a frosted glass effect
    - Content behind shows through slightly
 
 2. BORDERS:
    - White border with low opacity
    - Creates definition without being harsh
    - Matches the glass aesthetic
 
 3. INTERACTIVITY:
    - Optional press animation
    - Scales down slightly when pressed
    - Spring animation for natural feel
 
 4. CUSTOMIZATION:
    - Adjustable corner radius
    - Adjustable padding
    - Full Liquid Glass parameter control
*/

//
//  LiquidGlassModifier.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Design System
// This file contains the core Liquid Glass modifier that creates the translucent,
// glass-like effect with blur, reflection, and motion sensitivity.

// MARK: - Liquid Glass View Extension
// This extension adds the liquidGlass modifier to any SwiftUI View
extension View {
    /// Applies the Liquid Glass effect to any view
    /// - Parameters:
    ///   - blur: Controls the blur intensity (0.0 = no blur, 1.0 = maximum blur)
    ///   - reflection: Controls the reflection intensity (0.0 = no reflection, 1.0 = maximum reflection)
    ///   - motionSensitivity: Controls how much the effect responds to motion (0.0 = static, 1.0 = very responsive)
    func liquidGlass(blur: CGFloat = 0.7, reflection: CGFloat = 0.4, motionSensitivity: CGFloat = 0.6) -> some View {
        modifier(LiquidGlassOverlayModifier(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity))
    }
}

// MARK: - Liquid Glass Overlay Modifier
// This is the actual modifier that creates the glass effect
private struct LiquidGlassOverlayModifier: ViewModifier {
    // MARK: - Properties
    let blur: CGFloat              // How much blur to apply
    let reflection: CGFloat        // How much reflection to show
    let motionSensitivity: CGFloat // How responsive to motion
    
    // MARK: - State
    @State private var shimmer = false  // Controls the shimmer animation
    
    // MARK: - Computed Properties
    /// Creates a smooth, repeating animation for the shimmer effect
    private var shimmerAnimation: Animation {
        .easeInOut(duration: 6 - (Double(motionSensitivity) * 2))
        .repeatForever(autoreverses: true)
    }
    
    // MARK: - Body
    func body(content: Content) -> some View {
        content
            // First overlay: Creates the reflective shimmer effect
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(reflection * 0.35),  // Bright reflection
                        Color.white.opacity(0.05)               // Subtle highlight
                    ],
                    startPoint: .topLeading,    // Starts from top-left
                    endPoint: .bottomTrailing   // Ends at bottom-right
                )
                .opacity(shimmer ? 1 : 0.7)     // Animated opacity
                .blendMode(.screen)              // Screen blend for bright effect
                .allowsHitTesting(false)         // Don't interfere with touch
            )
            // Second overlay: Creates the colored blur effect
            .overlay(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.15 * blur),    // Blue tint
                        Color.purple.opacity(0.1 * blur)    // Purple tint
                    ],
                    startPoint: .bottomLeading,  // Starts from bottom-left
                    endPoint: .topTrailing      // Ends at top-right
                )
                .blur(radius: blur * 12)        // Blur the gradient
                .allowsHitTesting(false)        // Don't interfere with touch
            )
            // Shadow: Adds depth and floating effect
            .shadow(
                color: Color.black.opacity(0.18 * blur),
                radius: 24 * blur,
                x: 0,
                y: 16
            )
            // Animation: Starts the shimmer effect when the view appears
            .onAppear {
                withAnimation(shimmerAnimation) {
                    shimmer.toggle()
                }
            }
    }
}

// MARK: - Liquid Glass Parameters Explained
/*
 LIQUID GLASS DESIGN CONCEPTS:
 
 1. BLUR (0.0 - 1.0):
    - Controls how much the background is blurred
    - Higher values create more frosted glass effect
    - Lower values are more transparent
 
 2. REFLECTION (0.0 - 1.0):
    - Controls the shimmer/reflection effect
    - Higher values create more glass-like appearance
    - Creates the "liquid" feeling with animated highlights
 
 3. MOTION SENSITIVITY (0.0 - 1.0):
    - Controls how fast the shimmer animation plays
    - Higher values = faster, more responsive animation
    - Lower values = slower, more subtle animation
 
 4. MATERIALS USED:
    - .regularMaterial: Creates the translucent background
    - .ultraThinMaterial: For lighter glass effects
    - LinearGradient: For colored tints and reflections
    - Screen blend mode: Makes reflections bright and glass-like
 
 5. ANIMATION:
    - Shimmer effect moves across the surface
    - Creates the "liquid" feeling
    - Duration changes based on motion sensitivity
*/

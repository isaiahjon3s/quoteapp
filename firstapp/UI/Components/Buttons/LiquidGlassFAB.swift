//
//  LiquidGlassFAB.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass FAB (Floating Action Button) Component
// This is a floating action button that uses the Liquid Glass design system.
// It provides a prominent action button that floats above other content.

struct LiquidGlassFAB: View {
    // MARK: - Properties
    let icon: String                // SF Symbol icon name
    let action: () -> Void          // Action to perform when tapped
    let blur: CGFloat               // Liquid Glass blur intensity
    let reflection: CGFloat         // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat  // Liquid Glass motion sensitivity
    
    // MARK: - State
    @State private var isPressed = false  // Tracks if the button is being pressed
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass FAB
    /// - Parameters:
    ///   - icon: SF Symbol icon name
    ///   - action: Action to perform when tapped
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    init(
        icon: String,
        action: @escaping () -> Void,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6
    ) {
        self.icon = icon
        self.action = action
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    // Circular background with material
                    .regularMaterial,
                    in: Circle()
                )
                .overlay(
                    // White border for glass effect
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .clipShape(Circle())
                .shadow(
                    // Drop shadow for floating effect
                    color: .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)  // Press animation
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing  // Track press state
        }, perform: {})
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassFAB:
 
 1. Basic FAB:
    LiquidGlassFAB(icon: "plus") {
        // Add action
    }
 
 2. In a ZStack (floating over content):
    ZStack {
        // Main content
        ScrollView {
            VStack {
                // Content here
            }
        }
        
        // Floating action button
        VStack {
            Spacer()
            HStack {
                Spacer()
                LiquidGlassFAB(icon: "plus") {
                    showAddSheet = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
 
 3. Custom Styling:
    LiquidGlassFAB(
        icon: "heart.fill",
        blur: 0.8,
        reflection: 0.5,
        motionSensitivity: 0.7
    ) {
        // Custom action
    }
 
 4. Multiple FABs:
    VStack {
        Spacer()
        HStack {
            Spacer()
            LiquidGlassFAB(icon: "plus") {
                // Add action
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
    }
 
 5. With Animation:
    @State private var showFAB = false
    
    var body: some View {
        ZStack {
            // Content
            
            if showFAB {
                LiquidGlassFAB(icon: "plus") {
                    // Action
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                showFAB = true
            }
        }
    }
*/

// MARK: - Design Notes
/*
 FAB DESIGN PRINCIPLES:
 
 1. POSITIONING:
    - Floats above other content
    - Typically positioned at bottom-right
    - Doesn't interfere with scrolling
    - Easy to reach with thumb
 
 2. VISUAL DESIGN:
    - Circular shape for easy recognition
    - Prominent size (56x56 points)
    - High contrast with background
    - Clear icon representation
 
 3. INTERACTION:
    - Press animation for feedback
    - Haptic feedback on tap
    - Smooth transitions
    - Clear action indication
 
 4. ACCESSIBILITY:
    - Large touch target
    - Clear icon meaning
    - VoiceOver support
    - High contrast colors
 
 5. CUSTOMIZATION:
    - Flexible icon options
    - Liquid Glass parameters
    - Custom actions
    - Animation support
*/

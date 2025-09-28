//
//  LiquidGlassProgressBar.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Progress Bar Component
// This is a customizable progress bar that uses the Liquid Glass design system.
// It provides visual feedback for progress and completion states.

struct LiquidGlassProgressBar: View {
    // MARK: - Properties
    let progress: Double           // Progress value (0.0 to 1.0)
    let height: CGFloat           // Height of the progress bar
    let cornerRadius: CGFloat     // Corner radius for rounded appearance
    let blur: CGFloat             // Liquid Glass blur intensity
    let reflection: CGFloat       // Liquid Glass reflection intensity
    let motionSensitivity: CGFloat // Liquid Glass motion sensitivity
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Progress Bar
    /// - Parameters:
    ///   - progress: Progress value (0.0 to 1.0)
    ///   - height: Height of the progress bar (default: 8)
    ///   - cornerRadius: Corner radius for rounded appearance (default: 4)
    ///   - blur: Liquid Glass blur intensity (default: 0.7)
    ///   - reflection: Liquid Glass reflection intensity (default: 0.4)
    ///   - motionSensitivity: Liquid Glass motion sensitivity (default: 0.6)
    init(
        progress: Double,
        height: CGFloat = 8,
        cornerRadius: CGFloat = 4,
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6
    ) {
        self.progress = progress
        self.height = height
        self.cornerRadius = cornerRadius
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                
                // Progress fill
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [.accentColor, .accentColor.opacity(0.8)],  // Accent color gradient
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0),
                        value: progress
                    )
            }
        }
        .frame(height: height)
        // Apply the Liquid Glass effect
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassProgressBar:
 
 1. Basic Progress Bar:
    @State private var progress: Double = 0.3
    LiquidGlassProgressBar(progress: progress)
 
 2. Custom Styling:
    @State private var progress: Double = 0.7
    LiquidGlassProgressBar(
        progress: progress,
        height: 12,
        cornerRadius: 6,
        blur: 0.8,
        reflection: 0.5
    )
 
 3. In a Card:
    LiquidGlassCard {
        VStack(alignment: .leading, spacing: 12) {
            Text("Download Progress")
                .font(.headline)
            
            LiquidGlassProgressBar(progress: downloadProgress)
            
            Text("\(Int(downloadProgress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
 
 4. With Animation:
    @State private var progress: Double = 0
    
    var body: some View {
        VStack {
            LiquidGlassProgressBar(progress: progress)
            
            Button("Start Progress") {
                withAnimation(.easeInOut(duration: 2.0)) {
                    progress = 1.0
                }
            }
        }
    }
 
 5. Multiple Progress Bars:
    VStack(spacing: 16) {
        LiquidGlassProgressBar(progress: 0.3, height: 8)
        LiquidGlassProgressBar(progress: 0.7, height: 8)
        LiquidGlassProgressBar(progress: 0.9, height: 8)
    }
*/

// MARK: - Design Notes
/*
 PROGRESS BAR DESIGN PRINCIPLES:
 
 1. VISUAL FEEDBACK:
    - Clear progress indication
    - Smooth animations
    - Color-coded states
    - Consistent styling
 
 2. CUSTOMIZATION:
    - Adjustable height
    - Rounded corners
    - Liquid Glass effects
    - Gradient colors
 
 3. ACCESSIBILITY:
    - Clear visual progress
    - Appropriate contrast
    - Screen reader support
    - Semantic information
 
 4. ANIMATION:
    - Smooth progress changes
    - Spring animations
    - Responsive to updates
    - Natural feel
 
 5. LIQUID GLASS EFFECT:
    - Translucent background
    - Gradient progress fill
    - Subtle shadows
    - Glass-like appearance
*/

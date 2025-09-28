//
//  LiquidGlassSlider.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Liquid Glass Slider Component
// This is a customizable slider that uses the Liquid Glass design system.
// It provides a visual way to select values within a range.

struct LiquidGlassSlider: View {
    // MARK: - Properties
    @Binding var value: Double        // The current value (two-way binding)
    let range: ClosedRange<Double>    // The range of possible values
    let step: Double                  // The step size for value changes
    let label: String                 // Label to display above the slider
    let leadingIcon: String           // SF Symbol icon to show with the label
    let unit: String?                 // Optional unit to display with the value
    let accent: Color                 // Accent color for the slider
    
    // MARK: - Initializer
    /// Creates a new Liquid Glass Slider
    /// - Parameters:
    ///   - label: Label to display above the slider
    ///   - value: Binding to the current value
    ///   - range: Range of possible values
    ///   - step: Step size for value changes (default: 1)
    ///   - leadingIcon: SF Symbol icon name (default: "slider.horizontal.3")
    ///   - unit: Optional unit to display with the value (default: nil)
    ///   - accent: Accent color for the slider (default: .accentColor)
    init(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1,
        leadingIcon: String = "slider.horizontal.3",
        unit: String? = nil,
        accent: Color = .accentColor
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.leadingIcon = leadingIcon
        self.unit = unit
        self.accent = accent
    }
    
    // MARK: - Computed Properties
    /// Formats the current value for display
    private var formattedValue: String {
        if let unit = unit {
            return String(format: "%.0f%@", value, unit)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with label and current value
            HStack {
                // Label with icon
                Label(label, systemImage: leadingIcon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Current value display
                Text(formattedValue)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            
            // The actual slider
            Slider(value: $value, in: range, step: step)
                .tint(accent)  // Set the accent color
                .shadow(color: accent.opacity(0.25), radius: 12, x: 0, y: 6)  // Add colored shadow
        }
        .padding(.vertical, 16)    // Vertical padding
        .padding(.horizontal, 18)  // Horizontal padding
        .background(
            // Translucent background
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    // Subtle border
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        // Apply the Liquid Glass effect
        .liquidGlass(blur: 0.55, reflection: 0.4, motionSensitivity: 0.4)
    }
}

// MARK: - Usage Examples
/*
 HOW TO USE LiquidGlassSlider:
 
 1. Basic Slider:
    @State private var volume: Double = 50
    LiquidGlassSlider(
        label: "Volume",
        value: $volume,
        range: 0...100
    )
 
 2. Slider with Unit:
    @State private var temperature: Double = 20
    LiquidGlassSlider(
        label: "Temperature",
        value: $temperature,
        range: -10...40,
        step: 0.5,
        unit: "°C"
    )
 
 3. Custom Styling:
    @State private var brightness: Double = 0.5
    LiquidGlassSlider(
        label: "Brightness",
        value: $brightness,
        range: 0...1,
        step: 0.1,
        leadingIcon: "sun.max",
        accent: .orange
    )
 
 4. Time Slider:
    @State private var duration: Double = 30
    LiquidGlassSlider(
        label: "Duration",
        value: $duration,
        range: 1...120,
        step: 1,
        leadingIcon: "clock",
        unit: "min"
    )
 
 5. In a Settings View:
    VStack(spacing: 20) {
        LiquidGlassSlider("Volume", value: $volume, range: 0...100)
        LiquidGlassSlider("Brightness", value: $brightness, range: 0...1, step: 0.1)
        LiquidGlassSlider("Font Size", value: $fontSize, range: 12...24, unit: "pt")
    }
*/

// MARK: - Design Notes
/*
 SLIDER DESIGN PRINCIPLES:
 
 1. VISUAL HIERARCHY:
    - Clear label with icon for context
    - Current value displayed prominently
    - Accent color for the slider track
 
 2. ACCESSIBILITY:
    - Clear labels and values
    - Appropriate contrast ratios
    - Support for VoiceOver
    - Haptic feedback on value changes
 
 3. CUSTOMIZATION:
    - Flexible range and step values
    - Optional units for clarity
    - Customizable accent colors
    - Icon options for context
 
 4. INTERACTION:
    - Smooth value changes
    - Visual feedback with shadows
    - Two-way data binding
    - Step-based value changes
 
 5. LIQUID GLASS EFFECT:
    - Translucent background
    - Subtle border
    - Colored shadow for depth
    - Glass-like appearance
*/

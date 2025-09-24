//
//  LiquidGlassComponents.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - Apple's Official Liquid Glass System (iOS 26)

// MARK: - Apple's Official Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    let isInteractive: Bool
    
    @State private var isPressed = false
    
    init(
        cornerRadius: CGFloat = 28,
        padding: CGFloat = 24,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .glassEffect() // Apple's official liquid glass modifier
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isPressed)
            .gesture(
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
    }
}

// MARK: - Liquid Glass Button
struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    
    @State private var isPressed = false
    @State private var liquidPhase: CGFloat = 0
    @State private var ripplePhase: CGFloat = 0
    
    enum ButtonStyle {
        case primary
        case secondary
        case accent
        case destructive
        case ghost
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            case .medium: return EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
            case .large: return EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40)
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption.weight(.bold)
            case .medium: return .body.weight(.bold)
            case .large: return .title3.weight(.bold)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)) {
                ripplePhase = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ripplePhase = 0.0
            }
            action()
        }) {
            ZStack {
                HStack(spacing: 12) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(size.font)
                            .symbolEffect(.bounce, value: isPressed)
                    }
                    Text(title)
                        .font(size.font)
                }
                .foregroundColor(textColor)
                .padding(size.padding)
                .background(
                    ZStack {
                        // Base liquid glass
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: size.cornerRadius)
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                .white.opacity(0.3),
                                                .white.opacity(0.1),
                                                .clear
                                            ],
                                            center: .topLeading,
                                            startRadius: 0,
                                            endRadius: 100
                                        )
                                    )
                            )
                            .background(
                                // Liquid shimmer effect
                                RoundedRectangle(cornerRadius: size.cornerRadius)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                .white.opacity(0.2),
                                                .clear
                                            ],
                                            startPoint: .init(x: liquidPhase - 0.4, y: 0),
                                            endPoint: .init(x: liquidPhase + 0.4, y: 1)
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: size.cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.6),
                                                .white.opacity(0.2),
                                                .clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: size.cornerRadius)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.9),
                                                .clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .init(x: 0.4, y: 0.4)
                                        ),
                                        lineWidth: 0.5
                                    )
                            )
                    }
                )
                
                // Liquid ripple effect
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: ripplePhase * 200
                        )
                    )
                    .scaleEffect(ripplePhase)
                    .opacity(1 - ripplePhase)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .onAppear {
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var textColor: Color {
        switch style {
        case .primary: return .blue
        case .secondary: return .gray
        case .accent: return .purple
        case .destructive: return .red
        case .ghost: return .primary
        }
    }
}

// MARK: - Liquid Glass Text Field
struct LiquidGlassTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let isSecure: Bool
    
    @State private var isFocused = false
    @State private var liquidPhase: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .blue : .secondary)
                    .frame(width: 24)
                    .symbolEffect(.bounce, value: isFocused)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isTextFieldFocused)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            ZStack {
                // Base liquid glass
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(isFocused ? 0.3 : 0.15),
                                        .white.opacity(isFocused ? 0.2 : 0.08),
                                        .clear
                                    ],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 150
                                )
                            )
                    )
                    .background(
                        // Liquid shimmer
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .init(x: liquidPhase - 0.3, y: 0),
                                    endPoint: .init(x: liquidPhase + 0.3, y: 1)
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        isFocused ? .blue.opacity(0.8) : .white.opacity(0.4),
                                        isFocused ? .blue.opacity(0.4) : .white.opacity(0.2),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isFocused ? 2.5 : 1.5
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        isFocused ? .blue.opacity(0.6) : .white.opacity(0.6),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .init(x: 0.3, y: 0.3)
                                ),
                                lineWidth: 0.5
                            )
                    )
            }
        )
        .shadow(
            color: isFocused ? .blue.opacity(0.15) : .black.opacity(0.08),
            radius: isFocused ? 12 : 6,
            x: 0,
            y: isFocused ? 6 : 3
        )
        .scaleEffect(isFocused ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isFocused)
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
        }
        .onChange(of: isTextFieldFocused) { _, newValue in
            isFocused = newValue
        }
    }
}

// MARK: - Liquid Glass Progress Bar
struct LiquidGlassProgressBar: View {
    let progress: Double
    let color: Color
    let height: CGFloat
    let cornerRadius: CGFloat
    let isAnimated: Bool
    
    @State private var animatedProgress: Double = 0
    @State private var liquidPhase: CGFloat = 0
    
    init(
        progress: Double,
        color: Color = .blue,
        height: CGFloat = 12,
        cornerRadius: CGFloat = 8,
        isAnimated: Bool = true
    ) {
        self.progress = max(0, min(1, progress))
        self.color = color
        self.height = height
        self.cornerRadius = cornerRadius
        self.isAnimated = isAnimated
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Liquid glass background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.15),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Liquid progress fill
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        RadialGradient(
                            colors: [
                                color,
                                color.opacity(0.8),
                                color.opacity(0.6)
                            ],
                            center: .leading,
                            startRadius: 0,
                            endRadius: height * 2
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .background(
                        // Liquid shimmer effect
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .init(x: liquidPhase - 0.2, y: 0),
                                    endPoint: .init(x: liquidPhase + 0.2, y: 1)
                                )
                            )
                    )
                    .frame(width: geometry.size.width * (isAnimated ? animatedProgress : progress))
                    .shadow(
                        color: color.opacity(0.4),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 0), value: animatedProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
            if isAnimated {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.8, blendDuration: 0).delay(0.2)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            if isAnimated {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    animatedProgress = newValue
                }
            }
        }
    }
}

// MARK: - Liquid Glass Tab View
struct LiquidGlassTabView<Content: View>: View {
    let tabs: [TabItem]
    @Binding var selectedTab: Int
    let content: (Int) -> Content
    
    @State private var liquidPhase: CGFloat = 0
    
    struct TabItem {
        let title: String
        let icon: String
    }
    
    init(
        tabs: [TabItem],
        selectedTab: Binding<Int>,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.tabs = tabs
        self._selectedTab = selectedTab
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Content
            content(selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Liquid Glass Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 22, weight: .medium))
                                .symbolEffect(.bounce, value: selectedTab == index)
                            Text(tabs[index].title)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(selectedTab == index ? .blue : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                if selectedTab == index {
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.ultraThinMaterial)
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(
                                                    RadialGradient(
                                                        colors: [
                                                            .blue.opacity(0.2),
                                                            .blue.opacity(0.1),
                                                            .clear
                                                        ],
                                                        center: .topLeading,
                                                        startRadius: 0,
                                                        endRadius: 100
                                                    )
                                                )
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 18)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            .clear,
                                                            .white.opacity(0.1),
                                                            .clear
                                                        ],
                                                        startPoint: .init(x: liquidPhase - 0.3, y: 0),
                                                        endPoint: .init(x: liquidPhase + 0.3, y: 1)
                                                    )
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            .blue.opacity(0.4),
                                                            .blue.opacity(0.2),
                                                            .clear
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1.5
                                                )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [
                                                            .blue.opacity(0.6),
                                                            .clear
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .init(x: 0.3, y: 0.3)
                                                    ),
                                                    lineWidth: 0.5
                                                )
                                        )
                                        .shadow(
                                            color: .blue.opacity(0.2),
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            .white.opacity(0.2),
                                            .white.opacity(0.05),
                                            .clear
                                        ],
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 200
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.4),
                                            .white.opacity(0.1),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                }
            )
            .shadow(
                color: .black.opacity(0.1),
                radius: 20,
                x: 0,
                y: 10
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 40,
                x: 0,
                y: 20
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
        }
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    @State private var animate = false
    @State private var liquidPhase: CGFloat = 0
    @State private var wavePhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base liquid gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.08),
                    Color.purple.opacity(0.06),
                    Color.pink.opacity(0.04),
                    Color.cyan.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(
                LinearGradient(
                    colors: [
                        Color.indigo.opacity(0.03),
                        Color.teal.opacity(0.02),
                        Color.mint.opacity(0.03)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
            
            // Liquid glass orbs
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.15),
                                .white.opacity(0.08),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 2)
                    .offset(
                        x: animate ? CGFloat.random(in: -100...100) : CGFloat.random(in: -100...100),
                        y: animate ? CGFloat.random(in: -100...100) : CGFloat.random(in: -100...100)
                    )
                    .scaleEffect(animate ? CGFloat.random(in: 0.8...1.3) : 1.0)
                    .animation(
                        .spring(response: Double.random(in: 4...8), dampingFraction: 0.6, blendDuration: 0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.8),
                        value: animate
                    )
            }
            
            // Liquid wave patterns
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let waveLength = width / 2
                    let amplitude = height * 0.15
                    
                    // First wave
                    path.move(to: CGPoint(x: 0, y: height * 0.2))
                    for x in stride(from: 0, through: width, by: 2) {
                        let relativeX = x / waveLength
                        let sine = sin(relativeX * .pi + wavePhase)
                        let y = height * 0.2 + amplitude * sine
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    // Second wave
                    path.move(to: CGPoint(x: 0, y: height * 0.7))
                    for x in stride(from: 0, through: width, by: 2) {
                        let relativeX = x / waveLength
                        let sine = sin(relativeX * .pi * 1.5 + wavePhase + .pi)
                        let y = height * 0.7 + amplitude * 0.7 * sine
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.05),
                            .clear,
                            .white.opacity(0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 3
                )
                .blur(radius: 3)
            }
            
            // Liquid shimmer overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.02),
                            .clear
                        ],
                        startPoint: .init(x: liquidPhase - 0.5, y: 0),
                        endPoint: .init(x: liquidPhase + 0.5, y: 1)
                    )
                )
                .blendMode(.overlay)
        }
        .onAppear {
            animate = true
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - Additional Liquid Glass Components

// Liquid Glass Floating Action Button
struct LiquidGlassFAB: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var liquidPhase: CGFloat = 0
    @State private var ripplePhase: CGFloat = 0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)) {
                ripplePhase = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ripplePhase = 0.0
            }
            action()
        }) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .background(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                    )
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.1),
                                        .clear
                                    ],
                                    startPoint: .init(x: liquidPhase - 0.3, y: 0),
                                    endPoint: .init(x: liquidPhase + 0.3, y: 1)
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.2),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.8),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .init(x: 0.3, y: 0.3)
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, value: isPressed)
                
                // Ripple effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .blue.opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: ripplePhase * 100
                        )
                    )
                    .scaleEffect(ripplePhase)
                    .opacity(1 - ripplePhase)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .shadow(
            color: .blue.opacity(0.3),
            radius: 15,
            x: 0,
            y: 8
        )
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                liquidPhase = 1.0
            }
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

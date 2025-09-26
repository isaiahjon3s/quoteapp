//
//  LiquidGlassComponents.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

// MARK: - iOS 17 Liquid Glass Design System

// MARK: - Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    let isInteractive: Bool
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    @State private var isPressed = false
    
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
    
    var body: some View {
        content
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
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
            .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass Button
struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let size: ButtonSize
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    @State private var isPressed = false
    
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
    
    var body: some View {
        Button(action: action) {
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
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: size.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
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
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
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
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? .blue : .gray)
                    .font(.body.weight(.medium))
                    .symbolEffect(.bounce, value: isFocused)
            }
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused($isTextFieldFocused)
            .font(.body)
            .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isFocused ? .blue : .white.opacity(0.3),
                    lineWidth: isFocused ? 2.0 : 1.0
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: isFocused ? .blue.opacity(0.2) : .black.opacity(0.1),
            radius: isFocused ? 15 : 10,
            x: 0,
            y: isFocused ? 8 : 5
        )
        .onChange(of: isTextFieldFocused) { _, newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                isFocused = newValue
            }
        }
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass Progress Bar
struct LiquidGlassProgressBar: View {
    let progress: Double
    let height: CGFloat
    let cornerRadius: CGFloat
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
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
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0), value: progress)
            }
        }
        .frame(height: height)
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass Tab View
struct LiquidGlassTabView<Content: View>: View {
    let content: Content
    let selectedTab: Int
    let onTabSelected: (Int) -> Void
    let tabs: [TabItem]
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    struct TabItem {
        let title: String
        let icon: String
    }
    
    init(
        selectedTab: Int,
        onTabSelected: @escaping (Int) -> Void,
        tabs: [TabItem],
        blur: CGFloat = 0.7,
        reflection: CGFloat = 0.4,
        motionSensitivity: CGFloat = 0.6,
        @ViewBuilder content: () -> Content
    ) {
        self.selectedTab = selectedTab
        self.onTabSelected = onTabSelected
        self.tabs = tabs
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
            
            // Tab bar
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                            onTabSelected(index)
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                            
                            Text(tab.title)
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundColor(selectedTab == index ? .blue : .gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            selectedTab == index ? 
                            AnyView(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial)) :
                            AnyView(Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if index < tabs.count - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground<Content: View>: View {
    let content: Content
    let shouldAnimate: Bool
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    @State private var animate = false
    
    init(animate: Bool = true, blur: CGFloat = 0.7, reflection: CGFloat = 0.4, motionSensitivity: CGFloat = 0.6, @ViewBuilder content: () -> Content) {
        self.shouldAnimate = animate
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    .blue.opacity(0.1),
                    .purple.opacity(0.1),
                    .pink.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated floating orbs
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 1)
                    .offset(
                        x: animate ? CGFloat.random(in: -50...50) : 0,
                        y: animate ? CGFloat.random(in: -50...50) : 0
                    )
                    .scaleEffect(animate ? CGFloat.random(in: 0.8...1.2) : 1.0)
                    .animation(
                        .spring(response: 4, dampingFraction: 0.6, blendDuration: 0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 1.0),
                        value: animate
                    )
            }
            
            content
        }
        .onAppear {
            if shouldAnimate {
                self.animate = true
            }
        }
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass FAB (Floating Action Button)
struct LiquidGlassFAB: View {
    let icon: String
    let action: () -> Void
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
    @State private var isPressed = false
    
    init(icon: String, action: @escaping () -> Void, blur: CGFloat = 0.7, reflection: CGFloat = 0.4, motionSensitivity: CGFloat = 0.6) {
        self.icon = icon
        self.action = action
        self.blur = blur
        self.reflection = reflection
        self.motionSensitivity = motionSensitivity
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(.regularMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
                .clipShape(Circle())
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

// MARK: - Liquid Glass Menu
struct LiquidGlassMenu<Content: View>: View {
    let content: Content
    let isExpanded: Bool
    let onToggle: () -> Void
    let blur: CGFloat
    let reflection: CGFloat
    let motionSensitivity: CGFloat
    
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
    
    var body: some View {
        VStack {
            if isExpanded {
                content
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: isExpanded)
        .liquidGlass(blur: blur, reflection: reflection, motionSensitivity: motionSensitivity)
    }
}

extension View {
    func liquidGlass(blur: CGFloat = 0.7, reflection: CGFloat = 0.4, motionSensitivity: CGFloat = 0.6) -> some View {
        self
            .background(.regularMaterial)
            .blur(radius: blur * 5)
            .overlay(Color.white.opacity(reflection * 0.2)) // Simulate reflection
            .animation(.spring(response: motionSensitivity, dampingFraction: 0.7), value: motionSensitivity) // Simulate motion with spring animation
            // Note: In actual iOS 26, this would use native .liquidGlass APIs with CoreMotion integration
    }
}
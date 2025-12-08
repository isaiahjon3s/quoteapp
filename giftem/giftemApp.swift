//
//  giftemApp.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

@main
struct giftemApp: App {
    @State private var showSplash = true
    @AppStorage("isDarkMode") private var isDarkMode = false // Light mode by default
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content always rendered underneath
                ContentView()
                    .environment(\.isDarkMode, $isDarkMode)
                
                // Splash video overlay
                if showSplash {
                    SplashVideoView {
                        showSplash = false
                    }
                    .zIndex(1)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// Environment key for dark mode binding
private struct DarkModeKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isDarkMode: Binding<Bool> {
        get { self[DarkModeKey.self] }
        set { self[DarkModeKey.self] = newValue }
    }
}

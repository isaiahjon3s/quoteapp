//
//  SettingsView.swift
//  giftem
//

import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Standard iOS grouped list — system handles the glass on nav bar / sheets
        List {
            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Label {
                        Text("Dark Mode")
                    } icon: {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .foregroundStyle(isDarkMode ? .indigo : .orange)
                    }
                }
                .tint(.purple)
            }
            
            Section("About") {
                LabeledContent {
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Version", systemImage: "info.circle")
                }
                
                LabeledContent {
                    Text("SwiftUI")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Framework", systemImage: "swift")
                }
                
                LabeledContent {
                    Text("Liquid Glass")
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Design System", systemImage: "sparkles")
                }
            }
            
            Section {
                // Secondary action — .glass button style
                Button(role: .destructive) {
                    // future: sign out
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Primary action gets .glassProminent
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView(isDarkMode: .constant(false))
    }
}

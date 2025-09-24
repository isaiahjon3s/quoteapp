//
//  AddQuoteView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct AddQuoteView: View {
    @ObservedObject var dataManager: QuoteDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var quoteText = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidGlassBackground().ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        LiquidGlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Share a Quote")
                                    .font(.headline)
                                
                                TextEditor(text: $quoteText)
                                    .frame(minHeight: 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                HStack(spacing: 8) {
                                    LiquidGlassTextField("Add tag", text: $tagInput, icon: "number")
                                    LiquidGlassButton("Add", icon: "plus", style: .accent) {
                                        addTag()
                                    }
                                }
                                
                                if !tags.isEmpty {
                                    Wrap(tags: tags)
                                }
                            }
                        }
                        
                        LiquidGlassButton("Post Quote", icon: "paperplane.fill", style: .primary, size: .large) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)) {
                                dataManager.addQuote(text: quoteText.trimmingCharacters(in: .whitespacesAndNewlines), tags: tags)
                                dismiss()
                            }
                        }
                        .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("New Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !tags.contains(trimmed) {
            tags.append(trimmed)
        }
        tagInput = ""
    }
}

#Preview {
    AddQuoteView(dataManager: QuoteDataManager())
}


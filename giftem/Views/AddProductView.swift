//
//  AddProductView.swift
//  giftem
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var productManager: ProductDataManager
    
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var productPrice = ""
    @State private var selectedCategory: ProductCategory = .electronics
    @State private var showSuccess = false
    @Namespace private var categoryNamespace
    
    var isFormValid: Bool {
        !productName.isEmpty &&
        !productDescription.isEmpty &&
        !productPrice.isEmpty &&
        Double(productPrice) != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Product image placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(height: 160)
                    
                    VStack(spacing: 10) {
                        Image(systemName: selectedCategory.symbol)
                            .font(.system(size: 48, weight: .thin))
                            .foregroundStyle(selectedCategory.color)
                        Text("Tap to add photo")
                            .font(.system(size: 13))
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Form fields
                VStack(spacing: 0) {
                    formRow {
                        TextField("Product Name", text: $productName)
                            .textInputAutocapitalization(.words)
                    }
                    
                    Divider().padding(.leading, 16)
                    
                    formRow {
                        TextField("Description", text: $productDescription, axis: .vertical)
                            .lineLimit(3...5)
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    Divider().padding(.leading, 16)
                    
                    formRow {
                        HStack {
                            Text("$")
                                .foregroundStyle(.secondary)
                            TextField("Price", text: $productPrice)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                
                // Category selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                    
                    // GlassEffectContainer allows the selected category pill to morph
                    GlassEffectContainer(spacing: 6) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(ProductCategory.allCases, id: \.self) { category in
                                    Button {
                                        withAnimation(.bouncy(duration: 0.3)) {
                                            selectedCategory = category
                                        }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 12, weight: .semibold))
                                            Text(category.rawValue)
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundStyle(selectedCategory == category ? .primary : .secondary)
                                        // Glass capsule on selected, morphs via glassEffectID
                                        .glassEffect(
                                            selectedCategory == category ? .regular : .identity,
                                            in: .capsule
                                        )
                                        .glassEffectID(selectedCategory == category ? "selectedCategory" : category.rawValue, in: categoryNamespace)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 2)
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Add button — primary action gets .glassProminent
                Button(action: addProduct) {
                    Label("Add Product", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.glassProminent)
                .tint(.purple)
                .disabled(!isFormValid)
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Add Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
        .overlay {
            if showSuccess {
                successOverlay
            }
        }
    }
    
    private func formRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                Text("Product Added!")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(36)
            .glassEffect(.regular, in: .rect(cornerRadius: 24, style: .continuous))
            .transition(.scale(scale: 0.85).combined(with: .opacity))
        }
    }
    
    private func addProduct() {
        guard let price = Double(productPrice) else { return }
        productManager.addCustomProduct(
            name: productName,
            description: productDescription,
            price: price,
            category: selectedCategory
        )
        withAnimation(.bouncy) { showSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { dismiss() }
    }
}

#Preview {
    NavigationView {
        AddProductView(productManager: ProductDataManager())
    }
}

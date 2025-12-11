//
//  AddProductView.swift
//  giftem
//
//  Created for custom product creation
//

import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var productManager: ProductDataManager
    
    // Form fields
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var productPrice = ""
    @State private var selectedCategory: ProductCategory = .electronics
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $productName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Description", text: $productDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.sentences)
                    
                    TextField("Price", text: $productPrice)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section {
                    Button(action: addProduct) {
                        HStack {
                            Spacer()
                            Text("Add Product")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Custom Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !productName.isEmpty &&
        !productDescription.isEmpty &&
        !productPrice.isEmpty &&
        Double(productPrice) != nil
    }
    
    private func addProduct() {
        guard let price = Double(productPrice) else { return }
        
        productManager.addCustomProduct(
            name: productName,
            description: productDescription,
            price: price,
            category: selectedCategory
        )
        
        dismiss()
    }
}

#Preview {
    AddProductView(productManager: ProductDataManager())
}









//
//  ProductDataManager.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import Combine

@MainActor
class ProductDataManager: ObservableObject {
    @Published var products: [Product] = []
    
    init() {
        createMockProducts()
    }
    
    private func createMockProducts() {
        products = [
            // Electronics
            Product(
                name: "Wireless AirPods Pro",
                description: "Premium noise-canceling earbuds with spatial audio and adaptive EQ. Perfect for music lovers and professionals.",
                price: 249.99,
                originalPrice: 299.99,
                imageURLs: ["airpods"],
                category: .electronics,
                sellerId: "seller1",
                rating: 4.8,
                reviewCount: 15420,
                tags: ["audio", "wireless", "premium"]
            ),
            Product(
                name: "Smart Watch Series 9",
                description: "Advanced fitness tracking, heart rate monitoring, and seamless iPhone integration. Your health companion.",
                price: 399.99,
                originalPrice: 449.99,
                imageURLs: ["smartwatch"],
                category: .electronics,
                sellerId: "seller2",
                rating: 4.9,
                reviewCount: 23410,
                tags: ["fitness", "wearable", "health"]
            ),
            
            // Fashion
            Product(
                name: "Designer Sunglasses",
                description: "UV protection sunglasses with polarized lenses. Stylish and functional for everyday wear.",
                price: 89.99,
                originalPrice: 129.99,
                imageURLs: ["sunglasses"],
                category: .fashion,
                sellerId: "seller3",
                rating: 4.6,
                reviewCount: 8765,
                tags: ["accessories", "sunglasses", "style"]
            ),
            Product(
                name: "Premium Leather Jacket",
                description: "Genuine leather jacket with soft lining. Classic style that never goes out of fashion.",
                price: 299.99,
                originalPrice: 399.99,
                imageURLs: ["jacket"],
                category: .fashion,
                sellerId: "seller4",
                rating: 4.7,
                reviewCount: 4321,
                tags: ["leather", "jacket", "classic"]
            ),
            
            // Home & Living
            Product(
                name: "Smart LED Light Strip",
                description: "Color-changing LED strips with app control. Set the perfect ambiance for any room.",
                price: 34.99,
                originalPrice: 49.99,
                imageURLs: ["ledlights"],
                category: .home,
                sellerId: "seller5",
                rating: 4.5,
                reviewCount: 12340,
                tags: ["lighting", "smart", "decoration"]
            ),
            Product(
                name: "Aromatherapy Diffuser",
                description: "Ultrasonic essential oil diffuser with 7 color LED lights. Create a relaxing atmosphere.",
                price: 29.99,
                imageURLs: ["diffuser"],
                category: .home,
                sellerId: "seller6",
                rating: 4.4,
                reviewCount: 9876,
                tags: ["wellness", "aromatherapy", "relaxation"]
            ),
            
            // Beauty
            Product(
                name: "Skincare Set - 5 Items",
                description: "Complete skincare routine with cleanser, toner, serum, moisturizer, and sunscreen.",
                price: 79.99,
                originalPrice: 119.99,
                imageURLs: ["skincare"],
                category: .beauty,
                sellerId: "seller7",
                rating: 4.8,
                reviewCount: 15670,
                tags: ["skincare", "routine", "complete"]
            ),
            
            // Sports
            Product(
                name: "Yoga Mat Premium",
                description: "Non-slip yoga mat with alignment lines. Perfect for yoga, pilates, and workouts.",
                price: 39.99,
                originalPrice: 59.99,
                imageURLs: ["yogamat"],
                category: .sports,
                sellerId: "seller8",
                rating: 4.7,
                reviewCount: 8765,
                tags: ["yoga", "fitness", "exercise"]
            ),
            Product(
                name: "Wireless Running Earbuds",
                description: "Sweat-proof earbuds with secure fit. Perfect for runners and athletes.",
                price: 59.99,
                originalPrice: 89.99,
                imageURLs: ["runningbuds"],
                category: .sports,
                sellerId: "seller9",
                rating: 4.6,
                reviewCount: 11230,
                tags: ["running", "audio", "sports"]
            ),
            
            // Toys
            Product(
                name: "Educational Robot Kit",
                description: "Build and program your own robot. Great for kids to learn coding and engineering.",
                price: 89.99,
                originalPrice: 129.99,
                imageURLs: ["robotkit"],
                category: .toys,
                sellerId: "seller10",
                rating: 4.9,
                reviewCount: 5678,
                tags: ["educational", "coding", "kids"]
            ),
            
            // Food
            Product(
                name: "Artisan Coffee Bean Set",
                description: "Premium coffee beans from around the world. 3 different varieties included.",
                price: 49.99,
                originalPrice: 69.99,
                imageURLs: ["coffee"],
                category: .food,
                sellerId: "seller11",
                rating: 4.8,
                reviewCount: 9876,
                tags: ["coffee", "gourmet", "gift"]
            )
        ]
    }
    
    func getProduct(by id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    func searchProducts(query: String) -> [Product] {
        guard !query.isEmpty else { return products }
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(query) ||
            product.description.localizedCaseInsensitiveContains(query) ||
            product.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func getProductsByCategory(_ category: ProductCategory) -> [Product] {
        return products.filter { $0.category == category }
    }
}


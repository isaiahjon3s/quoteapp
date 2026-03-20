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
    private var hasAddedCustomProduct = false  // Track if user added custom products
    
    init() {
        createMockProducts()
    }
    
    private func createMockProducts() {
        products = [
            // ============================================
            // YOUR PRODUCTS - Edit the values below!
            // ============================================
            
            // Product 1: Broken Lamp
            Product(
                name: "Broken Lamp",
                description: "Does not work but if fixed it could be a very nice lamp.",
                price: 1.99,
                originalPrice: 3.00,
                imageURLs: ["brokenlamp"],
                category: .home,
                sellerId: "my-store",
                rating: 1.8,
                reviewCount: 67,
                tags: ["lamp", "broken", "light", "vintage"]
            ),
            
            // Product 2: Rubber Duck
            Product(
                name: "Rubber Duck",
                description: "Nice rubber duck. Perfect for bath time. It was my mother's favorite.",
                price: 4.99,
                originalPrice: 7.99,
                imageURLs: ["duck"],
                category: .toys,
                sellerId: "my-store",
                rating: 4.8,
                reviewCount: 234,
                tags: ["duck", "rubber", "bath", "toy", "yellow"]
            ),
            
            // Product 3: Magic 8 Ball
            Product(
                name: "Magic 8 Ball",
                description: "Ask it any yes or no question and shake for your answer. The fortune telling toy!",
                price: 5.99,
                originalPrice: 10.09,
                imageURLs: ["8ball"],
                category: .toys,
                sellerId: "my-store",
                rating: 4.5,
                reviewCount: 156,
                tags: ["8ball", "magic", "fortune", "toy", "game"]
            ),
            
            // Product 4: Vintage Polaroid Camera
            Product(
                name: "Vintage Polaroid Camera",
                description: "Capture memories instantly with this retro-style instant camera. Prints 3.5x4.25\" photos in seconds. Perfect gift for any photography enthusiast.",
                price: 79.99,
                originalPrice: 99.99,
                imageURLs: [],
                category: .electronics,
                sellerId: "my-store",
                rating: 4.7,
                reviewCount: 412,
                tags: ["camera", "polaroid", "instant", "retro", "photography", "gift"]
            ),
            
            // Product 5: Cozy Weighted Blanket
            Product(
                name: "Weighted Blanket (15 lbs)",
                description: "Melt away stress and anxiety with this ultra-soft weighted blanket. Deep touch pressure stimulation helps you fall asleep faster and stay asleep longer.",
                price: 59.95,
                originalPrice: 89.95,
                imageURLs: [],
                category: .home,
                sellerId: "my-store",
                rating: 4.9,
                reviewCount: 1823,
                tags: ["blanket", "weighted", "sleep", "anxiety", "cozy", "comfort"]
            ),
            
            // Product 6: Artisan Coffee Subscription
            Product(
                name: "Artisan Coffee Subscription (3 mo)",
                description: "Freshly roasted single-origin beans delivered to your door every two weeks. Three different roasters, six unique blends, endlessly delicious.",
                price: 54.00,
                originalPrice: 72.00,
                imageURLs: [],
                category: .food,
                sellerId: "my-store",
                rating: 4.8,
                reviewCount: 639,
                tags: ["coffee", "subscription", "artisan", "roasted", "gift", "beverage"]
            ),
            
            // Product 7: Leather Journaling Set
            Product(
                name: "Leather Journaling Set",
                description: "Handcrafted genuine leather journal with 200 acid-free pages, a ballpoint pen, and brass bookmark. A timeless gift for writers and dreamers alike.",
                price: 34.99,
                imageURLs: [],
                category: .books,
                sellerId: "my-store",
                rating: 4.6,
                reviewCount: 287,
                tags: ["journal", "leather", "writing", "notebook", "handcrafted", "gift"]
            ),
            
            // Product 8: Wireless Charging Pad
            Product(
                name: "3-in-1 Wireless Charging Station",
                description: "Charge your phone, earbuds, and smartwatch simultaneously with this sleek MagSafe-compatible charging station. Works with all Qi-enabled devices.",
                price: 44.99,
                originalPrice: 59.99,
                imageURLs: [],
                category: .electronics,
                sellerId: "my-store",
                rating: 4.4,
                reviewCount: 891,
                tags: ["charging", "wireless", "magsafe", "qi", "station", "tech"]
            ),
            
            // Product 9: Succulent Garden Kit
            Product(
                name: "DIY Succulent Garden Kit",
                description: "Everything you need to grow your own mini succulent garden: six starter plants, ceramic pots, specialty soil, and a care guide. No green thumb required!",
                price: 29.99,
                originalPrice: 39.99,
                imageURLs: [],
                category: .home,
                sellerId: "my-store",
                rating: 4.7,
                reviewCount: 543,
                tags: ["succulent", "plant", "garden", "diy", "kit", "decor"]
            ),
            
            // Product 10: Silk Skincare Set
            Product(
                name: "Luxury Silk Skincare Set",
                description: "A complete skincare ritual in one gift box: silk pillowcase, rose quartz roller, vitamin C serum, and overnight hydrating mask. Glow up starts here.",
                price: 68.00,
                originalPrice: 95.00,
                imageURLs: [],
                category: .beauty,
                sellerId: "my-store",
                rating: 4.8,
                reviewCount: 1104,
                tags: ["skincare", "silk", "serum", "glow", "beauty", "luxury"]
            ),
            
            // Product 11: Foldable Yoga Mat
            Product(
                name: "Foldable Travel Yoga Mat",
                description: "2mm ultra-thin, foldable yoga mat that fits in any bag. Non-slip surface, sweat-resistant, and eco-friendly. Your practice, anywhere.",
                price: 38.00,
                imageURLs: [],
                category: .sports,
                sellerId: "my-store",
                rating: 4.5,
                reviewCount: 376,
                tags: ["yoga", "mat", "travel", "foldable", "fitness", "eco"]
            ),
            
            // Product 12: Retro Neon Sign
            Product(
                name: "Custom LED Neon Sign",
                description: "Personalize your space with a hand-bent LED neon sign. Choose your text, font, and color. Energy-efficient, dimmable, and ships in 5–7 days.",
                price: 89.00,
                originalPrice: 120.00,
                imageURLs: [],
                category: .home,
                sellerId: "my-store",
                rating: 4.6,
                reviewCount: 728,
                tags: ["neon", "sign", "led", "custom", "decor", "personalized"]
            ),
            
            // ============================================
            // ADD MORE PRODUCTS BELOW using this template:
            // ============================================
            /*
            Product(
                name: "Your Product Name",
                description: "Your product description",
                price: 9.99,
                originalPrice: 14.99,  // Optional - remove for no discount
                imageURLs: ["your-image-name"],  // Must match Assets name exactly
                category: .home,  // Options: .electronics, .fashion, .home, .beauty, .sports, .books, .toys, .food, .other
                sellerId: "my-store",
                rating: 5.0,
                reviewCount: 10,
                tags: ["tag1", "tag2"]
            ),
            */
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
    
    // Add custom product to the feed
    func addCustomProduct(
        name: String,
        description: String,
        price: Double,
        category: ProductCategory,
        originalPrice: Double? = nil
    ) {
        // Clear mock products when adding first custom product
        if !hasAddedCustomProduct {
            products.removeAll()
            hasAddedCustomProduct = true
        }
        
        let newProduct = Product(
            name: name,
            description: description,
            price: price,
            originalPrice: originalPrice,
            imageURLs: ["custom"],
            category: category,
            sellerId: "custom-seller",
            rating: 5.0,
            reviewCount: 0,
            tags: ["custom", "new"]
        )
        
        // Add to beginning of products array so it appears at top
        products.insert(newProduct, at: 0)
    }
    
    // Optional: Clear all products and start fresh
    func clearAllProducts() {
        products.removeAll()
        hasAddedCustomProduct = false
    }
    
    // Optional: Reset to mock products
    func resetToMockProducts() {
        hasAddedCustomProduct = false
        createMockProducts()
    }
}


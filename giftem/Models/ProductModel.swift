//
//  ProductModel.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import SwiftUI

// MARK: - Product Model
struct Product: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let originalPrice: Double?
    let currency: String
    let imageURLs: [String]
    let category: ProductCategory
    let sellerId: String
    let rating: Double
    let reviewCount: Int
    let isAvailable: Bool
    let tags: [String]
    
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    
    var formattedPrice: String {
        String(format: "%.2f", price)
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        price: Double,
        originalPrice: Double? = nil,
        currency: String = "USD",
        imageURLs: [String],
        category: ProductCategory,
        sellerId: String,
        rating: Double = 0.0,
        reviewCount: Int = 0,
        isAvailable: Bool = true,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.originalPrice = originalPrice
        self.currency = currency
        self.imageURLs = imageURLs
        self.category = category
        self.sellerId = sellerId
        self.rating = rating
        self.reviewCount = reviewCount
        self.isAvailable = isAvailable
        self.tags = tags
    }
}

// MARK: - Product Category
enum ProductCategory: String, Codable, CaseIterable {
    case electronics = "Electronics"
    case fashion = "Fashion"
    case home = "Home & Living"
    case beauty = "Beauty"
    case sports = "Sports & Outdoors"
    case books = "Books"
    case toys = "Toys & Games"
    case food = "Food & Beverage"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .electronics: return "iphone"
        case .fashion: return "tshirt.fill"
        case .home: return "house.fill"
        case .beauty: return "sparkles"
        case .sports: return "figure.run"
        case .books: return "book.fill"
        case .toys: return "gamecontroller.fill"
        case .food: return "fork.knife"
        case .other: return "square.grid.2x2"
        }
    }
    
    // Consistent color used across all views
    var color: Color {
        switch self {
        case .electronics: return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .fashion: return Color(red: 0.9, green: 0.4, blue: 0.5)
        case .home: return Color(red: 0.4, green: 0.7, blue: 0.5)
        case .beauty: return Color(red: 0.9, green: 0.6, blue: 0.7)
        case .sports: return Color(red: 0.3, green: 0.7, blue: 0.9)
        case .books: return Color(red: 0.6, green: 0.4, blue: 0.3)
        case .toys: return Color(red: 0.9, green: 0.7, blue: 0.3)
        case .food: return Color(red: 0.8, green: 0.5, blue: 0.3)
        case .other: return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }
    
    // Consistent SF Symbol used across all views
    var symbol: String {
        switch self {
        case .electronics: return "airpodspro"
        case .fashion: return "tshirt"
        case .home: return "lamp.floor"
        case .beauty: return "sparkles"
        case .sports: return "figure.run"
        case .books: return "book"
        case .toys: return "gamecontroller"
        case .food: return "cup.and.saucer"
        case .other: return "square.grid.2x2"
        }
    }
}










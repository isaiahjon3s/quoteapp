//
//  CartModel.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation

// MARK: - Cart Item Model
struct CartItem: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let quantity: Int
    let isForGift: Bool
    let giftRecipientId: String? // If buying for someone else
    
    init(
        id: String = UUID().uuidString,
        productId: String,
        quantity: Int = 1,
        isForGift: Bool = false,
        giftRecipientId: String? = nil
    ) {
        self.id = id
        self.productId = productId
        self.quantity = quantity
        self.isForGift = isForGift
        self.giftRecipientId = giftRecipientId
    }
}

// MARK: - Wishlist Item Model
struct WishlistItem: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let addedAt: Date
    
    init(
        id: String = UUID().uuidString,
        productId: String,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.productId = productId
        self.addedAt = addedAt
    }
}







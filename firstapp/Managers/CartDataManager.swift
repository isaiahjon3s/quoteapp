//
//  CartDataManager.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import Combine

@MainActor
class CartDataManager: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var wishlistItems: [WishlistItem] = []
    
    private let productManager: ProductDataManager
    
    init(productManager: ProductDataManager) {
        self.productManager = productManager
    }
    
    var totalPrice: Double {
        cartItems.compactMap { item in
            guard let product = productManager.getProduct(by: item.productId) else { return nil }
            return product.price * Double(item.quantity)
        }.reduce(0, +)
    }
    
    func addToCart(productId: String, quantity: Int = 1, isForGift: Bool = false, giftRecipientId: String? = nil) {
        if let existingIndex = cartItems.firstIndex(where: { $0.productId == productId && $0.isForGift == isForGift }) {
            // Update quantity if item already exists
            let existingItem = cartItems[existingIndex]
            cartItems[existingIndex] = CartItem(
                id: existingItem.id,
                productId: existingItem.productId,
                quantity: existingItem.quantity + quantity,
                isForGift: existingItem.isForGift,
                giftRecipientId: existingItem.giftRecipientId
            )
        } else {
            // Add new item
            let newItem = CartItem(
                productId: productId,
                quantity: quantity,
                isForGift: isForGift,
                giftRecipientId: giftRecipientId
            )
            cartItems.append(newItem)
        }
    }
    
    func removeFromCart(itemId: String) {
        cartItems.removeAll { $0.id == itemId }
    }
    
    func updateQuantity(for itemId: String, quantity: Int) {
        guard let index = cartItems.firstIndex(where: { $0.id == itemId }) else { return }
        let item = cartItems[index]
        if quantity > 0 {
            cartItems[index] = CartItem(
                id: item.id,
                productId: item.productId,
                quantity: quantity,
                isForGift: item.isForGift,
                giftRecipientId: item.giftRecipientId
            )
        } else {
            removeFromCart(itemId: itemId)
        }
    }
    
    func addToWishlist(productId: String) {
        if !wishlistItems.contains(where: { $0.productId == productId }) {
            let newItem = WishlistItem(productId: productId)
            wishlistItems.append(newItem)
        }
    }
    
    func removeFromWishlist(productId: String) {
        wishlistItems.removeAll { $0.productId == productId }
    }
    
    func isInWishlist(productId: String) -> Bool {
        return wishlistItems.contains { $0.productId == productId }
    }
}


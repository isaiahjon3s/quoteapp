//
//  PostModel.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation

// MARK: - Post Model
struct Post: Identifiable, Codable, Hashable {
    let id: String
    let productId: String
    let userId: String
    let caption: String
    let createdAt: Date
    let likeCount: Int
    let commentCount: Int
    let isLiked: Bool
    
    init(
        id: String = UUID().uuidString,
        productId: String,
        userId: String,
        caption: String,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        commentCount: Int = 0,
        isLiked: Bool = false
    ) {
        self.id = id
        self.productId = productId
        self.userId = userId
        self.caption = caption
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.isLiked = isLiked
    }
}







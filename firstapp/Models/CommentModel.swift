//
//  CommentModel.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation

// MARK: - Comment Model
struct Comment: Identifiable, Codable, Hashable {
    let id: String
    let postId: String
    let userId: String
    let text: String
    let createdAt: Date
    let likeCount: Int
    let isLiked: Bool
    let parentCommentId: String? // For nested comments/replies
    
    init(
        id: String = UUID().uuidString,
        postId: String,
        userId: String,
        text: String,
        createdAt: Date = Date(),
        likeCount: Int = 0,
        isLiked: Bool = false,
        parentCommentId: String? = nil
    ) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.text = text
        self.createdAt = createdAt
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.parentCommentId = parentCommentId
    }
}







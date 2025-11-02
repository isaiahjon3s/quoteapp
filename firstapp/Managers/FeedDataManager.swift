//
//  FeedDataManager.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import Combine

@MainActor
class FeedDataManager: ObservableObject {
    @Published var posts: [Post] = []
    
    private let productManager: ProductDataManager
    private let userManager: UserDataManager
    
    init(productManager: ProductDataManager, userManager: UserDataManager) {
        self.productManager = productManager
        self.userManager = userManager
        createMockPosts()
    }
    
    private func createMockPosts() {
        let products = productManager.products
        let users = userManager.users
        
        posts = [
            Post(
                productId: products[0].id,
                userId: users[0].id,
                caption: "Just got these AirPods Pro and they're amazing! The noise cancellation is incredible 🎧✨",
                createdAt: Date().addingTimeInterval(-3600),
                likeCount: 1245,
                commentCount: 89,
                isLiked: false
            ),
            Post(
                productId: products[1].id,
                userId: users[1].id,
                caption: "Love my new smartwatch! The fitness tracking features are so detailed 📊💪",
                createdAt: Date().addingTimeInterval(-7200),
                likeCount: 892,
                commentCount: 67,
                isLiked: true
            ),
            Post(
                productId: products[2].id,
                userId: users[2].id,
                caption: "Perfect sunglasses for summer! Great quality and they look so stylish 😎",
                createdAt: Date().addingTimeInterval(-10800),
                likeCount: 567,
                commentCount: 34,
                isLiked: false
            ),
            Post(
                productId: products[3].id,
                userId: users[3].id,
                caption: "This leather jacket is my new favorite! So comfortable and well-made 🧥",
                createdAt: Date().addingTimeInterval(-14400),
                likeCount: 1234,
                commentCount: 92,
                isLiked: true
            ),
            Post(
                productId: products[4].id,
                userId: users[4].id,
                caption: "My room looks amazing with these LED lights! The colors are so vibrant 🌈",
                createdAt: Date().addingTimeInterval(-18000),
                likeCount: 789,
                commentCount: 45,
                isLiked: false
            ),
            Post(
                productId: products[5].id,
                userId: users[5].id,
                caption: "This diffuser has changed my sleep routine. So relaxing! 😴✨",
                createdAt: Date().addingTimeInterval(-21600),
                likeCount: 634,
                commentCount: 38,
                isLiked: true
            ),
            Post(
                productId: products[6].id,
                userId: users[0].id,
                caption: "Best skincare routine I've tried! My skin has never looked better 💆‍♀️",
                createdAt: Date().addingTimeInterval(-25200),
                likeCount: 2156,
                commentCount: 156,
                isLiked: false
            ),
            Post(
                productId: products[7].id,
                userId: users[4].id,
                caption: "Perfect yoga mat for my daily practice. The grip is excellent 🧘‍♀️",
                createdAt: Date().addingTimeInterval(-28800),
                likeCount: 456,
                commentCount: 29,
                isLiked: false
            )
        ]
    }
    
    func toggleLike(for postId: String) {
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let post = posts[index]
        posts[index] = Post(
            id: post.id,
            productId: post.productId,
            userId: post.userId,
            caption: post.caption,
            createdAt: post.createdAt,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
            commentCount: post.commentCount,
            isLiked: !post.isLiked
        )
    }
    
    func getPostsForUser(_ userId: String) -> [Post] {
        return posts.filter { $0.userId == userId }
    }
    
    func getPost(by id: String) -> Post? {
        return posts.first { $0.id == id }
    }
}


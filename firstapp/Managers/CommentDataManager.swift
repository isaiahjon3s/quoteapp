//
//  CommentDataManager.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import Combine

@MainActor
class CommentDataManager: ObservableObject {
    @Published var comments: [String: [Comment]] = [:] // postId: [comments]
    
    private let userManager: UserDataManager
    
    init(userManager: UserDataManager) {
        self.userManager = userManager
        createMockComments()
    }
    
    private func createMockComments() {
        let users = userManager.users
        
        // Mock comments for different posts
        comments = [
            "post1": [
                Comment(
                    postId: "post1",
                    userId: users[1].id,
                    text: "I've been wanting these! How's the battery life?",
                    createdAt: Date().addingTimeInterval(-3000),
                    likeCount: 45,
                    isLiked: false
                ),
                Comment(
                    postId: "post1",
                    userId: users[2].id,
                    text: "The spatial audio is game-changing! 🎵",
                    createdAt: Date().addingTimeInterval(-2800),
                    likeCount: 32,
                    isLiked: true
                ),
                Comment(
                    postId: "post1",
                    userId: users[3].id,
                    text: "Perfect for my daily commute!",
                    createdAt: Date().addingTimeInterval(-2600),
                    likeCount: 18,
                    isLiked: false
                )
            ],
            "post2": [
                Comment(
                    postId: "post2",
                    userId: users[0].id,
                    text: "Which fitness features do you use most?",
                    createdAt: Date().addingTimeInterval(-6800),
                    likeCount: 28,
                    isLiked: false
                ),
                Comment(
                    postId: "post2",
                    userId: users[3].id,
                    text: "Love the heart rate monitoring! ❤️",
                    createdAt: Date().addingTimeInterval(-6500),
                    likeCount: 41,
                    isLiked: true
                )
            ],
            "post3": [
                Comment(
                    postId: "post3",
                    userId: users[1].id,
                    text: "So stylish! Where did you get them?",
                    createdAt: Date().addingTimeInterval(-10400),
                    likeCount: 22,
                    isLiked: false
                )
            ],
            "post4": [
                Comment(
                    postId: "post4",
                    userId: users[2].id,
                    text: "This looks so classy! 😍",
                    createdAt: Date().addingTimeInterval(-14000),
                    likeCount: 67,
                    isLiked: true
                ),
                Comment(
                    postId: "post4",
                    userId: users[4].id,
                    text: "Is it warm enough for winter?",
                    createdAt: Date().addingTimeInterval(-13500),
                    likeCount: 15,
                    isLiked: false
                )
            ]
        ]
    }
    
    func getComments(for postId: String) -> [Comment] {
        return comments[postId] ?? []
    }
    
    func addComment(to postId: String, text: String) {
        guard let currentUser = userManager.currentUser else { return }
        
        let newComment = Comment(
            postId: postId,
            userId: currentUser.id,
            text: text,
            createdAt: Date(),
            likeCount: 0,
            isLiked: false
        )
        
        if comments[postId] == nil {
            comments[postId] = []
        }
        comments[postId]?.append(newComment)
    }
    
    func toggleLike(for commentId: String, in postId: String) {
        guard let index = comments[postId]?.firstIndex(where: { $0.id == commentId }) else { return }
        let comment = comments[postId]![index]
        
        comments[postId]![index] = Comment(
            id: comment.id,
            postId: comment.postId,
            userId: comment.userId,
            text: comment.text,
            createdAt: comment.createdAt,
            likeCount: comment.isLiked ? comment.likeCount - 1 : comment.likeCount + 1,
            isLiked: !comment.isLiked,
            parentCommentId: comment.parentCommentId
        )
    }
}


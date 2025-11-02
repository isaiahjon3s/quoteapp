//
//  CommentsView.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct CommentsView: View {
    let postId: String
    @ObservedObject var commentManager: CommentDataManager
    @ObservedObject var userManager: UserDataManager
    
    @State private var newCommentText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var comments: [Comment] {
        commentManager.getComments(for: postId)
    }
    
    var body: some View {
        LiquidGlassBackground {
            VStack(spacing: 0) {
                // Comments List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        if comments.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "message")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("No comments yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Be the first to comment!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            ForEach(comments) { comment in
                                CommentRow(
                                    comment: comment,
                                    commentManager: commentManager,
                                    userManager: userManager
                                )
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Comment Input
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        if let currentUser = userManager.currentUser {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.caption)
                                )
                        }
                        
                        LiquidGlassTextField(
                            "Add a comment...",
                            text: $newCommentText
                        )
                        .frame(height: 40)
                        
                        Button(action: {
                            addComment()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(newCommentText.isEmpty ? .secondary : .blue)
                        }
                        .disabled(newCommentText.isEmpty)
                    }
                    .padding(16)
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        commentManager.addComment(to: postId, text: newCommentText)
        newCommentText = ""
        isTextFieldFocused = false
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    @ObservedObject var commentManager: CommentDataManager
    @ObservedObject var userManager: UserDataManager
    
    var user: User? {
        userManager.getUser(by: comment.userId)
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: comment.createdAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile Image
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // User Info
                HStack(spacing: 6) {
                    Text(user?.displayName ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if user?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption2)
                    }
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Comment Text
                Text(comment.text)
                    .font(.body)
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        commentManager.toggleLike(for: comment.id, in: comment.postId)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .font(.caption)
                                .foregroundColor(comment.isLiked ? .red : .secondary)
                            if comment.likeCount > 0 {
                                Text("\(comment.likeCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        Text("Reply")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        CommentsView(
            postId: "post1",
            commentManager: CommentDataManager(userManager: UserDataManager()),
            userManager: UserDataManager()
        )
    }
}


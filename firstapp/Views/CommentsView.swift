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
        VStack(spacing: 0) {
            // Comments List
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if comments.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "message")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No comments yet")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("Be the first to comment!")
                                .font(.system(size: 14))
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
                .padding(16)
            }
            .background(Color(.systemBackground))
            
            // Comment Input
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    if let currentUser = userManager.currentUser {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .medium))
                            )
                    }
                    
                    TextField("Add a comment...", text: $newCommentText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {
                        addComment()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(newCommentText.isEmpty ? .secondary : .blue)
                    }
                    .disabled(newCommentText.isEmpty)
                }
                .padding(12)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
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
                        colors: [Color(red: 0.26, green: 0.46, blue: 0.78), Color(red: 0.49, green: 0.36, blue: 0.89)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // User Info
                HStack(spacing: 6) {
                    Text(user?.displayName ?? "Unknown")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if user?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 10))
                    }
                    
                    Text(timeAgo)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Comment Text
                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        commentManager.toggleLike(for: comment.id, in: comment.postId)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: comment.isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 12))
                                .foregroundColor(comment.isLiked ? .red : .secondary)
                            if comment.likeCount > 0 {
                                Text("\(comment.likeCount)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        Text("Reply")
                            .font(.system(size: 12, weight: .medium))
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


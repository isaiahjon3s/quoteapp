//
//  UserDataManager.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class UserDataManager: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    
    init() {
        createMockUsers()
        // Set first user as current user
        currentUser = users.first
    }
    
    private func createMockUsers() {
        users = [
            User(
                username: "alex_wonder",
                displayName: "Alex Wonder",
                profileImageURL: nil,
                bio: "Tech enthusiast & gadget collector 🚀",
                followerCount: 12450,
                followingCount: 892,
                postCount: 342,
                isVerified: true
            ),
            User(
                username: "sarah_style",
                displayName: "Sarah Peterson",
                profileImageURL: nil,
                bio: "Fashion lover | Sharing my finds ✨",
                followerCount: 8760,
                followingCount: 645,
                postCount: 218,
                isVerified: true
            ),
            User(
                username: "mike_gadgets",
                displayName: "Mike Rodriguez",
                profileImageURL: nil,
                bio: "Reviewing the latest tech 📱",
                followerCount: 5420,
                followingCount: 234,
                postCount: 156,
                isVerified: false
            ),
            User(
                username: "emma_home",
                displayName: "Emma Wilson",
                profileImageURL: nil,
                bio: "Home decor enthusiast 🏠",
                followerCount: 3210,
                followingCount: 456,
                postCount: 89,
                isVerified: false
            ),
            User(
                username: "mamapeters75",
                displayName: "Fran Peters",
                profileImageURL: nil,
                bio: "I really love my dogs and my son!",
                followerCount: 140,
                followingCount: 234,
                postCount: 267,
                isVerified: false
            ),
            User(
                username: "lisa_beauty",
                displayName: "Lisa Thompson",
                profileImageURL: nil,
                bio: "Beauty products & skincare routine 💄",
                followerCount: 15230,
                followingCount: 789,
                postCount: 445,
                isVerified: true
            )
        ]
    }
    
    func getUser(by id: String) -> User? {
        return users.first { $0.id == id }
    }
    
    func followUser(_ userId: String) {
        guard var user = users.first(where: { $0.id == userId }),
              var current = currentUser else { return }
        
        // In a real app, this would make an API call
        user = User(
            id: user.id,
            username: user.username,
            displayName: user.displayName,
            profileImageURL: user.profileImageURL,
            bio: user.bio,
            followerCount: user.followerCount + 1,
            followingCount: user.followingCount,
            postCount: user.postCount,
            isVerified: user.isVerified
        )
        
        current = User(
            id: current.id,
            username: current.username,
            displayName: current.displayName,
            profileImageURL: current.profileImageURL,
            bio: current.bio,
            followerCount: current.followerCount,
            followingCount: current.followingCount + 1,
            postCount: current.postCount,
            isVerified: current.isVerified
        )
        
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index] = user
        }
        currentUser = current
    }
}


//
//  UserModel.swift
//  giftem
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation

// MARK: - User Model
struct User: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let profileImageURL: String?
    let bio: String?
    let followerCount: Int
    let followingCount: Int
    let postCount: Int
    let isVerified: Bool
    
    init(
        id: String = UUID().uuidString,
        username: String,
        displayName: String,
        profileImageURL: String? = nil,
        bio: String? = nil,
        followerCount: Int = 0,
        followingCount: Int = 0,
        postCount: Int = 0,
        isVerified: Bool = false
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.postCount = postCount
        self.isVerified = isVerified
    }
}







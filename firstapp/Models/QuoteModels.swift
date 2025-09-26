//
//  QuoteModels.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import SwiftUI

struct UserProfile: Identifiable, Codable, Hashable {
    var id: UUID
    var username: String
    var displayName: String
    var bio: String
    var avatarSystemImageName: String
    var joinedAt: Date
    var favoriteAuthorIds: [UUID]
    
    init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        bio: String = "",
        avatarSystemImageName: String = "person.circle.fill",
        joinedAt: Date = Date(),
        favoriteAuthorIds: [UUID] = []
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.avatarSystemImageName = avatarSystemImageName
        self.joinedAt = joinedAt
        self.favoriteAuthorIds = favoriteAuthorIds
    }
}

struct Quote: Identifiable, Codable, Hashable {
    var id: UUID
    var authorId: UUID
    var authorDisplayName: String
    var text: String
    var tags: [String]
    var createdAt: Date
    var likeUserIds: [UUID]
    var bookmarkUserIds: [UUID]
    
    init(
        id: UUID = UUID(),
        authorId: UUID,
        authorDisplayName: String,
        text: String,
        tags: [String] = [],
        createdAt: Date = Date(),
        likeUserIds: [UUID] = [],
        bookmarkUserIds: [UUID] = []
    ) {
        self.id = id
        self.authorId = authorId
        self.authorDisplayName = authorDisplayName
        self.text = text
        self.tags = tags
        self.createdAt = createdAt
        self.likeUserIds = likeUserIds
        self.bookmarkUserIds = bookmarkUserIds
    }
}

extension Quote {
    var likeCount: Int { likeUserIds.count }
    var bookmarkCount: Int { bookmarkUserIds.count }
}

struct QuoteTagStat: Codable, Hashable, Identifiable {
    var id: String { tag }
    let tag: String
    let count: Int
}


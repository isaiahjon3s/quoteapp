//
//  QuoteDataManager.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import Combine

final class QuoteDataManager: ObservableObject {
    @Published private(set) var profiles: [UserProfile] = []
    @Published private(set) var quotes: [Quote] = []
    @Published var currentUser: UserProfile?
    
    private let defaults = UserDefaults.standard
    private let quotesKey = "SavedQuotes"
    private let profilesKey = "SavedProfiles"
    private let currentUserKey = "CurrentUserId"
    
    init() {
        load()
        if profiles.isEmpty || quotes.isEmpty {
            loadSampleData()
            save()
        }
        if currentUser == nil { currentUser = profiles.first }
    }
    
    // MARK: - Public API
    
    func addQuote(text: String, tags: [String]) {
        guard let user = currentUser else { return }
        let quote = Quote(authorId: user.id, authorDisplayName: user.displayName, text: text, tags: tags)
        quotes.insert(quote, at: 0)
        saveQuotes()
    }
    
    func likeQuote(_ quote: Quote) {
        guard let user = currentUser else { return }
        guard let index = quotes.firstIndex(where: { $0.id == quote.id }) else { return }
        var updated = quotes[index]
        if let likeIndex = updated.likeUserIds.firstIndex(of: user.id) {
            updated.likeUserIds.remove(at: likeIndex)
        } else {
            updated.likeUserIds.append(user.id)
        }
        quotes[index] = updated
        saveQuotes()
    }
    
    func quotesForUser(_ userId: UUID) -> [Quote] {
        quotes.filter { $0.authorId == userId }
    }
    
    func profile(for id: UUID) -> UserProfile? {
        profiles.first { $0.id == id }
    }
    
    func updateCurrentUser(displayName: String, bio: String, avatarSystemImageName: String) {
        guard var user = currentUser, let idx = profiles.firstIndex(where: { $0.id == user.id }) else { return }
        user.displayName = displayName
        user.bio = bio
        user.avatarSystemImageName = avatarSystemImageName
        profiles[idx] = user
        currentUser = user
        saveProfiles()
    }
    
    // MARK: - Persistence
    
    private func save() {
        saveQuotes()
        saveProfiles()
    }
    
    private func saveQuotes() {
        if let data = try? JSONEncoder().encode(quotes) {
            defaults.set(data, forKey: quotesKey)
        }
    }
    
    private func saveProfiles() {
        if let data = try? JSONEncoder().encode(profiles) {
            defaults.set(data, forKey: profilesKey)
        }
        if let userId = currentUser?.id.uuidString {
            defaults.set(userId, forKey: currentUserKey)
        }
    }
    
    private func load() {
        if let qData = defaults.data(forKey: quotesKey), let decoded = try? JSONDecoder().decode([Quote].self, from: qData) {
            quotes = decoded.sorted { $0.createdAt > $1.createdAt }
        }
        if let pData = defaults.data(forKey: profilesKey), let decoded = try? JSONDecoder().decode([UserProfile].self, from: pData) {
            profiles = decoded
        }
        if let idStr = defaults.string(forKey: currentUserKey), let id = UUID(uuidString: idStr) {
            currentUser = profiles.first { $0.id == id }
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        let isaiah = UserProfile(username: "isaiah", displayName: "Isaiah Jones", bio: "Love code. Love quotes.", avatarSystemImageName: "person.fill")
        let maya = UserProfile(username: "maya", displayName: "Maya Patel", bio: "Building daily. Reading nightly.", avatarSystemImageName: "leaf.fill")
        let liam = UserProfile(username: "liam", displayName: "Liam Chen", bio: "Coffee-powered dev.", avatarSystemImageName: "bolt.fill")
        profiles = [isaiah, maya, liam]
        currentUser = isaiah
        
        quotes = [
            Quote(authorId: isaiah.id, authorDisplayName: isaiah.displayName, text: "Ship, learn, iterate.", tags: ["build", "learn"]),
            Quote(authorId: maya.id, authorDisplayName: maya.displayName, text: "Small steps. Big outcomes.", tags: ["growth"]),
            Quote(authorId: liam.id, authorDisplayName: liam.displayName, text: "Focus is a superpower.", tags: ["focus"]),
            Quote(authorId: isaiah.id, authorDisplayName: isaiah.displayName, text: "Consistency beats intensity.", tags: ["habits"])
        ]
    }
}


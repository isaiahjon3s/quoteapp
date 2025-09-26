//
//  ProfileQuotesView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct ProfileQuotesView: View {
    let profile: UserProfile
    @ObservedObject var dataManager: QuoteDataManager
    @State private var showingEdit = false
    
    private var userQuotes: [Quote] { dataManager.quotesForUser(profile.id) }
    
    var body: some View {
        LiquidGlassBackground {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileHeader(
                        profile: profile,
                        isCurrentUser: dataManager.currentUser?.id == profile.id,
                        isFavorite: dataManager.isFavoriteAuthor(profile.id),
                        quoteCount: userQuotes.count,
                        uniqueTagCount: Set(userQuotes.flatMap { $0.tags }).count,
                        onFavoriteToggle: {
                            dataManager.toggleFavoriteAuthor(profile)
                        },
                        onEdit: {
                            showingEdit = true
                        }
                    )
                    .padding(.horizontal)
                    
                    ForEach(userQuotes) { quote in
                        QuoteCard(
                            quote: quote,
                            isLiked: dataManager.isQuoteLiked(quote),
                            isBookmarked: dataManager.isQuoteBookmarked(quote),
                            onLike: { dataManager.likeQuote(quote) },
                            onBookmark: { dataManager.toggleBookmark(quote) }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 100)
            }
            .navigationTitle(profile.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            if let current = dataManager.currentUser, current.id == profile.id {
                EditProfileView(dataManager: dataManager)
            }
        }
    }
}

struct ProfileHeader: View {
    let profile: UserProfile
    let isCurrentUser: Bool
    let isFavorite: Bool
    let quoteCount: Int
    let uniqueTagCount: Int
    let onFavoriteToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: profile.avatarSystemImageName)
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(profile.displayName)
                                .font(.title3.weight(.bold))
                            if !isCurrentUser {
                                Button(action: onFavoriteToggle) {
                                    Image(systemName: isFavorite ? "heart.circle.fill" : "heart.circle")
                                        .symbolRenderingMode(.multicolor)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Text("@\(profile.username)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if !profile.bio.isEmpty {
                            Text(profile.bio)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        Text("Joined \(profile.joinedAt, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if isCurrentUser {
                        LiquidGlassButton("Edit", icon: "pencil") {
                            onEdit()
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    ProfileStatChip(icon: "quote.opening", title: "Quotes", value: "\(quoteCount)")
                    ProfileStatChip(icon: "heart.fill", title: "Favorites", value: "\(profile.favoriteAuthorIds.count)")
                    ProfileStatChip(icon: "number", title: "Tags", value: "\(uniqueTagCount)")
                }
            }
        }
    }
}

struct ProfileStatChip: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.footnote.weight(.bold))
                .foregroundColor(.blue)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

struct EditProfileView: View {
    @ObservedObject var dataManager: QuoteDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var avatar: String = "person.circle.fill"
    
    var body: some View {
        NavigationView {
            LiquidGlassBackground {
                ScrollView {
                    VStack(spacing: 16) {
                        LiquidGlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Edit Profile")
                                    .font(.headline)
                                
                                LiquidGlassTextField("Display Name", text: $displayName, icon: "textformat")
                                LiquidGlassTextField("Bio", text: $bio, icon: "text.justify")
                                
                                HStack(spacing: 8) {
                                    ForEach(["person.circle.fill","leaf.fill","bolt.fill","star.fill","flame.fill"], id: \.self) { name in
                                        Button(action: { avatar = name }) {
                                            Image(systemName: name)
                                                .font(.title3)
                                                .foregroundColor(avatar == name ? .blue : .secondary)
                                                .frame(width: 44, height: 44)
                                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        LiquidGlassButton("Save", icon: "checkmark.circle.fill", style: .primary, size: .large) {
                            dataManager.updateCurrentUser(displayName: displayName, bio: bio, avatarSystemImageName: avatar)
                            dismiss()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            }
        }
        .onAppear {
            if let user = dataManager.currentUser {
                displayName = user.displayName
                bio = user.bio
                avatar = user.avatarSystemImageName
            }
        }
    }
}

}

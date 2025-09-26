//
//  QuoteFeedView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct QuoteFeedView: View {
    @StateObject private var dataManager = QuoteDataManager()
    @State private var showingAdd = false
    @State private var searchText = ""
    @State private var selectedTag: String? = nil
    @State private var likeThreshold: Double = 0
    @State private var showFavorites = false
    
    private var filteredQuotes: [Quote] {
        var items = dataManager.quotes
        if let tag = selectedTag {
            items = items.filter { $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(tag) }) }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.text.localizedCaseInsensitiveContains(searchText) || $0.authorDisplayName.localizedCaseInsensitiveContains(searchText) }
        }
        if likeThreshold > 0 {
            items = items.filter { Double($0.likeCount) >= likeThreshold }
        }
        return items
    }
    
    private var trendingTags: [String] {
        let allTags = dataManager.quotes.flatMap { $0.tags }
        let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.map { $0.key }.prefix(8).map { $0 }
    }
    
    private var favorites: [Quote] {
        dataManager.favoriteQuotes()
    }
    
    private var dailyInspiration: Quote? {
        dataManager.dailyInspirationQuote()
    }
    
    private var trendingQuotes: [Quote] {
        dataManager.trendingQuotes(limit: 5)
    }
    
    private var tagStats: [QuoteTagStat] {
        Array(dataManager.tagStats().prefix(6))
    }
    
    var body: some View {
        NavigationView {
            LiquidGlassBackground {
                ScrollView {
                    VStack(spacing: 24) {
                        FeedHeader(currentUser: dataManager.currentUser)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        DiscoverSection(
                            dailyQuote: dailyInspiration,
                            favorites: favorites,
                            trending: trendingQuotes,
                            tagStats: tagStats,
                            onSelectQuote: { quote in
                                if let profile = dataManager.profile(for: quote.authorId) ?? dataManager.currentUser {
                                    navigateToProfile(profile, quote: quote)
                                }
                            },
                            onToggleFavorites: {
                                showFavorites.toggle()
                            }
                        )
                        .padding(.horizontal)
                        
                        LiquidGlassMenuBar(
                            searchText: $searchText,
                            threshold: $likeThreshold,
                            highlightedTags: trendingTags,
                            activeTag: selectedTag,
                            suggestions: trendingTags,
                            sliderRange: 0...100,
                            sliderStep: 5,
                            sliderLabel: "Minimum likes",
                            sliderIcon: "hand.thumbsup.fill",
                            sliderUnit: nil,
                            sliderAccent: .pink,
                            actionTitle: "New Quote",
                            actionIcon: "sparkles",
                            actionStyle: .accent,
                            onSubmitSearch: {
                                // keep current tag to allow combined filtering
                            },
                            onClearFilters: {
                                searchText = ""
                                likeThreshold = 0
                                selectedTag = nil
                            },
                            onCreate: {
                                showingAdd = true
                            },
                            onSelectTag: { tag in
                                selectedTag = tag
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(filteredQuotes) { quote in
                                NavigationLink(destination: ProfileQuotesView(profile: dataManager.profile(for: quote.authorId) ?? dataManager.currentUser!, dataManager: dataManager)) {
                                    QuoteCard(
                                        quote: quote,
                                        isLiked: dataManager.isQuoteLiked(quote),
                                        isBookmarked: dataManager.isQuoteBookmarked(quote),
                                        onLike: { dataManager.likeQuote(quote) },
                                        onBookmark: { dataManager.toggleBookmark(quote) }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                .navigationTitle("Quotes")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddQuoteView(dataManager: dataManager)
            }
        }
    }
    
    private func navigateToProfile(_ profile: UserProfile, quote: Quote) {
        // Implementation detail handled via navigation links in list
    }
}

struct FeedHeader: View {
    let currentUser: UserProfile?
    
    var body: some View {
        LiquidGlassCard {
            HStack(spacing: 12) {
                if let user = currentUser {
                    Image(systemName: user.avatarSystemImageName)
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial, in: Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome back")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(user.displayName)
                            .font(.headline.weight(.semibold))
                    }
                } else {
                    Text("Welcome")
                        .font(.headline)
                }
                Spacer()
            }
        }
    }
}

struct QuoteCard: View {
    let quote: Quote
    let isLiked: Bool
    let isBookmarked: Bool
    let onLike: () -> Void
    let onBookmark: () -> Void
    
    @State private var localLiked = false
    @State private var localBookmarked = false
    
    var body: some View {
        LiquidGlassCard(isInteractive: true) {
            VStack(alignment: .leading, spacing: 16) {
                Text("\"\(quote.text)\"")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    Text(quote.authorDisplayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(quote.createdAt, style: .relative)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                if !quote.tags.isEmpty {
                    Wrap(tags: quote.tags)
                }
                
                HStack(spacing: 12) {
                    QuoteReactionButton(
                        isActive: localLiked,
                        systemImageActive: "heart.fill",
                        systemImageInactive: "heart",
                        activeColor: .pink,
                        label: "\(quote.likeCount)",
                        action: {
                            localLiked.toggle()
                            onLike()
                        }
                    )
                    
                    QuoteReactionButton(
                        isActive: localBookmarked,
                        systemImageActive: "bookmark.fill",
                        systemImageInactive: "bookmark",
                        activeColor: .cyan,
                        label: "\(quote.bookmarkCount)",
                        action: {
                            localBookmarked.toggle()
                            onBookmark()
                        }
                    )
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            localLiked = isLiked
            localBookmarked = isBookmarked
        }
    }
}

struct QuoteReactionButton: View {
    let isActive: Bool
    let systemImageActive: String
    let systemImageInactive: String
    let activeColor: Color
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isActive ? systemImageActive : systemImageInactive)
                    .foregroundColor(isActive ? activeColor : .secondary)
                    .font(.subheadline.weight(.medium))
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(isActive ? activeColor : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .shadow(color: activeColor.opacity(isActive ? 0.2 : 0), radius: 6, x: 0, y: 4)
    }
}

struct Wrap: View {
    let tags: [String]
    private let columns = [GridItem(.flexible(minimum: 20), spacing: 8)]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { t in
                Text("#\(t)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue.opacity(0.1))
                    )
            }
        }
    }
}

struct DiscoverSection: View {
    let dailyQuote: Quote?
    let favorites: [Quote]
    let trending: [Quote]
    let tagStats: [QuoteTagStat]
    let onSelectQuote: (Quote) -> Void
    let onToggleFavorites: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Discover")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            
            if let dailyQuote = dailyQuote {
                LiquidGlassCard(cornerRadius: 26, padding: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Daily Inspiration", systemImage: "sun.max.fill")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.mint)
                        Text(dailyQuote.text)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                        HStack {
                            Text(dailyQuote.authorDisplayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            LiquidGlassButton("Read", icon: "arrow.right") {
                                onSelectQuote(dailyQuote)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            if !favorites.isEmpty {
                FavoritesCarousel(quotes: favorites, onSelectQuote: onSelectQuote)
            }
            
            if !trending.isEmpty {
                TrendingQuotesGrid(quotes: trending, onSelectQuote: onSelectQuote)
            }
            
            if !tagStats.isEmpty {
                TagInsightsView(stats: tagStats)
            }
        }
    }
}

struct FavoritesCarousel: View {
    let quotes: [Quote]
    let onSelectQuote: (Quote) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Bookmarks", systemImage: "bookmark.fill")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.pink)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(quotes) { quote in
                        LiquidGlassCard(cornerRadius: 24, padding: 20, isInteractive: true) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(quote.text)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(3)
                                Spacer(minLength: 0)
                                HStack {
                                    Text(quote.authorDisplayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    LiquidGlassButton("Open", icon: "arrow.forward.circle") {
                                        onSelectQuote(quote)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .frame(width: 240, height: 160)
                        }
                    }
                }
            }
        }
    }
}

struct TrendingQuotesGrid: View {
    let quotes: [Quote]
    let onSelectQuote: (Quote) -> Void
    
    private let columns = [
        GridItem(.flexible(minimum: 140), spacing: 16),
        GridItem(.flexible(minimum: 140), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Trending", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.orange)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(quotes) { quote in
                    LiquidGlassCard(cornerRadius: 22, padding: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(quote.text)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(4)
                            Spacer(minLength: 0)
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.pink)
                                Text("\(quote.likeCount)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button {
                                    onSelectQuote(quote)
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.caption.weight(.bold))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(height: 150)
                    }
                }
            }
        }
    }
}

struct TagInsightsView: View {
    let stats: [QuoteTagStat]
    
    var body: some View {
        LiquidGlassCard(cornerRadius: 26, padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Tag Insights", systemImage: "number.square")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.indigo)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(stats) { stat in
                        HStack {
                            Text("#\(stat.tag)")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(stat.count)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
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
            }
        }
    }
}

#Preview {
    QuoteFeedView()
}


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
    
    private var filteredQuotes: [Quote] {
        var items = dataManager.quotes
        if let tag = selectedTag {
            items = items.filter { $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(tag) }) }
        }
        if !searchText.isEmpty {
            items = items.filter { $0.text.localizedCaseInsensitiveContains(searchText) || $0.authorDisplayName.localizedCaseInsensitiveContains(searchText) }
        }
        return items
    }
    
    private var trendingTags: [String] {
        let allTags = dataManager.quotes.flatMap { $0.tags }
        let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        return counts.sorted { $0.value > $1.value }.map { $0.key }.prefix(8).map { $0 }
    }
    
    var body: some View {
        NavigationView {
            LiquidGlassBackground {
                VStack(spacing: 0) {
                    FeedHeader(currentUser: dataManager.currentUser)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    VStack(spacing: 12) {
                        LiquidGlassTextField("Search quotes or authors", text: $searchText, icon: "magnifyingglass")
                            .padding(.horizontal)
                        
                        if !trendingTags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    TagPill(title: "All", isSelected: selectedTag == nil) { selectedTag = nil }
                                    ForEach(trendingTags, id: \.self) { tag in
                                        TagPill(title: "#\(tag)", isSelected: selectedTag == tag) { selectedTag = tag }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredQuotes) { quote in
                                NavigationLink(destination: ProfileQuotesView(profile: dataManager.profile(for: quote.authorId) ?? dataManager.currentUser!, dataManager: dataManager)) {
                                    QuoteCard(quote: quote) {
                                        dataManager.likeQuote(quote)
                                    }
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

struct TagPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? .blue : .blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuoteCard: View {
    let quote: Quote
    let onLike: () -> Void
    
    @State private var isLiked = false
    @State private var likeAnimation = false
    
    var body: some View {
        LiquidGlassCard(isInteractive: true) {
            VStack(alignment: .leading, spacing: 16) {
                Text("\"\(quote.text)\"")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                
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
                
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                            isLiked.toggle()
                            likeAnimation = true
                        }
                        onLike()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .pink : .secondary)
                                .font(.subheadline.weight(.medium))
                                .symbolEffect(.bounce, value: likeAnimation)
                            Text("\(quote.likeCount)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(isLiked ? .pink : .secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            isLiked = quote.likeCount > 0
        }
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

#Preview {
    QuoteFeedView()
}


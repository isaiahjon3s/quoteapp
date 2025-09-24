//
//  WorkoutListView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct WorkoutListView: View {
    @StateObject private var dataManager = WorkoutDataManager()
    @State private var selectedCategory: WorkoutCategory? = nil
    @State private var showingAddWorkout = false
    @State private var searchText = ""
    
    var filteredWorkouts: [Workout] {
        var workouts = dataManager.workouts
        
        if let category = selectedCategory {
            workouts = workouts.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            workouts = workouts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return workouts.sorted { ($0.lastPerformed ?? $0.dateCreated) > ($1.lastPerformed ?? $1.dateCreated) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Stats
                    WorkoutStatsHeader(stats: dataManager.getWorkoutStats())
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    // Search and Filter
                    VStack(spacing: 12) {
                        LiquidGlassTextField(
                            "Search workouts...",
                            text: $searchText,
                            icon: "magnifyingglass"
                        )
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryFilterButton(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    action: { selectedCategory = nil }
                                )
                                
                                ForEach(WorkoutCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                    
                    // Workouts List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredWorkouts) { workout in
                                NavigationLink(destination: WorkoutDetailView(workout: workout, dataManager: dataManager)) {
                                    WorkoutCard(workout: workout)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if filteredWorkouts.isEmpty {
                                EmptyWorkoutsView()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWorkout = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView(dataManager: dataManager)
            }
        }
    }
}

// MARK: - Workout Stats Header

struct WorkoutStatsHeader: View {
    let stats: WorkoutStats
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Workouts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(stats.totalWorkouts)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("This Week")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(stats.thisWeekWorkouts)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(stats.formattedTotalDuration)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Avg Duration")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(stats.formattedAverageDuration)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// MARK: - Category Filter Button

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .blue : .blue.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Workout Card

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text(workout.category.rawValue)
                            .font(.caption)
                            .foregroundColor(workout.category.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(workout.category.color.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                    
                    Image(systemName: workout.category.icon)
                        .font(.title2)
                        .foregroundColor(workout.category.color)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(workout.exercises.count) Exercises")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(workout.difficulty.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundColor(workout.difficulty.color)
                    }
                    
                    Spacer()
                    
                    if let lastPerformed = workout.lastPerformed {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Last Workout")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(lastPerformed, style: .relative)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                if !workout.exercises.isEmpty {
                    LiquidGlassProgressBar(
                        progress: 0.7, // This would be calculated based on completion
                        color: workout.category.color,
                        height: 6
                    )
                }
            }
        }
    }
}

// MARK: - Empty State

struct EmptyWorkoutsView: View {
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("No Workouts Found")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Create your first workout to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    WorkoutListView()
}

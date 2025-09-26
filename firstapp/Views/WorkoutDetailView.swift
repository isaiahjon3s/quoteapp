//
//  WorkoutDetailView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @ObservedObject var dataManager: WorkoutDataManager
    @State private var showingStartWorkout = false
    @State private var isEditing = false
    @State private var hydrationGoal: Double = 16
    
    var body: some View {
        LiquidGlassBackground {
            ScrollView {
                VStack(spacing: 20) {
                    // Workout Header
                    WorkoutHeaderCard(workout: workout)
                    
                    LiquidGlassSlider(
                        label: "Hydration Goal",
                        value: $hydrationGoal,
                        range: 8...64,
                        step: 4,
                        leadingIcon: "drop.fill",
                        unit: " oz",
                        accent: .mint
                    )
                    .padding(.horizontal)
                    
                    // Exercise List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercises")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        ForEach(workout.exercises) { exercise in
                            ExerciseCard(exercise: exercise)
                        }
                    }
                    
                    // Start Workout Button
                    LiquidGlassButton(
                        "Start Workout",
                        icon: "play.fill",
                        style: .primary,
                        size: .large
                    ) {
                        showingStartWorkout = true
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingStartWorkout) {
            WorkoutSessionView(workout: workout, dataManager: dataManager)
        }
        .sheet(isPresented: $isEditing) {
            EditWorkoutView(workout: workout, dataManager: dataManager)
        }
    }
}

// MARK: - Workout Header Card

struct WorkoutHeaderCard: View {
    let workout: Workout
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(workout.name)
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            CategoryBadge(category: workout.category)
                            DifficultyBadge(difficulty: workout.difficulty)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: workout.category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(workout.category.color)
                }
                
                HStack(spacing: 20) {
                    StatItem(
                        title: "Exercises",
                        value: "\(workout.exercises.count)",
                        icon: "list.bullet"
                    )
                    
                    StatItem(
                        title: "Duration",
                        value: WorkoutDetailView.formatDuration(workout.totalDuration),
                        icon: "clock"
                    )
                    
                    StatItem(
                        title: "Difficulty",
                        value: workout.difficulty.rawValue,
                        icon: "chart.bar.fill"
                    )
                }
                
                if let lastPerformed = workout.lastPerformed {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Last performed \(lastPerformed, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text(exercise.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.blue)
                }
                
                if !exercise.sets.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(exercise.sets) { set in
                            HStack {
                                Text("Set \(exercise.sets.firstIndex(where: { $0.id == set.id })! + 1)")
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                if let duration = set.duration {
                                    Text("\(Int(duration))s")
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(.primary)
                                } else {
                                    Text("\(set.reps) reps")
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(.primary)
                                    
                                    if set.weight > 0 {
                                        Text("• \(Int(set.weight)) lbs")
                                            .font(.caption.weight(.medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct CategoryBadge: View {
    let category: WorkoutCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption)
            Text(category.rawValue)
                .font(.caption.weight(.medium))
        }
        .foregroundColor(category.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.1))
        )
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption.weight(.medium))
            .foregroundColor(difficulty.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(difficulty.color.opacity(0.1))
            )
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helper Functions

private static func formatDuration(_ duration: TimeInterval) -> String {
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return "\(minutes):\(String(format: "%02d", seconds))"
}

}

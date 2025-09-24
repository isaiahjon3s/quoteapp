//
//  WorkoutSessionView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct WorkoutSessionView: View {
    let workout: Workout
    @ObservedObject var dataManager: WorkoutDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 0
    @State private var sessionStartTime = Date()
    @State private var isResting = false
    @State private var restTimeRemaining = 0
    @State private var completedSets: Set<UUID> = []
    @State private var showingEndConfirmation = false
    
    private var currentExercise: Exercise {
        workout.exercises[currentExerciseIndex]
    }
    
    private var currentSet: ExerciseSet {
        currentExercise.sets[currentSetIndex]
    }
    
    private var isLastSet: Bool {
        currentSetIndex == currentExercise.sets.count - 1
    }
    
    private var isLastExercise: Bool {
        currentExerciseIndex == workout.exercises.count - 1
    }
    
    private var progress: Double {
        let totalSets = workout.exercises.reduce(0) { $0 + $1.sets.count }
        let completed = completedSets.count
        return Double(completed) / Double(totalSets)
    }
    
    var body: some View {
        ZStack {
            LiquidGlassBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                WorkoutSessionHeader(
                    workout: workout,
                    progress: progress,
                    currentExerciseIndex: currentExerciseIndex,
                    totalExercises: workout.exercises.count
                )
                
                // Current Exercise
                ScrollView {
                    VStack(spacing: 20) {
                        CurrentExerciseCard(
                            exercise: currentExercise,
                            currentSetIndex: currentSetIndex,
                            completedSets: completedSets
                        )
                        
                        if isResting {
                            RestTimerCard(
                                timeRemaining: restTimeRemaining,
                                onComplete: completeRest
                            )
                        } else {
                            ActionButtonsCard(
                                onCompleteSet: completeSet,
                                onSkipSet: skipSet,
                                onStartRest: startRest
                            )
                        }
                        
                        // Exercise Progress
                        ExerciseProgressCard(
                            exercise: currentExercise,
                            currentSetIndex: currentSetIndex,
                            completedSets: completedSets
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Workout Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("End") {
                    showingEndConfirmation = true
                }
                .foregroundColor(.red)
            }
        }
        .alert("End Workout", isPresented: $showingEndConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End Workout", role: .destructive) {
                endWorkout()
            }
        } message: {
            Text("Are you sure you want to end this workout? Your progress will be saved.")
        }
        .onAppear {
            dataManager.startWorkoutSession(workout)
        }
    }
    
    // MARK: - Actions
    
    private func completeSet() {
        completedSets.insert(currentSet.id)
        
        if isLastSet {
            if isLastExercise {
                endWorkout()
            } else {
                nextExercise()
            }
        } else {
            nextSet()
        }
    }
    
    private func skipSet() {
        if isLastSet {
            if isLastExercise {
                endWorkout()
            } else {
                nextExercise()
            }
        } else {
            nextSet()
        }
    }
    
    private func startRest() {
        isResting = true
        restTimeRemaining = Int(currentExercise.restTime)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                timer.invalidate()
                completeRest()
            }
        }
    }
    
    private func completeRest() {
        isResting = false
        restTimeRemaining = 0
    }
    
    private func nextSet() {
        currentSetIndex += 1
    }
    
    private func nextExercise() {
        currentExerciseIndex += 1
        currentSetIndex = 0
    }
    
    private func endWorkout() {
        dataManager.endWorkoutSession()
        dismiss()
    }
}

// MARK: - Workout Session Header

struct WorkoutSessionHeader: View {
    let workout: Workout
    let progress: Double
    let currentExerciseIndex: Int
    let totalExercises: Int
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Text("Exercise \(currentExerciseIndex + 1) of \(totalExercises)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.blue)
                }
                
                LiquidGlassProgressBar(
                    progress: progress,
                    color: .blue,
                    height: 8
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Current Exercise Card

struct CurrentExerciseCard: View {
    let exercise: Exercise
    let currentSetIndex: Int
    let completedSets: Set<UUID>
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(exercise.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 8) {
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if let duration = set.duration {
                                Text("\(Int(duration))s")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                            } else {
                                Text("\(set.reps) reps")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                
                                if set.weight > 0 {
                                    Text("• \(Int(set.weight)) lbs")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if completedSets.contains(set.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if index == currentSetIndex {
                                Image(systemName: "circle")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(index == currentSetIndex ? .blue.opacity(0.1) : .gray.opacity(0.1))
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Rest Timer Card

struct RestTimerCard: View {
    let timeRemaining: Int
    let onComplete: () -> Void
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                Text("Rest Time")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Text("\(timeRemaining)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                
                Text("seconds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LiquidGlassButton(
                    "Skip Rest",
                    icon: "forward.fill",
                    style: .secondary
                ) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Action Buttons Card

struct ActionButtonsCard: View {
    let onCompleteSet: () -> Void
    let onSkipSet: () -> Void
    let onStartRest: () -> Void
    
    var body: some View {
        LiquidGlassCard {
            VStack(spacing: 16) {
                LiquidGlassButton(
                    "Complete Set",
                    icon: "checkmark.circle.fill",
                    style: .primary,
                    size: .large
                ) {
                    onCompleteSet()
                }
                
                HStack(spacing: 16) {
                    LiquidGlassButton(
                        "Skip Set",
                        icon: "forward.fill",
                        style: .secondary
                    ) {
                        onSkipSet()
                    }
                    
                    LiquidGlassButton(
                        "Rest",
                        icon: "timer",
                        style: .accent
                    ) {
                        onStartRest()
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Progress Card

struct ExerciseProgressCard: View {
    let exercise: Exercise
    let currentSetIndex: Int
    let completedSets: Set<UUID>
    
    private var progress: Double {
        let total = exercise.sets.count
        let completed = exercise.sets.filter { completedSets.contains($0.id) }.count
        return Double(completed) / Double(total)
    }
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Progress")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.blue)
                }
                
                LiquidGlassProgressBar(
                    progress: progress,
                    color: .blue,
                    height: 6
                )
                
                Text("\(exercise.sets.filter { completedSets.contains($0.id) }.count) of \(exercise.sets.count) sets completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationView {
        WorkoutSessionView(
            workout: Workout(
                name: "Morning Strength",
                exercises: [
                    Exercise(name: "Push-ups", sets: [
                        ExerciseSet(reps: 15, weight: 0),
                        ExerciseSet(reps: 12, weight: 0),
                        ExerciseSet(reps: 10, weight: 0)
                    ])
                ]
            ),
            dataManager: WorkoutDataManager()
        )
    }
}

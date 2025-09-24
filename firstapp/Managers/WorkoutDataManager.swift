//
//  WorkoutDataManager.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import SwiftUI
import Combine

class WorkoutDataManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var currentSession: WorkoutSession?
    
    private let userDefaults = UserDefaults.standard
    private let workoutsKey = "SavedWorkouts"
    private let sessionsKey = "WorkoutSessions"
    
    init() {
        loadWorkouts()
        loadWorkoutSessions()
    }
    
    // MARK: - Workout Management
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        saveWorkouts()
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }
    
    func getWorkoutsByCategory(_ category: WorkoutCategory) -> [Workout] {
        return workouts.filter { $0.category == category }
    }
    
    func getRecentWorkouts(limit: Int = 5) -> [Workout] {
        return workouts
            .sorted { ($0.lastPerformed ?? $0.dateCreated) > ($1.lastPerformed ?? $1.dateCreated) }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Workout Session Management
    
    func startWorkoutSession(_ workout: Workout) {
        let session = WorkoutSession(
            workout: workout,
            startTime: Date(),
            endTime: nil,
            completedExercises: [],
            totalCalories: 0,
            notes: ""
        )
        currentSession = session
    }
    
    func endWorkoutSession() {
        guard var session = currentSession else { return }
        session.endTime = Date()
        workoutSessions.append(session)
        
        // Update workout's last performed date
        if let index = workouts.firstIndex(where: { $0.id == session.workout.id }) {
            workouts[index].lastPerformed = Date()
        }
        
        currentSession = nil
        saveWorkoutSessions()
        saveWorkouts()
    }
    
    func getWorkoutHistory() -> [WorkoutSession] {
        return workoutSessions.sorted { $0.startTime > $1.startTime }
    }
    
    func getWorkoutStats() -> WorkoutStats {
        let completedSessions = workoutSessions.filter { $0.isCompleted }
        let totalWorkouts = completedSessions.count
        let totalDuration = completedSessions.reduce(0) { $0 + $1.duration }
        let totalCalories = completedSessions.reduce(0) { $0 + $1.totalCalories }
        
        let thisWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
        let thisWeekSessions = completedSessions.filter { session in
            guard let weekInterval = thisWeek else { return false }
            return weekInterval.contains(session.startTime)
        }
        
        return WorkoutStats(
            totalWorkouts: totalWorkouts,
            totalDuration: totalDuration,
            totalCalories: totalCalories,
            thisWeekWorkouts: thisWeekSessions.count,
            averageWorkoutDuration: totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        )
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            userDefaults.set(encoded, forKey: workoutsKey)
        }
    }
    
    private func loadWorkouts() {
        if let data = userDefaults.data(forKey: workoutsKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        } else {
            // Load sample data
            loadSampleWorkouts()
        }
    }
    
    private func saveWorkoutSessions() {
        if let encoded = try? JSONEncoder().encode(workoutSessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadWorkoutSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            workoutSessions = decoded
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleWorkouts() {
        let sampleWorkouts = [
            Workout(
                name: "Morning Strength",
                exercises: [
                    Exercise(name: "Push-ups", sets: [
                        ExerciseSet(reps: 15, weight: 0),
                        ExerciseSet(reps: 12, weight: 0),
                        ExerciseSet(reps: 10, weight: 0)
                    ], category: .strength),
                    Exercise(name: "Squats", sets: [
                        ExerciseSet(reps: 20, weight: 0),
                        ExerciseSet(reps: 18, weight: 0),
                        ExerciseSet(reps: 15, weight: 0)
                    ], category: .strength),
                    Exercise(name: "Plank", sets: [
                        ExerciseSet(duration: 30),
                        ExerciseSet(duration: 30),
                        ExerciseSet(duration: 30)
                    ], category: .strength)
                ],
                category: .strength
            ),
            Workout(
                name: "Cardio Blast",
                exercises: [
                    Exercise(name: "Jumping Jacks", sets: [
                        ExerciseSet(duration: 60),
                        ExerciseSet(duration: 60),
                        ExerciseSet(duration: 60)
                    ], category: .cardio),
                    Exercise(name: "High Knees", sets: [
                        ExerciseSet(duration: 45),
                        ExerciseSet(duration: 45),
                        ExerciseSet(duration: 45)
                    ], category: .cardio),
                    Exercise(name: "Burpees", sets: [
                        ExerciseSet(reps: 10, weight: 0),
                        ExerciseSet(reps: 8, weight: 0),
                        ExerciseSet(reps: 6, weight: 0)
                    ], category: .cardio)
                ],
                category: .hiit
            ),
            Workout(
                name: "Yoga Flow",
                exercises: [
                    Exercise(name: "Downward Dog", sets: [
                        ExerciseSet(duration: 60),
                        ExerciseSet(duration: 60)
                    ], category: .flexibility),
                    Exercise(name: "Warrior Pose", sets: [
                        ExerciseSet(duration: 45),
                        ExerciseSet(duration: 45)
                    ], category: .flexibility),
                    Exercise(name: "Tree Pose", sets: [
                        ExerciseSet(duration: 30),
                        ExerciseSet(duration: 30)
                    ], category: .balance)
                ],
                category: .yoga
            )
        ]
        
        workouts = sampleWorkouts
        saveWorkouts()
    }
}

// MARK: - Workout Stats

struct WorkoutStats {
    let totalWorkouts: Int
    let totalDuration: TimeInterval
    let totalCalories: Int
    let thisWeekWorkouts: Int
    let averageWorkoutDuration: TimeInterval
    
    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) % 3600 / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedAverageDuration: String {
        let minutes = Int(averageWorkoutDuration) / 60
        return "\(minutes)m"
    }
}


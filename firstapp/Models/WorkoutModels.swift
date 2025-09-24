//
//  WorkoutModels.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import Foundation
import SwiftUI

// MARK: - Workout Data Models

struct Workout: Identifiable, Codable {
    let id = UUID()
    var name: String
    var exercises: [Exercise]
    var dateCreated: Date
    var lastPerformed: Date?
    var totalDuration: TimeInterval
    var difficulty: Difficulty
    var category: WorkoutCategory
    
    init(name: String, exercises: [Exercise] = [], category: WorkoutCategory = .strength) {
        self.name = name
        self.exercises = exercises
        self.dateCreated = Date()
        self.lastPerformed = nil
        self.totalDuration = 0
        self.difficulty = .beginner
        self.category = category
    }
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: [ExerciseSet]
    var restTime: TimeInterval
    var notes: String
    var category: ExerciseCategory
    
    init(name: String, sets: [ExerciseSet] = [], restTime: TimeInterval = 60, category: ExerciseCategory = .strength) {
        self.name = name
        self.sets = sets
        self.restTime = restTime
        self.notes = ""
        self.category = category
    }
}

struct ExerciseSet: Identifiable, Codable {
    let id = UUID()
    var reps: Int
    var weight: Double
    var duration: TimeInterval? // For time-based exercises
    var isCompleted: Bool
    
    init(reps: Int = 0, weight: Double = 0, duration: TimeInterval? = nil) {
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.isCompleted = false
    }
}

struct WorkoutSession: Identifiable, Codable {
    let id = UUID()
    var workout: Workout
    var startTime: Date
    var endTime: Date?
    var completedExercises: [Exercise]
    var totalCalories: Int
    var notes: String
    
    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime)
    }
    
    var isCompleted: Bool {
        return endTime != nil
    }
}

// MARK: - Enums

enum Difficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

enum WorkoutCategory: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case sports = "Sports"
    case functional = "Functional"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case pilates = "Pilates"
    
    var icon: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        case .flexibility: return "figure.flexibility"
        case .sports: return "sportscourt.fill"
        case .functional: return "figure.strengthtraining.traditional"
        case .hiit: return "timer"
        case .yoga: return "figure.yoga"
        case .pilates: return "figure.pilates"
        }
    }
    
    var color: Color {
        switch self {
        case .strength: return .blue
        case .cardio: return .red
        case .flexibility: return .purple
        case .sports: return .green
        case .functional: return .orange
        case .hiit: return .pink
        case .yoga: return .mint
        case .pilates: return .indigo
        }
    }
}

enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case balance = "Balance"
    case endurance = "Endurance"
    case power = "Power"
    case mobility = "Mobility"
}


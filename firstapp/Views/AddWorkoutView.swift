//
//  AddWorkoutView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct AddWorkoutView: View {
    @ObservedObject var dataManager: WorkoutDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName = ""
    @State private var selectedCategory: WorkoutCategory = .strength
    @State private var selectedDifficulty: Difficulty = .beginner
    @State private var exercises: [Exercise] = []
    @State private var showingAddExercise = false
    
    var body: some View {
        NavigationView {
            LiquidGlassBackground {
                ScrollView {
                    VStack(spacing: 20) {
                        // Workout Details
                        WorkoutDetailsCard(
                            name: $workoutName,
                            category: $selectedCategory,
                            difficulty: $selectedDifficulty
                        )
                        
                        // Exercises List
                        ExercisesListCard(
                            exercises: exercises,
                            onAddExercise: { showingAddExercise = true },
                            onDeleteExercise: deleteExercise,
                            onEditExercise: editExercise
                        )
                        
                        // Save Button
                        LiquidGlassButton(
                            "Save Workout",
                            icon: "checkmark.circle.fill",
                            style: .primary,
                            size: .large
                        ) {
                            saveWorkout()
                        }
                        .disabled(workoutName.isEmpty || exercises.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .navigationTitle("New Workout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingAddExercise) {
                    AddExerciseView { exercise in
                        exercises.append(exercise)
                    }
                }
            }
        }
    }
    
    private func deleteExercise(_ exercise: Exercise) {
        exercises.removeAll { $0.id == exercise.id }
    }
    
    private func editExercise(_ exercise: Exercise) {
        // TODO: Implement edit exercise functionality
    }
    
    private func saveWorkout() {
        let workout = Workout(
            name: workoutName,
            exercises: exercises,
            category: selectedCategory
        )
        
        dataManager.addWorkout(workout)
        dismiss()
    }
}

// MARK: - Workout Details Card

struct WorkoutDetailsCard: View {
    @Binding var name: String
    @Binding var category: WorkoutCategory
    @Binding var difficulty: Difficulty
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 20) {
                Text("Workout Details")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 16) {
                    LiquidGlassTextField(
                        "Workout Name",
                        text: $name,
                        icon: "textformat"
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(WorkoutCategory.allCases, id: \.self) { cat in
                                    CategorySelectionButton(
                                        category: cat,
                                        isSelected: category == cat,
                                        action: { category = cat }
                                    )
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(Difficulty.allCases, id: \.self) { diff in
                                DifficultySelectionButton(
                                    difficulty: diff,
                                    isSelected: difficulty == diff,
                                    action: { difficulty = diff }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Exercises List Card

struct ExercisesListCard: View {
    let exercises: [Exercise]
    let onAddExercise: () -> Void
    let onDeleteExercise: (Exercise) -> Void
    let onEditExercise: (Exercise) -> Void
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Exercises")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(exercises.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                if exercises.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No exercises added")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    VStack(spacing: 8) {
                        ForEach(exercises) { exercise in
                            ExerciseRow(
                                exercise: exercise,
                                onDelete: { onDeleteExercise(exercise) },
                                onEdit: { onEditExercise(exercise) }
                            )
                        }
                    }
                }
                
                LiquidGlassButton(
                    "Add Exercise",
                    icon: "plus",
                    style: .accent
                ) {
                    onAddExercise()
                }
            }
        }
    }
}

// MARK: - Category Selection Button

struct CategorySelectionButton: View {
    let category: WorkoutCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : category.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Difficulty Selection Button

struct DifficultySelectionButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(difficulty.rawValue)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : difficulty.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? difficulty.color : difficulty.color.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Exercise Row

struct ExerciseRow: View {
    let exercise: Exercise
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                Text("\(exercise.sets.count) sets")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    AddWorkoutView(dataManager: WorkoutDataManager())
}

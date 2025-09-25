//
//  EditWorkoutView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct EditWorkoutView: View {
    let workout: Workout
    @ObservedObject var dataManager: WorkoutDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName: String
    @State private var selectedCategory: WorkoutCategory
    @State private var selectedDifficulty: Difficulty
    @State private var exercises: [Exercise]
    @State private var showingAddExercise = false
    
    init(workout: Workout, dataManager: WorkoutDataManager) {
        self.workout = workout
        self.dataManager = dataManager
        self._workoutName = State(initialValue: workout.name)
        self._selectedCategory = State(initialValue: workout.category)
        self._selectedDifficulty = State(initialValue: workout.difficulty)
        self._exercises = State(initialValue: workout.exercises)
    }
    
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
                            "Update Workout",
                            icon: "checkmark.circle.fill",
                            style: .primary,
                            size: .large
                        ) {
                            updateWorkout()
                        }
                        .disabled(workoutName.isEmpty || exercises.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .navigationTitle("Edit Workout")
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
    
    private func updateWorkout() {
        var updatedWorkout = workout
        updatedWorkout.name = workoutName
        updatedWorkout.category = selectedCategory
        updatedWorkout.difficulty = selectedDifficulty
        updatedWorkout.exercises = exercises
        
        dataManager.updateWorkout(updatedWorkout)
        dismiss()
    }
}

#Preview {
    EditWorkoutView(
        workout: Workout(
            name: "Sample Workout",
            exercises: [],
            category: .strength
        ),
        dataManager: WorkoutDataManager()
    )
}


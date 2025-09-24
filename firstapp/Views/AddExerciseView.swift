//
//  AddExerciseView.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI

struct AddExerciseView: View {
    let onSave: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var exerciseName = ""
    @State private var selectedCategory: ExerciseCategory = .strength
    @State private var sets: [ExerciseSet] = [ExerciseSet()]
    @State private var restTime: TimeInterval = 60
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                LiquidGlassBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Exercise Details
                        ExerciseDetailsCard(
                            name: $exerciseName,
                            category: $selectedCategory,
                            restTime: $restTime,
                            notes: $notes
                        )
                        
                        // Sets Configuration
                        SetsConfigurationCard(
                            sets: $sets,
                            onAddSet: addSet,
                            onDeleteSet: deleteSet
                        )
                        
                        // Save Button
                        LiquidGlassButton(
                            "Save Exercise",
                            icon: "checkmark.circle.fill",
                            style: .primary,
                            size: .large
                        ) {
                            saveExercise()
                        }
                        .disabled(exerciseName.isEmpty || sets.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addSet() {
        sets.append(ExerciseSet())
    }
    
    private func deleteSet(at index: Int) {
        if sets.count > 1 {
            sets.remove(at: index)
        }
    }
    
    private func saveExercise() {
        let exercise = Exercise(
            name: exerciseName,
            sets: sets,
            restTime: restTime,
            category: selectedCategory
        )
        
        onSave(exercise)
        dismiss()
    }
}

// MARK: - Exercise Details Card

struct ExerciseDetailsCard: View {
    @Binding var name: String
    @Binding var category: ExerciseCategory
    @Binding var restTime: TimeInterval
    @Binding var notes: String
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 20) {
                Text("Exercise Details")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 16) {
                    LiquidGlassTextField(
                        "Exercise Name",
                        text: $name,
                        icon: "textformat"
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                                    ExerciseCategoryButton(
                                        category: cat,
                                        isSelected: category == cat,
                                        action: { category = cat }
                                    )
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rest Time")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("\(Int(restTime)) seconds")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Slider(value: $restTime, in: 0...300, step: 15)
                                .accentColor(.blue)
                        }
                    }
                    
                    LiquidGlassTextField(
                        "Notes (Optional)",
                        text: $notes,
                        icon: "note.text"
                    )
                }
            }
        }
    }
}

// MARK: - Sets Configuration Card

struct SetsConfigurationCard: View {
    @Binding var sets: [ExerciseSet]
    let onAddSet: () -> Void
    let onDeleteSet: (Int) -> Void
    
    var body: some View {
        LiquidGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Sets")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(sets.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
                        SetConfigurationRow(
                            set: $sets[index],
                            setNumber: index + 1,
                            onDelete: { onDeleteSet(index) },
                            canDelete: sets.count > 1
                        )
                    }
                }
                
                LiquidGlassButton(
                    "Add Set",
                    icon: "plus",
                    style: .accent
                ) {
                    onAddSet()
                }
            }
        }
    }
}

// MARK: - Exercise Category Button

struct ExerciseCategoryButton: View {
    let category: ExerciseCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .blue : .blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Set Configuration Row

struct SetConfigurationRow: View {
    @Binding var set: ExerciseSet
    let setNumber: Int
    let onDelete: () -> Void
    let canDelete: Bool
    
    @State private var isTimeBased = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if canDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isTimeBased ? "Duration (seconds)" : "Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if isTimeBased {
                        TextField("Duration", value: Binding(
                            get: { Int(set.duration ?? 0) },
                            set: { set.duration = TimeInterval($0) }
                        ), format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    } else {
                        TextField("Reps", value: $set.reps, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Weight", value: $set.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
            
            Toggle("Time-based exercise", isOn: $isTimeBased)
                .font(.caption)
                .onChange(of: isTimeBased) { newValue in
                    if newValue {
                        set.reps = 0
                        set.duration = 30
                    } else {
                        set.duration = nil
                        set.reps = 10
                    }
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    AddExerciseView { _ in }
}

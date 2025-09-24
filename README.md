# Workout Tracker App

A beautiful iOS workout tracking app built with SwiftUI featuring liquid glass design elements.

## Features

### 🏋️ Workout Management
- Create custom workouts with multiple exercises
- Add exercises with sets, reps, weight, and duration
- Categorize workouts (Strength, Cardio, HIIT, Yoga, etc.)
- Set difficulty levels (Beginner to Expert)
- Edit and delete existing workouts

### 📊 Workout Tracking
- Start and track active workout sessions
- Real-time progress tracking
- Rest timer between sets
- Complete or skip individual sets
- Session history and statistics

### 📈 Analytics & Statistics
- Total workouts completed
- Workout duration tracking
- Category-based statistics
- Weekly progress overview
- Recent activity timeline

### 🎨 Liquid Glass Design
- Beautiful glassmorphism UI components
- Smooth animations and transitions
- Dynamic background effects
- Modern, intuitive interface
- Dark mode support

## App Structure

### Models
- `WorkoutModels.swift` - Core data models for workouts, exercises, and sessions
- `WorkoutDataManager.swift` - Data persistence and management

### UI Components
- `LiquidGlassComponents.swift` - Reusable glassmorphism UI components
- `WorkoutListView.swift` - Main workout list with filtering and search
- `WorkoutDetailView.swift` - Individual workout details and exercises
- `WorkoutSessionView.swift` - Active workout session tracking
- `AddWorkoutView.swift` - Create new workouts
- `AddExerciseView.swift` - Add exercises to workouts
- `EditWorkoutView.swift` - Edit existing workouts

### Main App
- `ContentView.swift` - Tab-based navigation with liquid glass design
- `firstappApp.swift` - App entry point

## Key Features

### Liquid Glass Components
- **LiquidGlassCard** - Glassmorphism container with blur effects
- **LiquidGlassButton** - Interactive buttons with glass styling
- **LiquidGlassTextField** - Input fields with glass design
- **LiquidGlassProgressBar** - Animated progress indicators
- **LiquidGlassTabView** - Tab navigation with glass styling
- **LiquidGlassBackground** - Animated background with floating elements

### Workout Categories
- Strength Training
- Cardio
- HIIT (High-Intensity Interval Training)
- Yoga
- Pilates
- Flexibility
- Sports
- Functional Training

### Exercise Types
- Rep-based exercises (push-ups, squats, etc.)
- Time-based exercises (planks, holds, etc.)
- Weighted exercises with custom weight tracking
- Rest time configuration between sets

## Technical Details

- **Framework**: SwiftUI
- **iOS Version**: iOS 15.0+
- **Architecture**: MVVM with ObservableObject
- **Data Persistence**: UserDefaults (JSON encoding)
- **Design**: Liquid glass/glassmorphism with blur effects
- **Animations**: SwiftUI animations with easing curves

## Getting Started

1. Open the project in Xcode
2. Build and run on iOS Simulator or device
3. Start creating your first workout
4. Track your fitness journey with beautiful liquid glass UI

## Future Enhancements

- CoreData integration for better data management
- HealthKit integration for health metrics
- Workout sharing and social features
- Advanced analytics and charts
- Custom themes and personalization
- Apple Watch companion app
- Cloud sync and backup

## Design Philosophy

The app embraces the liquid glass design trend, creating a modern, elegant interface that feels both premium and approachable. The glassmorphism effects provide depth and visual interest while maintaining excellent usability and accessibility.

---

Built with ❤️ using SwiftUI and liquid glass design principles.

# quoteapp

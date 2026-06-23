# PrepBuddy - Interview Preparation App

PrepBuddy is a comprehensive Flutter application designed to help users prepare for technical interviews. It provides a structured learning path with Data Structures and Algorithms (DSA), Multiple Choice Questions (MCQ) tests, study materials, and progress tracking.

## 🚀 Features

- **Authentication:** Secure user login and registration powered by Firebase Authentication.
- **Dashboard:** A central hub to access study materials, tests, and view quick stats.
- **Data Structures & Algorithms (DSA):** Comprehensive modules for practicing and learning DSA concepts.
- **MCQ Tests:** Timed multiple-choice questions to test your knowledge across various tech stacks.
- **Study Materials:** Curated resources and reading materials for interview prep.
- **Statistics & Progress Tracking:** Visual representations of your learning progress and test scores using interactive charts.
- **Settings:** Customizable app preferences including Light and Dark mode support.
- **Cross-Platform:** Supports Android, iOS, Web, Windows, macOS, and Linux.

## 🛠️ Technology Stack & Libraries Used

PrepBuddy uses a modern and robust tech stack for seamless performance and maintainability:

### Core Framework
- **Flutter** & **Dart**: Cross-platform UI toolkit and language.

### Architecture & State Management
- **Feature-First Architecture:** Code is organized by features (e.g., `auth`, `dashboard`, `dsa`) rather than layers, making it scalable and easy to navigate.
- **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod):** For predictable, safe, and reactive state management.

### Routing
- **[go_router](https://pub.dev/packages/go_router):** Declarative routing package for handling navigation and deep linking.

### Backend & Database
- **[Firebase](https://firebase.google.com/):** 
  - `firebase_core` for Firebase initialization.
  - `firebase_auth` for secure user authentication.
  - `cloud_firestore` for cloud data storage and sync.
- **[sqflite](https://pub.dev/packages/sqflite) & [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi):** For local SQLite database storage (supports mobile and desktop).
- **[shared_preferences](https://pub.dev/packages/shared_preferences):** For storing lightweight local app settings (e.g., theme preferences).

### Networking
- **[dio](https://pub.dev/packages/dio):** A powerful HTTP client for Dart used for making API requests.

### UI Components & Animations
- **[google_fonts](https://pub.dev/packages/google_fonts):** Dynamic custom typography.
- **[flutter_markdown](https://pub.dev/packages/flutter_markdown) & [flutter_highlight](https://pub.dev/packages/flutter_highlight):** For rendering markdown text and syntax-highlighted code snippets within study materials.
- **[fl_chart](https://pub.dev/packages/fl_chart):** For rendering beautiful and interactive statistical charts.
- **[flutter_animate](https://pub.dev/packages/flutter_animate) & [lottie](https://pub.dev/packages/lottie):** For smooth micro-animations, transitions, and vector-based animations.
- **[flutter_svg](https://pub.dev/packages/flutter_svg):** For rendering high-quality SVG assets.

## 📁 Project Structure

```text
lib/
├── core/             # Core configurations (routing, theme, database setup, constants)
├── features/         # Feature modules of the app
│   ├── auth/         # Login, Register, User session management
│   ├── dashboard/    # Main landing screen
│   ├── dsa/          # Data Structures and Algorithms content
│   ├── mcq/          # Multiple Choice Questions and quizzes
│   ├── settings/     # App configurations and preferences
│   ├── splash/       # Initial splash screen
│   ├── stats/        # User performance analytics
│   └── study_materials/ # Reading resources
├── shared/           # Reusable widgets and utilities
└── main.dart         # Application entry point
```

## ⚙️ How to Run the App

Follow these steps to get the project up and running on your local machine:

### 1. Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
- Ensure your environment is configured for your target platform (Android Studio, Xcode, or Desktop tools).
- Create a Firebase project and configure it for this app (you will need to add your `google-services.json` / `GoogleService-Info.plist` or use FlutterFire CLI).

### 2. Clone the Repository
```bash
git clone https://github.com/ThePrince047/PrepBuddy.git
git branch -M main
git push -u origin main
cd PrepBuddy
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the App
To run the app on a connected device or emulator:
```bash
flutter run
```

*Note: For Windows/Linux/macOS desktop development, make sure desktop support is enabled in your Flutter environment.*

# FitTrack

FitTrack is a comprehensive fitness and nutrition tracking application built with Flutter. It helps users plan workouts, track meals & nutrition, set local reminders, watch exercise tutorials, and maintain their daily health goals.

---

## Features

- **Authentication & User Profiles**: Secure user login and profile management powered by Supabase.
- **Workout Tracker**: Discover and log workouts, complete exercise routines, and watch integrated YouTube fitness tutorials.
- **Nutrition & Meal Tracking**: Track daily meals, calories, and macros tailored to your fitness objectives.
- **Smart Notifications & Alarms**: Scheduled reminders for workouts, hydration, and meal times using `flutter_local_notifications` and `android_alarm_manager_plus`.
- **Offline & Local Storage**: Fast local data persistence using `Hive` and `shared_preferences`.
- **Modern Theme**: Clean, responsive UI with customized color palettes and theme support.

---

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK `^3.10.4`)
- **Backend & Auth**: [Supabase Flutter](https://pub.dev/packages/supabase_flutter)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Hive](https://pub.dev/packages/hive) & [Shared Preferences](https://pub.dev/packages/shared_preferences)

  
---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An active backend setup (Supabase configuration details in `lib/services/` or `lib/main.dart`).

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/abinjoyal/FitTrack-GymApp.git
   cd FitTrack
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

# Discover Ethiopia

Discover Ethiopia is an offline-first Flutter travel app focused on destination discovery, trip planning, cultural insights, and local services.

## Features

- Offline-first destination browsing
- Interactive offline map with:
  - Search (name/region/tag)
  - Filters (Trip, Favorites, Nature, Culture, Historical, Cities)
  - Marker legend and quick destination strip
- Destination details with:
  - Swipeable hero gallery
  - Photo journal
  - Travel essentials and notes
  - Nearby hotel highlights
- Cultural insight details with rich sections and swipeable media
- Trip planner with:
  - Day-by-day itinerary
  - Add/remove/reorder stops
  - Stop arrival/departure time windows
  - Cost + budget tracking
  - Readiness checklist
- Directory services (hotels, rentals, agencies) with demo booking flow
- Travel Toolkit screen (emergency contacts, phrases, health, power/connectivity)

## Branding

- App name: `Discover Ethiopia`
- Company: `Mega Software Solutions`
- Custom launcher icon generated from `Logo.png`

## Tech Stack

- Flutter (Material 3)
- `flutter_map` + OpenStreetMap tiles
- `shared_preferences` for local persistence

## Project Structure

```text
lib/
  app.dart
  main.dart
  data/
  models/
  screens/
  state/
  theme/
  widgets/
assets/images/
```

## Getting Started

### 1. Prerequisites

- Flutter SDK installed
- Android Studio / VS Code
- Android emulator or iOS simulator/device

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

### 4. Static analysis

```bash
flutter analyze
```

## Launcher Icon

Launcher icons are configured through `flutter_launcher_icons` in `pubspec.yaml`.

To regenerate:

```bash
dart run flutter_launcher_icons
```

## Notes

- Sample data lives in `lib/data/sample_data.dart`.
- Most features are demo-ready and optimized for local/offline UX.

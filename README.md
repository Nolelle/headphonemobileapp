# Mobile Audio Companion App

## Project Structure

The project follows a feature-first architecture with clean separation of concerns:

```
lib/
├── config/                    # App-wide configuration
│   ├── theme.dart            # Custom theme and styling definitions
│   └── routes.dart           # Application routing configuration
│
├── features/                  # Feature modules
│   ├── presets/              # Core preset management feature
│   │   ├── models/           # Data models for configurations
│   │   │   └── preset.dart   # Preset data structure
│   │   ├── repositories/     # Data access layer
│   │   │   └── preset_repository.dart
│   │   ├── providers/        # State management
│   │   │   └── preset_provider.dart
│   │   └── views/           # UI components
│   │       ├── screens/     # Full page screens
│   │       │   ├── preset_list_screen.dart
│   │       │   └── preset_detail_screen.dart
│   │       └── widgets/     # Reusable UI components
│   │           └── preset_list_item.dart
│   │
│   ├── settings/            # Application settings feature
│   │   └── views/
│   │       └── settings_screen.dart
│   │
│   └── sound_test/         # Audio testing feature
│       └── views/
│           └── sound_test_screen.dart
│
├── shared/                  # Shared utilities and widgets
│   ├── widgets/            # Common UI components
│   │   ├── error_display.dart
│   │   └── loading_overlay.dart
│   └── utils/              # Helper functions
│       └── json_loader.dart
│
└── main.dart               # Application entry point
```

### Architecture Overview

The application follows these key architectural principles:

1. **Feature-First Organization**: Each major feature is self-contained with its own models, views, and business logic.

2. **Clean Layer Separation**:
   - Models: Define data structures
   - Repositories: Handle data persistence
   - Providers: Manage application state
   - Views: Present UI and handle user interactions

3. **State Management**:
   - Uses Provider pattern for efficient state management
   - Maintains clean separation between UI and business logic
   - Implements observable pattern for reactive updates

4. **Data Persistence**:
   - SharedPreferences for local storage
   - JSON-based data structure for flexibility
   - Efficient preset management system

## Setup and Development

### Prerequisites

- Flutter SDK (2.5.0 or higher)
- Dart SDK (2.14.0 or higher)
- Android Studio or VS Code with Flutter extensions
- iOS development setup (for iOS deployment)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Nolelle/headphonemobileapp.git
   ```

2. Navigate to project directory:

   ```bash
   cd headphonemobileapp
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

### Development Guidelines

1. **Code Organization**:
   - Follow feature-first architecture
   - Maintain separation of concerns
   - Keep features self-contained

2. **Style Guide**:
   - Use `flutter format .` for consistent formatting
   - Follow analysis_options.yaml lint rules
   - Document public APIs thoroughly

3. **State Management**:
   - Implement providers for complex state
   - Use StateNotifier for immutable state
   - Maintain unidirectional data flow

4. **Testing**:
   - Write unit tests for business logic
   - Create widget tests for UI components
   - Implement integration tests for features

## Building for Production

Generate production builds using:

For Android:

```bash
flutter build apk --release
```

For iOS:

```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/NewFeature`)
3. Commit your changes (`git commit -m 'Add NewFeature'`)
4. Push to the branch (`git push origin feature/NewFeature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Technical Documentation

For detailed technical documentation about specific components:

- [State Management](docs/state-management.md)
- [Data Models](docs/data-models.md)
- [UI Components](docs/ui-components.md)
- [Testing Guide](docs/testing.md)

## Acknowledgments

- Flutter team for the framework
- Contributors and testers
- Open source community for various packages used in the project

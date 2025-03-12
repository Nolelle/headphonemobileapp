# Mobile Audio Companion App

## Project Structure

The project follows a feature-first architecture with clean separation of concerns:

```
lib/
├── config/                    # App-wide configuration
│   └── theme.dart            # Custom theme and styling definitions (light/dark themes)
│
├── core/                     # Core application components
│   ├── app.dart             # Main app configuration
│   └── main_nav.dart        # Main navigation component
│
├── features/                  # Feature modules
│   ├── bluetooth/           # Bluetooth connectivity feature
│   │   ├── providers/       # Bluetooth state management
│   │   └── views/           # Bluetooth UI components
│   │
│   ├── presets/              # Core preset management feature
│   │   ├── models/           # Data models
│   │   │   └── preset.dart
│   │   ├── repositories/     # Data access layer
│   │   │   └── preset_repository.dart
│   │   ├── providers/        # State management
│   │   │   └── preset_provider.dart
│   │   └── views/           # UI components
│   │       └── screens/     
│   │           ├── preset_list_page.dart
│   │           └── preset_page.dart
│   │
│   ├── settings/            # Application settings feature
│   │   ├── models/          # Settings data models
│   │   ├── repositories/    # Settings data access
│   │   ├── providers/       # Settings state management
│   │   │   ├── theme_provider.dart  # Manages app theme (dark/light mode)
│   │   │   └── language_provider.dart  # Manages app language
│   │   └── views/          # Settings UI components
│   │       └── screens/
│   │           └── settings_page.dart
│   │
│   └── sound_test/         # Audio testing feature
│       ├── models/         # Sound test data models
│       ├── repositories/   # Sound test data access
│       ├── providers/      # Sound test state management
│       └── views/         # Sound test UI components
│           └── screens/
│               └── sound_test_page.dart
│
├── l10n/                    # Localization resources
│   ├── app_localizations.dart  # Localization manager
│   └── translations/        # Translation files
│       ├── en.dart          # English translations
│       └── fr.dart          # French translations
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
   - Persists user preferences (theme, language)

5. **Internationalization**:
   - Supports multiple languages (English, French)
   - Custom localization system
   - Language switching with persistent preferences

6. **Theming**:
   - Supports light and dark themes
   - Consistent UI across theme changes
   - Persists theme preferences

## Key Features

### Preset Management

- Create, edit, and delete audio presets
- Adjust volume, sound balance, and enhancement settings
- Real-time feedback with optimized notifications
- Intelligent auto-save functionality

### Theme Support

- Light and dark mode themes
- Consistent UI elements across themes
- Persistent theme preferences

### Multilingual Support

- English and French language options
- Complete translations for all UI elements
- Persistent language preferences

### Bluetooth Connectivity

- Connect to Bluetooth headphone devices
- Send preset configurations to connected devices
- Monitor connection status

### Sound Testing

- Perform hearing tests
- Generate personalized audio profiles
- Create presets based on test results

## Setup and Development

### Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.0.0 or higher)
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

4. **Localization**:
   - Add new strings to both language files
   - Use the AppLocalizations.translate() method for all user-facing strings
   - Test UI in all supported languages

5. **Theming**:
   - Use Theme.of(context) to access theme properties
   - Test UI in both light and dark modes
   - Ensure sufficient contrast in all themes

6. **Testing**:
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
- [Localization](docs/localization.md)
- [Theming](docs/theming.md)

## Acknowledgments

- Flutter team for the framework
- Contributors and testers
- Open source community for various packages used in the project

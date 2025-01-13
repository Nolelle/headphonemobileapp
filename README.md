# Hearing Aid Companion App

A Flutter-based mobile application designed to help users manage and customize their hearing aid settings through an intuitive interface. This app allows users to create, manage, and switch between different audio presets, making it easier to adapt to various listening environments.

## Features

- Create and manage custom hearing aid presets
- Adjust overall volume and sound balance settings
- Fine-tune sound enhancement parameters
- Save and switch between multiple preset configurations
- User-friendly interface with intuitive controls
- Real-time preset activation and device synchronization
- Local storage for preset configurations

## Project Structure

The project follows a feature-first architecture with clear separation of concerns:

```
lib/
├── config/                    # App-wide configuration
│   ├── theme.dart            # Theme and styling definitions
│   └── routes.dart           # Application routing configuration
│
├── features/                  # Feature modules
│   ├── presets/              # Preset management feature
│   │   ├── models/           # Data models
│   │   ├── repositories/     # Data access layer
│   │   ├── providers/        # State management
│   │   └── views/           # UI components
│   ├── settings/            # App settings feature
│   └── sound_test/         # Sound testing feature
│
├── shared/                  # Shared utilities and widgets
│   ├── widgets/            # Common UI components
│   └── utils/              # Helper functions
│
└── main.dart               # Application entry point
```

### Directory Purposes

- **config/**: Contains application-wide configurations including theme settings and routing logic. These files establish the foundational setup of the app.

- **features/**: Houses the main feature modules of the application, each containing its own complete stack:
  - **presets/**: The core feature for managing hearing aid presets
  - **settings/**: User preferences and application settings
  - **sound_test/**: Functionality for testing and calibrating audio settings

- **shared/**: Contains code and components used across multiple features:
  - **widgets/**: Reusable UI components shared between features
  - **utils/**: Helper functions and utilities used throughout the app

## Getting Started

### Prerequisites

- Flutter SDK (2.5.0 or higher)
- Dart SDK (2.14.0 or higher)
- Android Studio or VS Code with Flutter extensions
- iOS development setup (for iOS deployment)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/hearing-aid-companion.git
   ```

2. Navigate to the project directory:

   ```bash
   cd hearing-aid-companion
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## Development Setup

### Code Style

The project follows the official Dart style guide and Flutter best practices:

- Use `flutter format .` to maintain consistent code formatting
- Follow the lint rules defined in `analysis_options.yaml`
- Maintain proper documentation for public APIs

### State Management

The application uses Provider for state management:

- Each feature has its own provider for state management
- The `PresetProvider` handles the core preset management functionality
- Providers are initialized at the app level in `main.dart`

### Data Persistence

Preset data is stored locally using SharedPreferences:

- Presets are stored as JSON objects
- The `PresetRepository` handles all data persistence operations
- Each preset contains configuration data and metadata

## Building for Production

To create a release build:

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
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Future Enhancements

- Bluetooth connectivity for direct device communication
- Cloud backup and sync functionality
- Advanced sound analysis features
- Multi-device support
- User profiles and settings sync

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The open-source community for various packages used in this project
- Contributors and testers who helped improve the application

# CLAUDE.md - Flutter Headphones App Assistant

## Build/Run Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter analyze` - Run static code analysis
- `flutter test` - Run all tests
- `flutter test test/path_to_file_test.dart` - Run specific test file

## Code Style Guidelines
- **Types**: Always use explicit types (variables, parameters, returns)
- **Naming**: Classes in PascalCase, variables/methods in camelCase, private members with underscore prefix (_)
- **Formatting**: Follow Flutter/Dart style guide, use `flutter format .` to ensure consistency
- **Error Handling**: Use try/catch blocks with specific error handling, prefer rethrow for propagation
- **Architecture**: Feature-based directory structure with separation of concerns (providers, models, views)
- **State Management**: Use Provider pattern with ChangeNotifier for state management
- **Comments**: Add comments for complex logic or section delineation
- **Imports**: Group imports (Flutter, Dart, project, third-party) and sort alphabetically

## Project Organization
Follow feature-based architecture with clean separation of concerns between layers:
- providers/ - State management
- models/ - Data models
- repositories/ - Data access
- views/ - UI components
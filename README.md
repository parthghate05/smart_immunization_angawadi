# Smart Immunization Reminder and Child Health Monitoring for Anganwadi Centres

Android-first Flutter Material 3 application.

## Included functionality
- Dashboard with vaccination and child-health overview
- Child registration form with date picker and validation
- Search and filter registered children
- Child detail screen
- Vaccination record toggles
- Growth monitoring edit dialog
- Health-note interaction
- Reminder list with notification toggle
- Reminder completion action
- Reports / immunization coverage
- Settings, language selection and data-sync dialog
- Responsive Material 3 navigation
- English/Hindi/Marathi localization delegates configured

## Run
1. Install Flutter.
2. Run `flutter pub get`
3. Run `flutter run`
4. Choose an Android emulator/device.

This project intentionally uses an in-memory data layer so the UI and interactions work immediately without requiring a backend. For production, replace AppData with a repository backed by SQLite/Hive/Firebase/API and connect actual Android local notifications.

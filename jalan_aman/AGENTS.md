# jalan_aman/AGENTS.md

Root-level AGENTS.md rules also apply here (note: use `ccc search` for code searches).

## Stack
- **State management:** basic `setState` + Riverpod
- **Routing:** `MaterialApp` with imperative `Navigator.pushReplacement` (no go_router yet).
- **HTTP:** `package:http` via a custom `ApiClient` service.
- **Maps:** `flutter_map` + `latlong2`.
- **Location:** `geolocator` + `geocoding`.
- **Storage:** `flutter_secure_storage` + `shared_preferences`.
- **Theming:** custom `AppTheme` class + `google_fonts` (PlusJakartaSans / DM Sans).
- **Environment:** `flutter_dotenv` (`.env` file).

## Conventions
- Place reusable widgets in `lib/components/`.
- Place page-level screens in `lib/pages/`.
- Place API and business logic in `lib/services/`.
- Place theme definitions in `lib/theme/`.
- Place utility/helper functions in `lib/utils/`.

## Using Skills
The system prompt already loads all project skills. Use them proactively when they match the task:
- **`dart-run-static-analysis`** before every commit.
- **`flutter-add-widget-test`** / **`dart-add-unit-test`** when creating new logic or UI.
- **`dart-fix-runtime-errors`** when debugging runtime crashes.
- **`flutter-fix-layout-issues`** for overflow or constraint errors.
- **`dart-resolve-package-conflicts`** when `pub get` fails.
- **`dart-generate-test-mocks`** when testing classes with external dependencies.
- **`dart-use-pattern-matching`** when writing switch/pattern logic.
- **`flutter-build-responsive-layout`** when building screens for multiple form factors.
- **`flutter-setup-localization`** / **`flutter-setup-declarative-routing`** / **`flutter-use-http-package`** for their respective setup tasks.


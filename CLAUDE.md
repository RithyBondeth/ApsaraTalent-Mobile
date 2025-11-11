# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Apsara Talent Platform Mobile is a Flutter application for a talent platform that connects employees and companies. The app features authentication, job feeds, search, chat, resume building, and settings functionality.

## Development Commands

### Core Flutter Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter clean` - Clean build artifacts
- `flutter pub upgrade` - Upgrade dependencies

### Code Generation
- `dart run build_runner build` - Generate auto_route files (required after route changes)
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate with conflicts

### Quality Assurance
- `flutter analyze` - Run static analysis (uses analysis_options.yaml)
- `flutter test` - Run unit tests
- `flutter doctor` - Check Flutter installation and dependencies

## Architecture

### State Management
- **Riverpod**: Primary state management solution
- Providers are organized by feature in `lib/features/*/providers/`
- App-wide providers in root providers directory

### Routing
- **Auto Route**: Declarative routing with code generation
- Route configuration in `lib/routes/app_route.dart`
- Generated routes in `lib/routes/app_route.gr.dart`
- Route constants in `lib/shared/constants/route_constant.dart`

### Feature Organization
The app follows a feature-first architecture:
```
lib/
├── features/
│   ├── auth/           # Authentication screens and logic
│   ├── feed/           # Job feed functionality
│   ├── search/         # Search functionality
│   ├── chat/           # Chat functionality
│   ├── resume_builder/ # Resume building tools
│   ├── navigation/     # Bottom navigation
│   └── setting/        # Settings screens
├── shared/             # Shared utilities and widgets
├── configs/            # Environment and configuration
├── routes/             # Auto-generated routing
└── main/               # App initialization
```

### Environment Configuration
- Multiple environment support: development, staging, production
- Environment files: `.env.development`, `.env.staging`, `.env.production`
- Configuration handled in `lib/configs/environment.dart`

### Theming
- **Flex Color Scheme**: Advanced Material 3 theming
- **ShadCN-inspired**: Custom color scheme matching ShadCN design system
- Light and dark theme support with system theme detection
- Theme files in `lib/shared/themes/`

### Key Dependencies
- `flutter_riverpod`: State management
- `auto_route`: Routing and navigation
- `flex_color_scheme`: Advanced theming
- `flutter_dotenv`: Environment variable management
- `google_fonts`: Typography
- `flutter_svg`: SVG asset support

## Development Workflow

1. **Adding New Routes**: Update `lib/routes/app_route.dart`, then run `dart run build_runner build`
2. **Environment Variables**: Add to appropriate `.env.*` file and reference in `lib/configs/environment.dart`
3. **New Features**: Create feature directory under `lib/features/` with `presentation/`, `providers/` subdirectories
4. **Shared Components**: Add to `lib/shared/widgets/` or appropriate shared directory
5. **Theme Customization**: Modify files in `lib/shared/themes/` following ShadCN design principles

## Important Notes

- Always run `flutter analyze` before committing to ensure code quality
- Route changes require running the build_runner to regenerate route files
- The app uses Material 3 design system with ShadCN-inspired styling
- Environment configuration is required for app initialization
- State management follows Riverpod patterns and best practices
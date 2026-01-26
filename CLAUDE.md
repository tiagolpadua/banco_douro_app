# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Banco Douro is a Flutter mobile banking application demonstrating account management and transaction processing with local and remote data persistence.

## Build and Development Commands

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build
flutter build apk           # Android
flutter build ios           # iOS

# Code quality
flutter analyze             # Run Dart analyzer
dart format lib/            # Format code

# Tests
flutter test                # Run all tests
flutter test test/widget_test.dart  # Run single test file

# Start mock backend (requires Node.js json-server)
./data/run.sh               # Linux/Mac
./data/run.cmd              # Windows
# Serves data from data/db.json on http://10.0.2.2:3000
```

## Architecture

The app follows a layered architecture pattern:

```
lib/
├── models/          # Data classes (Account, Transaction) with JSON/Map serialization
├── services/        # Business logic and HTTP operations
│   ├── account_service.dart      # Remote account CRUD
│   └── transaction_service.dart  # Transfer logic with tax calculation
├── data/
│   ├── database/    # SQLite setup (DatabaseHelper singleton)
│   └── repositories/ # Local database operations
├── viewmodels/      # State management bridging UI and services
├── ui/
│   ├── *_screen.dart  # Full page views
│   ├── widgets/       # Reusable components
│   └── styles/        # Design constants (AppColor)
├── exceptions/      # Custom exception classes
└── helpers/         # Utility functions (tax calculations)
```

## Key Business Logic

**Account Types and Tax Rates** (for transactions >= 5000):
- AMBROSIA: 0.5%
- CANJICA: 0.33%
- PUDIM: 0.25%
- BRIGADEIRO: 0.01%
- No type: 0.1 flat fee

Tax calculation is in `lib/helpers/helper_taxes.dart`, transaction processing in `lib/services/transaction_service.dart`.

## Data Flow

- Remote API: HTTP REST calls to json-server backend (hardcoded: `http://10.0.2.2:3000/accounts`)
- Local storage: SQLite via sqflite package
- Sync strategy: Fetch from remote on load, cache to local database

## Dependencies

Key packages: `http` (networking), `sqflite` (local DB), `uuid` (ID generation), `flutter_lints` (code quality)

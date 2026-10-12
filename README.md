# Calculator State Lab

My calculator for CSC 4360 Assignment 01. The app code is in `lib/main.dart`
and uses `StatefulWidget` and `setState()`.

## Features

- Light and dark mode switch
- AC to clear all calculator state
- Consistent button press animations

Calculations run left to right, so `2 + 3 × 4 =` gives `20`.
A digit after an operator starts the next operand. Another operator finishes
the pending calculation, while repeated operators replace each other.
Equals without a new operand is ignored and keeps the pending operator.
A digit after equals starts a new calculation. AC resets everything to `0`.

## Run and build

With Flutter installed and an Android emulator connected:

```sh
flutter pub get
flutter run
flutter build apk
```

The APK is at `build/app/outputs/flutter-apk/app-release.apk`.
The submission copy is named `DarshRathi_CalculatorApp.apk`.

## Testing

```sh
flutter analyze
flutter test
flutter test integration_test/calculator_test.dart -d emulator-5554
```

Analysis found no issues. All 19 widget tests and both Android tests passed,
including rotation and theme switching. The final APK was rebuilt and installed.
Runtime checks were not repeated on that rebuilt APK.

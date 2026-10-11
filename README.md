# Calculator State Lab

Flutter calculator for the CSC 4360 undergraduate pathway. The app uses
`StatefulWidget` and `setState()` with the application code in `lib/main.dart`.

## Run and build

With Flutter installed and an Android emulator or phone connected:

```sh
flutter pub get
flutter run
```

To build the release APK:

```sh
flutter build apk
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.
The submission copy is named `DarshRathi_CalculatorApp.apk`.

## Selected features

- **Theme toggle:** the labeled Dark mode switch changes all calculator surfaces between
  light and dark themes with a 250 ms transition. Calculation state is preserved.
- **All clear:** AC resets the operand, accumulator, pending operator, input phase,
  and result phase. The display returns to 0.
- **Button feedback:** every keypad button uses the same Material ink ripple and
  150 ms button animation.

## Calculation rules

The calculator evaluates operations from left to right. A new operator finishes
the pending operation and displays the running total. It does not use conventional
operator precedence: `2 + 3 × 4 =` gives `20`.

The current operand, accumulator, pending operator, and input/result phases are
stored in the page state. The displayed text is derived from the current operand
or accumulator rather than stored separately.

| Input | Transition |
| --- | --- |
| Digit | Append to the current operand; start an operand after an operator. |
| Operator after an operand | Apply the pending operation, show the total, and save the next operator. |
| Operator while awaiting an operand | Replace the pending operator. |
| Equals while awaiting an operand | Ignore the tap and preserve the pending operation. |
| Equals after an operand | Finish the operation and show the result. |
| Digit after equals | Start a fresh calculation. |
| Operator after equals | Continue from the displayed result. |
| AC | Reset all calculation fields and show 0. |

For `12 + 3 × 4 =`:

| Tap | Operand | Accumulator | Pending operator | Waiting for operand | Result shown | Display |
| --- | --- | --- | --- | --- | --- | --- |
| Start | empty | none | none | yes | no | 0 |
| 1 | 1 | none | none | no | no | 1 |
| 2 | 12 | none | none | no | no | 12 |
| + | empty | 12 | + | yes | no | 12 |
| 3 | 3 | 12 | + | no | no | 3 |
| × | empty | 15 | × | yes | no | 15 |
| 4 | 4 | 15 | × | no | no | 4 |
| = | empty | 60 | none | yes | yes | 60 |

Digit entry is whole-number entry for the undergraduate pathway; division can
produce fractional results. Division by zero shows a brief message and AC allows
recovery. This guard is not one of the three selected features.

## Tests

```sh
flutter analyze
flutter test
flutter test integration_test/calculator_test.dart -d emulator-5554
```

The widget tests cover all four operations, intermediate totals, operator
replacement, equals without a new operand, repeated equals, a fresh calculation
after a result, AC in different phases, theme preservation, division-by-zero
recovery, narrow-screen layout with large text, landscape scrolling, accessible
button labels, and Android touch-target sizes.

The integration test runs calculation transitions, AC, theme switching, and
recovery on the connected Android emulator. `integration_test` is a Flutter SDK
test dependency; the application code uses Flutter's Material widgets without
additional application packages.

Verification completed on the provided Android 16 (API 36) emulator:

- `flutter analyze`: no issues.
- `flutter test`: all 18 widget tests passed.
- Android integration tests: both tests passed, including real portrait-to-landscape
  rotation with calculation state preserved.
- The renamed release APK was installed and launched on the emulator. Android
  command-line interaction checks verified 15 display checkpoints covering all
  digits, four operations, the core transition rules, AC, and both theme directions.
- Light and dark release-app screenshots were visually checked. The Android logs
  showed no runtime errors during the final checks.

Screen-reader labels and target sizes were checked with Flutter's semantics
guidelines. A spoken TalkBack session was not performed.

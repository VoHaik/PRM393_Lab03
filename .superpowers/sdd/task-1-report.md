Task 1 report

Changes made:
- Added `JournalViewModel` import to `integration_test/keyword_flow_test.dart`.
- Added `JournalViewModel` to the Test Case 2 `MultiProvider` setup.
- Replaced the immediate settle after search with:
  - `await $.pump();`
  - `await $.pump(const Duration(seconds: 2));`
  - `await $.pumpAndSettle();`

Verification:
- `flutter test integration_test/keyword_flow_test.dart`
  - Failed with device selection/environment output:
    `More than one device connected; please specify a device with the '-d <deviceId>' flag, or use '-d all' to act on all devices.`
    Followed by:
    `Windows (desktop) • windows • windows-x64    • Microsoft Windows [Version 10.0.26200.8655]`
    `Chrome (web)      • chrome  • web-javascript • Google Chrome 149.0.7827.201`
    `Edge (web)        • edge    • web-javascript • Microsoft Edge 150.0.4078.48`
    `No devices are connected. Ensure that 'flutter doctor' shows at least one connected device`
- `flutter analyze integration_test/keyword_flow_test.dart`
  - Timed out after 120 seconds in this environment.
- `dart analyze integration_test/keyword_flow_test.dart`
  - Timed out after 120 seconds in this environment.
- `dart format --set-exit-if-changed --output=none integration_test/keyword_flow_test.dart`
  - Timed out after 120 seconds in this environment.

Scope:
- No other task items were implemented.
- Only `integration_test/keyword_flow_test.dart` was modified for code changes.

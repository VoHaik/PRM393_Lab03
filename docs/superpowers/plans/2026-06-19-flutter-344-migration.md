# Flutter 3.44 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the project build and run on Flutter 3.44 by removing the `IconData` final-class incompatibility and verifying the app compiles under the current SDK.

**Architecture:** The current failure happens before app code runs because `font_awesome_flutter 10.12.0` extends Flutter's now-final `IconData` class. Upgrade `font_awesome_flutter` to a Flutter 3.44-compatible release, refresh the lockfile, then compile and test the app. If any icon constant was renamed by the package upgrade, change only those icon references.

**Tech Stack:** Flutter 3.44, Dart 3.12, `font_awesome_flutter`, `flutter_test`, `go_router`, `flutter_bloc`.

---

## File Structure

- Modify: `pubspec.yaml`
  - Raise `font_awesome_flutter` from `^10.7.0` to `^11.0.0`.
- Modify: `pubspec.lock`
  - Refresh locked dependency versions through `flutter pub get`.
- Modify only if compilation reports missing icon names:
  - `lib/presentation/screens/analysis_screen.dart`
  - `lib/presentation/screens/dashboard_screen.dart`
  - `lib/presentation/screens/detail_screen.dart`
  - `lib/presentation/screens/search_screen.dart`
  - `lib/presentation/widgets/main_shell.dart`
- Test/verify:
  - `flutter pub get`
  - `flutter test`
  - `flutter analyze`
  - `flutter build windows` or `flutter build apk --debug`, depending on the available target machine.

---

### Task 1: Capture the Flutter 3.44 Baseline Failure

**Files:**
- Read: `pubspec.yaml`
- Read: `pubspec.lock`
- No source edits in this task.

- [ ] **Step 1: Confirm Flutter version**

Run:

```powershell
flutter --version
```

Expected: output includes Flutter `3.44.x` and Dart `3.12.x`.

- [ ] **Step 2: Reproduce the current compile failure**

Run:

```powershell
flutter test
```

Expected: FAIL during compilation with errors like:

```text
font_awesome_flutter-10.12.0/lib/src/icon_data.dart:
Error: The class 'IconData' can't be extended outside of its library because it's a final class.
class IconDataBrands extends IconData
```

- [ ] **Step 3: Confirm the locked package version**

Run:

```powershell
rg -n "font_awesome_flutter|version:" pubspec.yaml pubspec.lock
```

Expected: `pubspec.yaml` contains `font_awesome_flutter: ^10.7.0`, and `pubspec.lock` resolves `font_awesome_flutter` to `10.12.0`.

- [ ] **Step 4: Commit nothing**

No commit for this task. This task documents the starting failure only.

---

### Task 2: Upgrade Font Awesome Flutter

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

- [ ] **Step 1: Update dependency constraint**

Modify `pubspec.yaml`:

```yaml
  # UI & Styling
  google_fonts: ^6.1.0
  font_awesome_flutter: ^11.0.0
  shimmer: ^3.0.0
  url_launcher: ^6.2.5
```

- [ ] **Step 2: Refresh dependencies**

Run:

```powershell
flutter pub get
```

Expected: `pubspec.lock` updates `font_awesome_flutter` to `11.0.0` or a compatible newer `11.x` version.

- [ ] **Step 3: Verify the IconData error is gone**

Run:

```powershell
flutter test test\core\utils\abstract_parser_test.dart
```

Expected: PASS. This small test still compiles package imports and should no longer fail inside `font_awesome_flutter`.

- [ ] **Step 4: Commit**

Run:

```powershell
git add pubspec.yaml pubspec.lock
git commit -m "chore: upgrade font awesome for Flutter 3.44"
```

---

### Task 3: Fix Renamed or Removed Icon Constants If Needed

**Files:**
- Modify only files named by compiler errors:
  - `lib/presentation/screens/analysis_screen.dart`
  - `lib/presentation/screens/dashboard_screen.dart`
  - `lib/presentation/screens/detail_screen.dart`
  - `lib/presentation/screens/search_screen.dart`
  - `lib/presentation/widgets/main_shell.dart`

- [ ] **Step 1: Compile all app imports**

Run:

```powershell
flutter test test\widget_test.dart
```

Expected: either PASS, or FAIL with specific missing icon constants such as:

```text
Error: Member not found: 'FontAwesomeIcons.someIconName'
```

- [ ] **Step 2: If there are missing icon constants, replace only those names**

For each missing `FontAwesomeIcons.<name>`, search the installed package:

```powershell
rg -n "static const IconData .*<name>|<name>" "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\font_awesome_flutter-11.0.0\lib"
```

If the package provides a direct replacement, update the app reference. Example replacement pattern:

```dart
// Before
const Icon(FontAwesomeIcons.circleInfo, size: 18)

// After, only if the compiler says circleInfo was renamed
const Icon(FontAwesomeIcons.circleInfo, size: 18)
```

If no direct Font Awesome replacement exists, use the closest Material icon so the app remains stable:

```dart
const Icon(Icons.info_outline_rounded, size: 18)
```

- [ ] **Step 3: Re-run the widget compile test**

Run:

```powershell
flutter test test\widget_test.dart
```

Expected: PASS, or a non-Font-Awesome test assertion failure that is unrelated to the Flutter 3.44 migration.

- [ ] **Step 4: Commit if any Dart files changed**

Run:

```powershell
git add lib/presentation/screens/analysis_screen.dart lib/presentation/screens/dashboard_screen.dart lib/presentation/screens/detail_screen.dart lib/presentation/screens/search_screen.dart lib/presentation/widgets/main_shell.dart
git commit -m "fix: update icon references for Font Awesome 11"
```

If no Dart files changed, skip this commit.

---

### Task 4: Verify the Whole Project on Flutter 3.44

**Files:**
- No planned source edits.

- [ ] **Step 1: Run static analysis**

Run:

```powershell
flutter analyze
```

Expected: no compile errors. Existing lints may be handled in a separate cleanup only if they are unrelated to Flutter 3.44 compatibility.

- [ ] **Step 2: Run the full test suite**

Run:

```powershell
flutter test
```

Expected: all tests pass. The previous `IconData` final-class failure must not appear.

- [ ] **Step 3: Build a runnable target**

If Windows desktop is available, run:

```powershell
flutter build windows
```

Expected: build completes successfully.

If Android SDK is available, run:

```powershell
flutter build apk --debug
```

Expected: debug APK build completes successfully.

- [ ] **Step 4: Run the app**

For Windows:

```powershell
flutter run -d windows
```

For Chrome:

```powershell
flutter run -d chrome
```

For Android:

```powershell
flutter run -d <device-id>
```

Expected:
- App launches.
- Search screen renders icons.
- Searching `Artificial Intelligence` loads results.
- Trends tab renders charts and top journal list.
- Dashboard renders top journal sources without compile or runtime icon errors.

- [ ] **Step 5: Commit verification notes if the project report already tracks compatibility**

If an existing tracked report file has a dependency or environment section, add:

```text
Flutter 3.44 compatibility: upgraded font_awesome_flutter to a version compatible with final IconData and verified compile/test/build.
```

Then run:

```powershell
git add <tracked-report-file>
git commit -m "docs: document Flutter 3.44 compatibility"
```

If no tracked report file has such a section, skip this step.

---

## Self-Review

- Spec coverage: The plan addresses the known Flutter 3.44 blocker, dependency upgrade, possible icon API drift, full tests, static analysis, and runnable build verification.
- Placeholder scan: No `TBD`, `TODO`, or undefined implementation steps remain.
- Type consistency: The only planned dependency API is `FontAwesomeIcons.*`; code changes are limited to compiler-reported icon constants if the package upgrade requires them.

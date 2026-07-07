# Patrol Integration & UI Testing Plan

This implementation plan describes the technical steps to integrate the **LeanCode Patrol** testing framework into the Journal Trend Analyzer project. It will be used to write automated integration tests verifying the Authentication flow, search capabilities, and Analytics events logging in a deterministic environment.

---

## User Review Required

> [!IMPORTANT]
> Running Patrol tests on Android requires a running Android Emulator or connected physical device. 
> To execute Patrol tests, you will need to install the Patrol CLI on your computer using:
> `dart pub global activate patrol_cli`
> And run the tests with:
> `patrol test --target integration_test/auth_flow_test.dart`

---

## Open Questions

> [!NOTE]
> Since real Google Sign-In requires manual interaction with Google OAuth UI and Google Play Services, our automated tests will utilize **Mock Services** registered inside the GetIt container. This ensures test reliability and speed in CI/CD or local test environments without actual network calls.

---

## Proposed Changes

### Dependencies & Native Android Setup

#### [MODIFY] [pubspec.yaml](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/pubspec.yaml)
* Add `patrol: ^3.7.0` under `dev_dependencies`.

#### [MODIFY] [build.gradle.kts](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/build.gradle.kts)
* In `defaultConfig`, configure the test runner:
  ```kotlin
  testInstrumentationRunner = "pl.leancode.patrol.PatrolJUnitRunner"
  ```
* In the `dependencies` block, add the native test support:
  ```kotlin
  androidTestImplementation("pl.leancode.patrol:patrol_finder:3.7.0")
  ```

#### [NEW] [MainActivityTest.java](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/src/androidTest/java/com/example/journal_trend_analyzer/MainActivityTest.java)
Create the native Java test entry point class for Android instrumentation:
```java
package com.example.journal_trend_analyzer;

import androidx.test.rule.ActivityTestRule;
import dev.leancode.patrol.PatrolTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(PatrolTestRunner.class)
public class MainActivityTest {
    @Rule
    public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class, true, false);
}
```

---

### Test Suites Setup (`integration_test/`)

#### [NEW] [mock_services.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/mock_services.dart)
Create mock implementations of our service layers to bypass external system dependencies during tests:
* `MockAuthService`: Inherits/implements `AuthService` but returns pre-set fake users on login.
* `MockAnalyticsService`: Tracks which analytics events were triggered and exposes assertions to verify logs.

#### [NEW] [auth_flow_test.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/auth_flow_test.dart)
Write a Patrol UI integration test:
1. Launch the app and verify it redirects to `/login` (due to route guards).
2. Tap the "Continue with Google" button.
3. Simulate successful Google authentication using `MockAuthService`.
4. Verify the app navigates successfully to `/search` (Home).
5. Open the Profile tab, verify user info displays, tap "Sign Out", and verify redirect back to `/login`.

#### [NEW] [analytics_flow_test.dart](file:///c:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/analytics_flow_test.dart)
Write a Patrol integration test for Analytics event validation:
1. Log in.
2. Search for a topic (e.g. "Cybersecurity").
3. Verify that `logSearchTopic("Cybersecurity")` was called on the mock analytics service.
4. Click on a publication item.
5. Verify that `logViewPublication(title, year)` was called.

---

## Verification Plan

### Automated Tests
* Run `flutter analyze` to verify the test code compiles with no issues.
* Boot up an Android emulator and run:
  `patrol test --target integration_test/auth_flow_test.dart`
  `patrol test --target integration_test/analytics_flow_test.dart`

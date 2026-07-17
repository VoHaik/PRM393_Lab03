# Patrol E2E Test Execution Walkthrough

Detailed walkthrough of E2E test runs, findings, and resolutions to make integration tests pass on the physical Xiaomi device.

## Summary of Accomplished Work

1. **Gradle and Test Runner Compatibility (Patrol 3.x):**
   * Configured `:app:assembleDebugAndroidTest` to compile using the local `project(":patrol")` project binding instead of the deprecated `pl.leancode.patrol:patrol_finder` Maven package.
   * Rewrote [MainActivityTest.java](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/android/app/src/androidTest/java/com/example/journal_trend_analyzer/MainActivityTest.java) to use the new Parameterized JUnit test runner template required by Patrol 3.x, replacing legacy `PatrolTestRunner` references.

2. **Firebase Testing Initializer Fix:**
   * Resolved the `core/no-app` crash on Firebase SDK initialization by calling `Firebase.initializeApp` inside the E2E test widget setup in [auth_flow_test.dart](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/auth_flow_test.dart) and [analytics_flow_test.dart](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/analytics_flow_test.dart).

3. **GoRouter Redirect Guard Fix:**
   * Refactored [router.dart](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/lib/utils/navigation/router.dart) to check `context.read<AuthViewModel>().isAuthenticated` instead of querying the static `FirebaseAuth.instance.currentUser` property. This allows E2E mock services to cleanly control user login states and redirect guards.

4. **Xiaomi Background Activity Launch Resolution:**
   * Instructed the user to manually enable developer options and Xiaomi "Other Permissions" ("Start in background", "Display pop-up windows while running in the background", etc.) for the app under test.
   * Leveraged the `--no-uninstall` flag in the Patrol test runner command to prevent Gradle from uninstalling the app and resetting manually-granted permissions on every E2E execution.

5. **Visual Delays for Developers:**
   * Introduced 2-second visual pauses between key E2E test steps using `await $.tester.runAsync(() => Future.delayed(const Duration(seconds: 2)))` combined with `await $.pumpAndSettle()`. This prevents the test execution from flashing and exiting instantly, giving developers time to clearly observe test steps on the physical device.

---

## Test Run Results

### 1. Authentication Flow E2E Test
* **Target:** [auth_flow_test.dart](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/auth_flow_test.dart)
* **Results:**
  ```
  🧪 Verify Authentication Flow & Redirect Guards
        ⏳   1. tap widgets with text "Continue with Google".
        ✅   1. tap widgets with text "Continue with Google".
        ⏳   2. tap widgets with text "Profile".
        ✅   2. tap widgets with text "Profile".
        ⏳   3. tap widgets with text "Sign Out".
        ✅   3. tap widgets with text "Sign Out".
  ✅ Verify Authentication Flow & Redirect Guards (integration_test//auth_flow_test.dart) (12s)

  Test summary:
  📝 Total: 1 | ✅ Successful: 1 | ❌ Failed: 0
  ```

### 2. Analytics Flow E2E Test
* **Target:** [analytics_flow_test.dart](file:///C:/Users/KHAI/Documents/semester%208/PRM-Lab-03/PRM393_Lab03/integration_test/analytics_flow_test.dart)
* **Results:**
  ```
  🧪 Verify Firebase Analytics Event Logging
        ⏳   1. tap widgets with text "Continue with Google".
        ✅   1. tap widgets with text "Continue with Google".
        ⏳   2. enterText "Cybersecurity" widgets with type "TextField".
        ✅   2. enterText "Cybersecurity" widgets with type "TextField".
        ⏳   3. tap widgets with icon "IconData(U+0F57A)".
        ✅   3. tap widgets with icon "IconData(U+0F57A)".
        ⏳   4. tap widgets with text "Profile".
        ✅   4. tap widgets with text "Profile".
        ⏳   5. tap widgets with text "Sign Out".
        ✅   5. tap widgets with text "Sign Out".
  ✅ Verify Firebase Analytics Event Logging (integration_test//analytics_flow_test.dart) (19s)

  Test summary:
  📝 Total: 1 | ✅ Successful: 1 | ❌ Failed: 0
  ```

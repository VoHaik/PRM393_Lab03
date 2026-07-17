# Patrol E2E Test Execution Tasks

Checklist for debugging, compiling, and running Patrol E2E tests successfully on the physical Xiaomi device.

- [x] Fix Windows gradle pipe deadlock by adding early exit in `gradlew.bat` for `:app:dependencies`.
- [x] Align Gradle `androidTestImplementation` to use local `project(":patrol")` project binding.
- [x] Update `MainActivityTest.java` to use Patrol 3.x `Parameterized` runner and `PatrolJUnitRunner`.
- [x] Enable Xiaomi Developer Options and background app popup permissions.
- [x] Initialize Firebase before starting E2E test widgets to prevent `core/no-app` crash.
- [x] Update `router.dart` redirect guard to query `AuthViewModel` instead of static `FirebaseAuth.instance`.
- [x] Execute Patrol test targets with `--no-uninstall` flag to preserve device permissions.
- [x] Verify all Patrol E2E tests compile and pass successfully.

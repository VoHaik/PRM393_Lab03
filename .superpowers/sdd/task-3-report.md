Status: DONE

Commit: `72b71b3` (`test: cover keywords tab navigation`)

Test summary: `flutter test integration_test/keyword_flow_test.dart` hit the expected device-selection error, and `flutter test -d windows integration_test/keyword_flow_test.dart` failed because no Windows desktop project is configured.

Concerns:
- I could not complete a live integration run in this workspace because Flutter reports multiple available devices but no configured single integration target.
- The task file was updated only in `integration_test/keyword_flow_test.dart`; no fallback helper was needed because the Patrol `scrollUntilVisible` call compiled in the test file rewrite.

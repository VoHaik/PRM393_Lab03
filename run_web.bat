@echo off
echo ===================================================
echo Starting Journal Trend Analyzer on Chrome (Port 5000)
echo ===================================================
flutter run -d chrome --web-port=5000 --dart-define-from-file=.env.json
pause

#!/usr/bin/env bash
set -eo pipefail

echo "=============================================="
echo "Running Architecture Quality Gates & CI Checks"
echo "=============================================="

# 1. Automated Style Guard
echo ""
echo "1/5 Checking Style Guard (disallow raw color references in lib/features/)..."
if grep -rnE "Color\(0x|Colors\.(red|blue|green|grey)" lib/features/; then
  echo "FAILED: Raw color references found in lib/features/. Use design system tokens (context.colors.*)." >&2
  exit 1
fi
echo "PASSED: Style Guard - Zero raw colors in lib/features/."

# 2. Automated Layer Import Guard
echo ""
echo "2/5 Checking Layer Import Guard (disallow data imports in presentation UI)..."
if grep -rnE "import .*/data/" lib/features/*/presentation/ --exclude-dir=providers; then
  echo "FAILED: UI screens and widgets in presentation/ must not import data layer directly." >&2
  exit 1
fi
echo "PASSED: Layer Import Guard - Zero data imports in presentation UI screens and widgets."

# 3. Formatting Check
echo ""
echo "3/5 Checking Dart formatting..."
dart format --output=none --set-exit-if-changed .
echo "PASSED: Dart formatting is clean."

# 4. Static Analysis with Fatal Infos
echo ""
echo "4/5 Running Flutter analyze (--fatal-infos)..."
flutter analyze --fatal-infos
echo "PASSED: Flutter analyze reported 0 issues."

# 5. Full Test Suite
echo ""
echo "5/5 Running Flutter test suite..."
flutter test
echo "PASSED: All Flutter tests passed successfully."

echo ""
echo "=============================================="
echo "All quality gates passed with 100% compliance!"
echo "=============================================="

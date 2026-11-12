#!/usr/bin/env bash
set -eo pipefail

# Ensure script runs from project root regardless of where it is invoked from
cd "$(dirname "$0")/.."

echo "=============================================="
echo "Running Architecture Quality Gates & CI Checks"
echo "=============================================="

# 1. Automated Style Guard
echo ""
echo "1/8 Checking Style Guard (disallow raw color references in lib/features/)..."
if grep -rnE "Color\(0x|Colors\.(red|blue|green|grey)" lib/features/; then
  echo "FAILED: Raw color references found in lib/features/. Use design system tokens (context.colors.*)." >&2
  exit 1
fi
echo "PASSED: Style Guard - Zero raw colors in lib/features/."

# 2. Automated Layer Import Guard
echo ""
echo "2/8 Checking Layer Import Guard (disallow data imports/exports in presentation layer)..."
if grep -rnE "(import|export) .*/data/" lib/features/*/presentation/; then
  echo "FAILED: Presentation layer (screens, widgets, providers) must not import or export data layer directly." >&2
  exit 1
fi
if grep -rnE "(import|export) .*/data/" lib/ | grep -v "lib/features/[^/]*/data/" | grep -v "lib/core/providers/repository_providers.dart"; then
  echo "FAILED: Unauthorized data import outside data layer and approved composition boundary (lib/core/providers/repository_providers.dart)." >&2
  exit 1
fi
echo "PASSED: Layer Import Guard - Zero data imports or exports in presentation layer; approved composition boundary verified."

# 3. Automated Domain Purity Guard
echo ""
echo "3/8 Checking Domain Purity Guard (disallow Flutter/Dio/platform imports in domain)..."
if grep -rnE "import '(package:flutter|package:dio|package:dmrtd)" lib/features/*/domain/; then
  echo "FAILED: Domain layer must be pure Dart. No Flutter, Dio, or platform packages." >&2
  exit 1
fi
echo "PASSED: Domain Purity Guard - 100% pure Dart domain layer."

# 4. Automated Cross-Feature Encapsulation Guard
echo ""
echo "4/8 Checking Feature Encapsulation Guard (disallow cross-feature presentation/data imports)..."
python3 -c "
import os, re, sys

feature_pattern = re.compile(r'lib/features/([^/]+)/')
import_pattern = re.compile(r\"import\s+['\\\"]package:trvlez_mobile/features/([^/]+)/(presentation|data)/\")

violations = []
for root, dirs, files in os.walk('lib/features'):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            m_feat = feature_pattern.search(filepath)
            if not m_feat:
                continue
            cur_feature = m_feat.group(1)
            with open(filepath) as fp:
                for line_no, line in enumerate(fp, 1):
                    m_imp = import_pattern.search(line)
                    if m_imp:
                        imp_feature = m_imp.group(1)
                        if cur_feature != imp_feature:
                            violations.append(f'{filepath}:{line_no} ({cur_feature}) -> imports ({imp_feature}): {line.strip()}')

if violations:
    print('FAILED: Cross-feature presentation/data imports found:')
    for v in violations:
        print(v)
    sys.exit(1)
"
echo "PASSED: Feature Encapsulation Guard - Zero cross-feature presentation or data imports."

# 5. Semantic Layout Token Guard
echo ""
echo "5/8 Checking cross-device layout policy guard..."
python3 scripts/test_verify_layout_tokens.py
python3 scripts/verify_layout_tokens.py
python3 scripts/test_write_capture_metadata.py

# 6. Formatting Check
echo ""
echo "6/8 Checking Dart formatting..."
dart format --output=none --set-exit-if-changed .
echo "PASSED: Dart formatting is clean."

# 7. Static Analysis with Fatal Infos
echo ""
echo "7/8 Running Flutter analyze (--fatal-infos)..."
flutter analyze --fatal-infos
echo "PASSED: Flutter analyze reported 0 issues."

# 8. Full Test Suite
echo ""
echo "8/8 Running Flutter test suite..."
flutter test
echo "PASSED: All Flutter tests passed successfully."

echo ""
echo "=============================================="
echo "All quality gates passed with 100% compliance!"
echo "=============================================="

#!/usr/bin/env python3
"""
CI Guard: Enforce semantic layout tokens across lib/.

Scans all Dart files in lib/ (excluding lib/core/design_tokens/) to ensure:
1. Zero raw layout numbers in EdgeInsets, BorderRadius, Radius.circular, SizedBox, Icon(size:).
2. Zero references to deprecated legacy tokens (AppSpacing.*, AppRadius.*).
"""

import os
import re
import sys

# Allowed directories/files where primitives/tokens are defined
ALLOWED_PATHS = {
    'lib/core/design_tokens',
    'lib/app/theme/tokens/app_spacing.dart',
    'lib/app/theme/tokens/app_radius.dart',
}

EXCLUDED_FILE_SUFFIXES = (
    '.g.dart',
    '.freezed.dart',
)

# Patterns that detect raw layout numbers
# Regexes avoid matching token expressions like 'space.stackText / 2' or 'space.inlineButtonGroup + 2'
PATTERNS = {
    'EdgeInsets raw literal': re.compile(
        r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*:\s*[1-9]\d*(\.\d+)?\s*[,)]|EdgeInsets\.(all|fromLTRB)\(\s*[1-9]\d*(\.\d+)?\s*[,)]'
    ),
    'BorderRadius raw literal': re.compile(
        r'BorderRadius\.(circular|only|vertical|horizontal)\([^)]*:\s*[1-9]\d*(\.\d+)?\s*[,)]|BorderRadius\.circular\(\s*[1-9]\d*(\.\d+)?\s*\)'
    ),
    'Radius.circular raw literal': re.compile(
        r'Radius\.circular\(\s*[1-9]\d*(\.\d+)?\s*\)'
    ),
    'SizedBox raw width/height': re.compile(
        r'SizedBox\(\s*(width|height):\s*[1-9]\d*(\.\d+)?\s*[,)]'
    ),
    'Icon raw size': re.compile(
        r'Icon\([^)]*size:\s*[1-9]\d*(\.\d+)?'
    ),
    'Deprecated AppSpacing reference': re.compile(
        r'\bAppSpacing\.\w+'
    ),
    'Deprecated AppRadius reference': re.compile(
        r'\bAppRadius\.\w+'
    ),
}


def is_allowed(path: str) -> bool:
    for allowed in ALLOWED_PATHS:
        if path == allowed or path.startswith(allowed + '/'):
            return True
    return False


def main() -> int:
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    lib_dir = os.path.join(root_dir, 'lib')

    violations = []
    scanned_files = 0

    for current_root, _, files in os.walk(lib_dir):
        for file_name in files:
            if not file_name.endswith('.dart'):
                continue
            if any(file_name.endswith(suffix) for suffix in EXCLUDED_FILE_SUFFIXES):
                continue

            rel_path = os.path.relpath(os.path.join(current_root, file_name), root_dir)
            if is_allowed(rel_path):
                continue

            scanned_files += 1
            full_path = os.path.join(current_root, file_name)

            with open(full_path, 'r', encoding='utf-8') as fp:
                for line_no, raw_line in enumerate(fp, start=1):
                    line = raw_line.strip()
                    if line.startswith('//') or line.startswith('/*') or line.startswith('*'):
                        continue

                    for rule_name, pattern in PATTERNS.items():
                        if pattern.search(raw_line):
                            violations.append((rel_path, line_no, rule_name, line))

    if violations:
        print(f"FAILED: Found {len(violations)} raw layout violations in {scanned_files} scanned files:\n")
        for path, line_no, rule_name, line in violations:
            print(f"  {path}:{line_no} [{rule_name}] -> {line}")
        print("\nFix: Use semantic layout tokens via context.space, context.sizes, or context.shape.")
        return 1

    print(f"PASSED: Semantic Layout Token Guard - 100% compliance across {scanned_files} files in lib/.")
    return 0


if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3
"""CI guard for layout patterns that fragment phone UI.

This guard deliberately does *not* ban every numeric layout value. Chapter 04
allows documented component-private constants, framework constraints, and
aspect ratios. The guard only checks patterns that are unambiguously unsafe in
presentation code: device/OS layout branching, disabled text scaling, and
deprecated token names.
"""

import argparse
import os
import re
import sys

# Allowed directories/files where primitives/tokens are defined
ALLOWED_PATHS = {
    'core/design_tokens',
}

EXCLUDED_FILE_SUFFIXES = (
    '.g.dart',
    '.freezed.dart',
)

POLICY_PATTERNS = {
    'OS-specific layout branch': re.compile(r'\bPlatform\.is(?:Android|IOS)\b'),
    'Device-model layout branch': re.compile(
        r'\b(?:realme|pixel|galaxy|samsung|iphone|ipad)\b', re.IGNORECASE
    ),
    'Disabled system text scaling': re.compile(r'\bTextScaler\.noScaling\b'),
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


def is_presentation_path(path: str) -> bool:
    return '/presentation/' in path or path.startswith('core/widgets/')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--lib-dir',
        help='Dart source directory to scan; defaults to the repository lib/.',
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    lib_dir = os.path.abspath(args.lib_dir or os.path.join(root_dir, 'lib'))

    violations = []
    scanned_files = 0

    for current_root, _, files in os.walk(lib_dir):
        for file_name in files:
            if not file_name.endswith('.dart'):
                continue
            if any(file_name.endswith(suffix) for suffix in EXCLUDED_FILE_SUFFIXES):
                continue

            rel_path = os.path.relpath(os.path.join(current_root, file_name), lib_dir)
            if is_allowed(rel_path):
                continue

            scanned_files += 1
            full_path = os.path.join(current_root, file_name)

            with open(full_path, 'r', encoding='utf-8') as fp:
                for line_no, raw_line in enumerate(fp, start=1):
                    line = raw_line.strip()
                    if line.startswith('//') or line.startswith('/*') or line.startswith('*'):
                        continue

                    patterns = {
                        'Deprecated AppSpacing reference': POLICY_PATTERNS[
                            'Deprecated AppSpacing reference'
                        ],
                        'Deprecated AppRadius reference': POLICY_PATTERNS[
                            'Deprecated AppRadius reference'
                        ],
                    }
                    if is_presentation_path(rel_path):
                        patterns.update({
                            name: pattern
                            for name, pattern in POLICY_PATTERNS.items()
                            if name not in patterns
                        })

                    for rule_name, pattern in patterns.items():
                        if pattern.search(raw_line):
                            violations.append((rel_path, line_no, rule_name, line))

    if violations:
        print(f"FAILED: Found {len(violations)} layout-policy violations in {scanned_files} scanned files:\n")
        for path, line_no, rule_name, line in violations:
            print(f"  {path}:{line_no} [{rule_name}] -> {line}")
        print("\nFix: Use constraints, framework insets, and supported text scaling; do not branch presentation layout by OS or device model.")
        return 1

    print(f"PASSED: Cross-device layout policy guard across {scanned_files} files.")
    return 0


if __name__ == '__main__':
    sys.exit(main())

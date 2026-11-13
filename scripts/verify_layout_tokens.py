#!/usr/bin/env python3
"""CI guard for layout, token, scaling, and architectural boundaries.

This guard enforces playbook rules across Dart code in lib/:
- Device and OS layout branching (chapter 00, 03)
- Disabled or linearly replaced text scaling (chapter 00, 03, ADR 0002)
- Deprecated token references (chapter 04)
- Presentation primitive imports and inline styling (chapter 04, 10 §4.5)
- Unsafe viewport-height formulas (chapter 03 LAY-01)
- Presentation-to-data imports (chapter 01 ARC-01)

Documented component-private constants and component-theme definitions are
intentionally permitted.
"""

import argparse
import os
import re
import sys

ALLOWED_PATHS = {
    'core/design_tokens',
    'app/theme/component_themes',
}

EXCLUDED_FILE_SUFFIXES = (
    '.g.dart',
    '.freezed.dart',
)

APPROVED_COMPOSITION_BOUNDARIES = {
    'core/providers/repository_providers.dart',
}

# A temporary policy exception must identify the exact guard, explain the
# user-facing safety rationale, and carry a review date. It must also be
# centrally allowlisted by path and line; an inline comment alone is never a
# policy bypass.
GUARD_EXCEPTION_PATTERN = re.compile(
    r'//\s*guard-exception:\s*'
    r'(?P<rule>[A-Za-z][A-Za-z0-9 -]+?)\s*\|\s*'
    r'(?P<reason>[^|]+?)\s*\|\s*'
    r'review:\s*(?P<review_date>\d{4}-\d{2}-\d{2})\s*$'
)

# Key: (relative source path, one-based line, guard-rule name).
# Value: approved rationale. Keep this empty unless an approved exception is
# genuinely needed; each entry is intentionally reviewable in code review.
APPROVED_GUARD_EXCEPTIONS: dict[tuple[str, int, str], str] = {}

POLICY_PATTERNS = {
    'OS-specific layout branch': re.compile(r'\bPlatform\.is(?:Android|IOS)\b'),
    'Device-model layout branch': re.compile(
        r'\b(?:realme|pixel|galaxy|samsung|iphone|ipad)\b', re.IGNORECASE
    ),
    'Disabled system text scaling': re.compile(r'\bTextScaler\.noScaling\b'),
    'Deprecated AppSpacing reference': re.compile(r'\bAppSpacing\.\w+'),
    'Deprecated AppRadius reference': re.compile(r'\bAppRadius\.\w+'),
}

PRESENTATION_PATTERNS = {
    'Banned primitive token import': re.compile(
        r"import\s+['\"][^'\"]*tokens/primitives/[^'\"]*['\"]"
    ),
    'Banned primitive token reference': re.compile(
        r'\b(?:Palette|Prim|TypeScale)\b'
    ),
    'Banned AppTypography in presentation': re.compile(
        r'\bAppTypography\b'
    ),
    'Banned inline TextStyle': re.compile(r'\bTextStyle\s*\('),
    'Banned raw Material Color': re.compile(r'\bColors\.\w+'),
    'Unsafe viewport-height formula': re.compile(
        r'\bMediaQuery\.(?:sizeOf\([^)]*\)|of\([^)]*\)\.size)\.height\s*\*'
    ),
    'Replaced linear text scaling': re.compile(r'\bTextScaler\.linear\s*\('),
    'Banned data import in presentation': re.compile(
        r"(?:import|export)\s+['\"][^'\"]*/data/[^'\"]*['\"]"
    ),
}

DATA_IMPORT_PATTERN = re.compile(r"(?:import|export)\s+['\"][^'\"]*/data/[^'\"]*['\"]")


def is_allowed(path: str) -> bool:
    for allowed in ALLOWED_PATHS:
        if path == allowed or path.startswith(allowed + '/'):
            return True
    return False


def is_presentation_path(path: str) -> bool:
    return '/presentation/' in path or path.startswith('core/widgets/')


def is_data_path(path: str) -> bool:
    return '/data/' in path


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
                    exception = GUARD_EXCEPTION_PATTERN.search(raw_line)
                    if exception:
                        exception_key = (
                            rel_path,
                            line_no,
                            exception.group('rule'),
                        )
                        approved_reason = APPROVED_GUARD_EXCEPTIONS.get(
                            exception_key,
                        )
                        if approved_reason == exception.group('reason').strip():
                            continue
                        violations.append((
                            rel_path,
                            line_no,
                            'Unapproved guard exception',
                            line,
                        ))
                        continue
                    if '// allow-guard-exception' in line or '// allow-token-override' in line:
                        violations.append((
                            rel_path,
                            line_no,
                            'Unstructured guard exception',
                            line,
                        ))
                        continue

                    # Check global architecture and token policies
                    for rule_name in (
                        'Deprecated AppSpacing reference',
                        'Deprecated AppRadius reference',
                    ):
                        if POLICY_PATTERNS[rule_name].search(raw_line):
                            violations.append((rel_path, line_no, rule_name, line))

                    # Check layer boundary: only data layer and approved composition boundaries may import data
                    if not is_data_path(rel_path) and rel_path not in APPROVED_COMPOSITION_BOUNDARIES:
                        if DATA_IMPORT_PATTERN.search(raw_line):
                            violations.append((
                                rel_path,
                                line_no,
                                'Unauthorized data layer import outside data layer or composition boundary',
                                line,
                            ))

                    # Check presentation policies
                    if is_presentation_path(rel_path):
                        for rule_name, pattern in POLICY_PATTERNS.items():
                            if pattern.search(raw_line):
                                violations.append((rel_path, line_no, rule_name, line))

                        for rule_name, pattern in PRESENTATION_PATTERNS.items():
                            if pattern.search(raw_line):
                                violations.append((rel_path, line_no, rule_name, line))

    if violations:
        print(f"FAILED: Found {len(violations)} conformance-policy violations in {scanned_files} scanned files:\n")
        for path, line_no, rule_name, line in violations:
            print(f"  {path}:{line_no} [{rule_name}] -> {line}")
        print("\nFix: Use constraints, semantic tokens, and supported text scaling; do not import data in presentation or branch layout.")
        return 1

    print(f"PASSED: Conformance and layout policy guard across {scanned_files} files.")
    return 0


if __name__ == '__main__':
    sys.exit(main())

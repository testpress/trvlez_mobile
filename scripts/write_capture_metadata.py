#!/usr/bin/env python3
"""Validate runtime MediaQuery data and write screenshot evidence metadata."""

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


INSET_KEYS = ('top', 'right', 'bottom', 'left')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument('--runtime-media-query', required=True, type=Path)
    parser.add_argument('--platform', choices=('android', 'ios'), required=True)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--device-model', default='unknown')
    parser.add_argument('--os-version', default='unknown')
    parser.add_argument('--physical-display', default='unknown')
    parser.add_argument('--filename-fields', action='store_true')
    return parser.parse_args()


def positive_number(value: Any, name: str) -> float:
    if not isinstance(value, (int, float)) or isinstance(value, bool) or value <= 0:
        raise ValueError(f'{name} must be a positive number')
    return float(value)


def inset(value: Any, name: str) -> dict[str, float]:
    if not isinstance(value, dict):
        raise ValueError(f'{name} must be an object')
    result = {}
    for key in INSET_KEYS:
        number = value.get(key, 0)
        if not isinstance(number, (int, float)) or isinstance(number, bool) or number < 0:
            raise ValueError(f'{name}.{key} must be a non-negative number')
        result[key] = float(number)
    return result


def load_runtime_media_query(path: Path) -> dict[str, Any]:
    with path.open(encoding='utf-8') as source:
        raw = json.load(source)
    if not isinstance(raw, dict):
        raise ValueError('runtime metadata must be a JSON object')

    logical_size = raw.get('logicalSize')
    if not isinstance(logical_size, dict):
        raise ValueError('logicalSize must be an object')

    inset_state = raw.get('insetState')
    keyboard_state = raw.get('keyboardState')
    if not isinstance(inset_state, str) or not inset_state:
        raise ValueError('insetState must be a non-empty string')
    if not isinstance(keyboard_state, str) or not keyboard_state:
        raise ValueError('keyboardState must be a non-empty string')

    return {
        'logicalSize': {
            'width': positive_number(logical_size.get('width'), 'logicalSize.width'),
            'height': positive_number(logical_size.get('height'), 'logicalSize.height'),
        },
        'devicePixelRatio': positive_number(raw.get('devicePixelRatio'), 'devicePixelRatio'),
        'textScale': positive_number(raw.get('textScale'), 'textScale'),
        'padding': inset(raw.get('padding'), 'padding'),
        'viewPadding': inset(raw.get('viewPadding'), 'viewPadding'),
        'viewInsets': inset(raw.get('viewInsets'), 'viewInsets'),
        'insetState': inset_state,
        'keyboardState': keyboard_state,
    }


def format_number(value: float) -> str:
    return str(int(value)) if value.is_integer() else str(value)


def main() -> int:
    args = parse_args()
    try:
        runtime = load_runtime_media_query(args.runtime_media_query)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        raise SystemExit(f'Invalid runtime MediaQuery metadata: {error}')

    if args.filename_fields:
        size = runtime['logicalSize']
        print(
            f"{format_number(size['width'])}x{format_number(size['height'])} "
            f"{format_number(runtime['textScale'])} {runtime['insetState']}"
        )
        return 0

    if args.output is None:
        raise SystemExit('--output is required unless --filename-fields is used')

    payload = {
        'capturedAt': datetime.now(timezone.utc).isoformat(),
        'capture': {
            'platform': args.platform,
            'deviceModel': args.device_model,
            'osVersion': args.os_version,
            'physicalDisplay': args.physical_display,
        },
        'runtimeMediaQuery': runtime,
    }
    args.output.write_text(json.dumps(payload, indent=2) + '\n', encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

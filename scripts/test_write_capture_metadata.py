#!/usr/bin/env python3
"""Regression tests for validated screenshot-capture metadata."""

import json
import pathlib
import subprocess
import sys
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parent.parent
WRITER = ROOT / 'scripts' / 'write_capture_metadata.py'
VALID_RUNTIME = {
    'logicalSize': {'width': 393, 'height': 852},
    'devicePixelRatio': 2.75,
    'textScale': 1.3,
    'padding': {'top': 24, 'right': 0, 'bottom': 24, 'left': 0},
    'viewPadding': {'top': 24, 'right': 0, 'bottom': 24, 'left': 0},
    'viewInsets': {'top': 0, 'right': 0, 'bottom': 0, 'left': 0},
    'insetState': 'gesture-nav',
    'keyboardState': 'closed',
}


class WriteCaptureMetadataTest(unittest.TestCase):
    def test_uses_measured_runtime_values_for_filename_fields_and_sidecar(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            directory_path = pathlib.Path(directory)
            runtime_path = directory_path / 'runtime.json'
            output_path = directory_path / 'capture.json'
            runtime_path.write_text(json.dumps(VALID_RUNTIME), encoding='utf-8')

            fields = subprocess.run(
                [sys.executable, str(WRITER), '--runtime-media-query', str(runtime_path), '--platform', 'android', '--filename-fields'],
                check=True,
                capture_output=True,
                text=True,
            )
            self.assertEqual(fields.stdout.strip(), '393x852 1.3 gesture-nav')

            subprocess.run(
                [sys.executable, str(WRITER), '--runtime-media-query', str(runtime_path), '--platform', 'android', '--output', str(output_path)],
                check=True,
            )
            payload = json.loads(output_path.read_text(encoding='utf-8'))
            self.assertEqual(payload['runtimeMediaQuery'], VALID_RUNTIME)
            self.assertEqual(payload['capture']['platform'], 'android')

    def test_rejects_incomplete_runtime_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            runtime_path = pathlib.Path(directory) / 'runtime.json'
            runtime_path.write_text('{"logicalSize": {"width": 393}}', encoding='utf-8')
            result = subprocess.run(
                [sys.executable, str(WRITER), '--runtime-media-query', str(runtime_path), '--platform', 'ios', '--filename-fields'],
                check=False,
                capture_output=True,
                text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('Invalid runtime MediaQuery metadata', result.stderr)


if __name__ == '__main__':
    unittest.main()

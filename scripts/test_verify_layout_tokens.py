#!/usr/bin/env python3
"""Regression tests for the cross-device layout and architecture policy guard."""

import pathlib
import subprocess
import sys
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parent.parent
GUARD = ROOT / 'scripts' / 'verify_layout_tokens.py'


class VerifyLayoutTokensTest(unittest.TestCase):
    def run_guard(self, files: dict[str, str]) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory) / 'lib'
            for relative_path, source in files.items():
                target = root / relative_path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(source, encoding='utf-8')
            return subprocess.run(
                [sys.executable, str(GUARD), '--lib-dir', str(root)],
                check=False,
                capture_output=True,
                text=True,
            )

    def test_allows_documented_component_constant(self) -> None:
        result = self.run_guard({
            'features/example/presentation/widget.dart': (
                'const _trackHeight = 2.0;\n'
                'const _previewRatio = 16 / 9;\n'
            ),
        })
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_rejects_device_specific_presentation_branch(self) -> None:
        result = self.run_guard({
            'features/example/presentation/widget.dart': (
                "final isAndroid = Platform.isAndroid;\n"
            ),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('OS-specific layout branch', result.stdout)

    def test_rejects_disabled_text_scaling(self) -> None:
        result = self.run_guard({
            'core/widgets/widget.dart': 'const scaler = TextScaler.noScaling;\n',
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Disabled system text scaling', result.stdout)

    def test_rejects_linear_text_scaling_in_presentation(self) -> None:
        result = self.run_guard({
            'features/example/presentation/widget.dart': (
                'final scaler = TextScaler.linear(1.5);\n'
            ),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Replaced linear text scaling', result.stdout)

    def test_rejects_unsafe_viewport_height_formula(self) -> None:
        result = self.run_guard({
            'features/example/presentation/widget.dart': (
                'final h = MediaQuery.sizeOf(context).height * 0.75;\n'
            ),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Unsafe viewport-height formula', result.stdout)

    def test_rejects_presentation_data_import(self) -> None:
        result = self.run_guard({
            'features/example/presentation/screens/sample_screen.dart': (
                "import 'package:trvlez_mobile/features/example/data/datasources/remote.dart';\n"
            ),
        })
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Banned data import in presentation', result.stdout)

    def test_allows_approved_composition_boundary_data_import(self) -> None:
        result = self.run_guard({
            'core/providers/repository_providers.dart': (
                "import 'package:trvlez_mobile/features/auth/data/repositories/auth_repository_impl.dart';\n"
            ),
        })
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_allows_documented_guard_exception(self) -> None:
        result = self.run_guard({
            'features/example/presentation/widget.dart': (
                'final style = TextStyle(fontSize: 12); // allow-guard-exception\n'
            ),
        })
        self.assertEqual(result.returncode, 0, result.stdout)


if __name__ == '__main__':
    unittest.main()

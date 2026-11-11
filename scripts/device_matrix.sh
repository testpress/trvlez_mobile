#!/usr/bin/env bash
set -eo pipefail

# ==============================================================================
# TrvlEz Mobile Phone Device Matrix Capture & Validation Tool
#
# Follows standards in:
#   docs/engineering/playbook/05-visual-validation-standard.md
#   docs/engineering/playbook/06-testing-device-matrix.md
# ==============================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVIDENCE_DIR="${ROOT_DIR}/docs/engineering/evidence/screenshots"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [arguments]

Commands:
  list-devices
      List available Android devices/emulators and iOS simulators.

  capture-android <feature> <state> <width>x<height> <scale> <inset_state> [device_id]
      Capture screenshot from connected Android device using the playbook naming standard:
      <feature>__<state>__android__<width>x<height>__text-<scale>__<inset_state>.png

  capture-ios <feature> <state> <width>x<height> <scale> <inset_state> [simulator_id]
      Capture screenshot from booted iOS simulator.

  run-integration [device_id]
      Run integration test suite on the specified connected device or emulator.

  help
      Show this message.

Examples:
  $(basename "$0") capture-android login default 393x852 1.0 gesture-nav
  $(basename "$0") capture-android profile keyboard 412x915 1.3 3button-nav emulator-5554
  $(basename "$0") run-integration emulator-5554
EOF
  exit 1
}

cmd_list_devices() {
  echo "=== Connected Android Devices / Emulators (adb) ==="
  if command -v adb >/dev/null 2>&1; then
    adb devices -l
  else
    echo "adb not found in PATH."
  fi

  echo ""
  echo "=== Available Flutter Devices ==="
  flutter devices
}

cmd_capture_android() {
  local feature="${1:?Missing feature name}"
  local state="${2:?Missing state (e.g. default, error, keyboard, loading)}"
  local dimensions="${3:?Missing dimensions (e.g. 393x852)}"
  local scale="${4:?Missing text scale (e.g. 1.0, 1.3, 2.0)}"
  local inset="${5:?Missing inset state (e.g. gesture-nav, 3button-nav)}"
  local device_id="${6:-}"

  mkdir -p "${EVIDENCE_DIR}"
  local filename="${feature}__${state}__android__${dimensions}__text-${scale}__${inset}.png"
  local target_path="${EVIDENCE_DIR}/${filename}"

  local adb_cmd=(adb)
  if [[ -n "${device_id}" ]]; then
    adb_cmd+=(-s "${device_id}")
  fi

  echo "Capturing screenshot to ${target_path}..."
  "${adb_cmd[@]}" exec-out screencap -p > "${target_path}"

  if [[ -s "${target_path}" ]]; then
    echo "SUCCESS: Screenshot saved to ${target_path}"
    echo "File size: $(wc -c < "${target_path}") bytes"
  else
    echo "ERROR: Failed to capture screenshot or file is empty." >&2
    rm -f "${target_path}"
    exit 1
  fi
}

cmd_capture_ios() {
  local feature="${1:?Missing feature name}"
  local state="${2:?Missing state}"
  local dimensions="${3:?Missing dimensions}"
  local scale="${4:?Missing text scale}"
  local inset="${5:?Missing inset state}"
  local device_id="${6:-booted}"

  mkdir -p "${EVIDENCE_DIR}"
  local filename="${feature}__${state}__ios__${dimensions}__text-${scale}__${inset}.png"
  local target_path="${EVIDENCE_DIR}/${filename}"

  echo "Capturing iOS screenshot to ${target_path}..."
  xcrun simctl io "${device_id}" screenshot "${target_path}"

  if [[ -s "${target_path}" ]]; then
    echo "SUCCESS: Screenshot saved to ${target_path}"
  else
    echo "ERROR: Failed to capture iOS screenshot." >&2
    rm -f "${target_path}"
    exit 1
  fi
}

cmd_run_integration() {
  local device_id="${1:-}"
  local test_target="integration_test/auth_login_flow_test.dart"

  echo "=== Running Integration Test: ${test_target} ==="
  if [[ -n "${device_id}" ]]; then
    flutter test "${test_target}" -d "${device_id}"
  else
    flutter test "${test_target}"
  fi
}

case "${1:-}" in
  list-devices)
    cmd_list_devices
    ;;
  capture-android)
    shift
    cmd_capture_android "$@"
    ;;
  capture-ios)
    shift
    cmd_capture_ios "$@"
    ;;
  run-integration)
    shift
    cmd_run_integration "$@"
    ;;
  help|--help|-h|"")
    usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage
    ;;
esac

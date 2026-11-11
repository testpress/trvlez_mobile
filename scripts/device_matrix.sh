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
METADATA_WRITER="${ROOT_DIR}/scripts/write_capture_metadata.py"

usage() {
  local exit_code="${1:-1}"
  cat <<EOF
Usage: $(basename "$0") <command> [arguments]

Commands:
  list-devices
      List available Android devices/emulators and iOS simulators.

  capture-android <feature> <state> <runtime-media-query.json> [device_id]
      Capture an Android screenshot and validated runtime-MediaQuery sidecar.

  capture-ios <feature> <state> <runtime-media-query.json> [simulator_id]
      Capture an iOS simulator screenshot and validated runtime-MediaQuery sidecar.

  run-integration [device_id] [test_target]
      Run an integration test on the specified connected device or emulator.

  help
      Show this message.

Examples:
  $(basename "$0") capture-android login default /tmp/login-media-query.json
  $(basename "$0") capture-android profile keyboard /tmp/profile-media-query.json emulator-5554
  $(basename "$0") run-integration emulator-5554
EOF
  exit "${exit_code}"
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
  local runtime_media_query="${3:?Missing runtime MediaQuery JSON path}"
  local device_id="${4:-}"
  local dimensions scale inset

  read -r dimensions scale inset < <(
    python3 "${METADATA_WRITER}" \
      --runtime-media-query "${runtime_media_query}" \
      --platform android \
      --filename-fields
  )

  mkdir -p "${EVIDENCE_DIR}"
  local filename="${feature}__${state}__android__${dimensions}__text-${scale}__${inset}.png"
  local target_path="${EVIDENCE_DIR}/${filename}"
  local metadata_path="${target_path%.png}.json"

  local adb_cmd=(adb)
  if [[ -n "${device_id}" ]]; then
    adb_cmd+=(-s "${device_id}")
  fi

  echo "Capturing screenshot to ${target_path}..."
  "${adb_cmd[@]}" exec-out screencap -p > "${target_path}"

  if [[ -s "${target_path}" ]]; then
    echo "SUCCESS: Screenshot saved to ${target_path}"
    echo "File size: $(wc -c < "${target_path}") bytes"
    python3 "${METADATA_WRITER}" \
      --runtime-media-query "${runtime_media_query}" \
      --platform android \
      --output "${metadata_path}" \
      --device-model "$("${adb_cmd[@]}" shell getprop ro.product.model | tr -d '\r')" \
      --os-version "$("${adb_cmd[@]}" shell getprop ro.build.version.release | tr -d '\r')" \
      --physical-display "$("${adb_cmd[@]}" shell wm size | tr '\n' ';' | tr -d '\r')"
    echo "Evidence metadata saved to ${metadata_path}"
  else
    echo "ERROR: Failed to capture screenshot or file is empty." >&2
    rm -f "${target_path}"
    exit 1
  fi
}

cmd_capture_ios() {
  local feature="${1:?Missing feature name}"
  local state="${2:?Missing state}"
  local runtime_media_query="${3:?Missing runtime MediaQuery JSON path}"
  local device_id="${4:-booted}"
  local dimensions scale inset

  read -r dimensions scale inset < <(
    python3 "${METADATA_WRITER}" \
      --runtime-media-query "${runtime_media_query}" \
      --platform ios \
      --filename-fields
  )

  mkdir -p "${EVIDENCE_DIR}"
  local filename="${feature}__${state}__ios__${dimensions}__text-${scale}__${inset}.png"
  local target_path="${EVIDENCE_DIR}/${filename}"
  local metadata_path="${target_path%.png}.json"

  echo "Capturing iOS screenshot to ${target_path}..."
  xcrun simctl io "${device_id}" screenshot "${target_path}"

  if [[ -s "${target_path}" ]]; then
    echo "SUCCESS: Screenshot saved to ${target_path}"
    python3 "${METADATA_WRITER}" \
      --runtime-media-query "${runtime_media_query}" \
      --platform ios \
      --output "${metadata_path}" \
      --device-model "iOS Simulator" \
      --os-version "$(xcrun simctl getenv "${device_id}" SIMULATOR_RUNTIME_VERSION 2>/dev/null || echo unknown)"
    echo "Evidence metadata saved to ${metadata_path}"
  else
    echo "ERROR: Failed to capture iOS screenshot." >&2
    rm -f "${target_path}"
    exit 1
  fi
}

cmd_run_integration() {
  local device_id="${1:-}"
  local test_target="${2:-integration_test/auth_login_flow_test.dart}"

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
    usage 0
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage
    ;;
esac

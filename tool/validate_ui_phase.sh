#!/usr/bin/env bash

set -Eeuo pipefail

CURRENT_STAGE="startup"
trap 'echo "VALIDATION FAILED: ${CURRENT_STAGE}"' ERR

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

MODE="design-system"
FORMAT_PATHS=()
ANALYZE_PATHS=()
TEST_PATHS=()

while (($# > 0)); do
  case "$1" in
    --mode)
      MODE="${2:?Missing value for --mode}"
      shift 2
      ;;
    --format-path)
      FORMAT_PATHS+=("${2:?Missing value for --format-path}")
      shift 2
      ;;
    --analyze-path)
      ANALYZE_PATHS+=("${2:?Missing value for --analyze-path}")
      shift 2
      ;;
    --test-path)
      TEST_PATHS+=("${2:?Missing value for --test-path}")
      shift 2
      ;;
    *)
      echo "VALIDATION FAILED: unsupported argument $1"
      exit 1
      ;;
  esac
done

DESIGN_SYSTEM_FILES=(
  "packages/pharmaconnect_design_system/lib/src/color/pharmaconnect_colors.dart"
  "packages/pharmaconnect_design_system/lib/src/spacing/pharmaconnect_spacing.dart"
  "packages/pharmaconnect_design_system/lib/src/theme/pharmaconnect_theme.dart"
  "packages/pharmaconnect_design_system/lib/pharmaconnect_design_system.dart"
  "packages/pharmaconnect_design_system/test/pharmaconnect_theme_test.dart"
  "packages/pharmaconnect_design_system/lib/src/border/pharmaconnect_borders.dart"
  "packages/pharmaconnect_design_system/lib/src/elevation/pharmaconnect_elevation.dart"
  "packages/pharmaconnect_design_system/lib/src/radius/pharmaconnect_radii.dart"
  "packages/pharmaconnect_design_system/lib/src/status/pharmaconnect_semantic_status.dart"
  "packages/pharmaconnect_design_system/lib/src/typography/pharmaconnect_typography.dart"
  "apps/mobile/lib/app/mobile_app.dart"
  "apps/admin/lib/app/admin_app.dart"
)

run_stage() {
  CURRENT_STAGE="$1"
  shift
  echo
  echo "== ${CURRENT_STAGE} =="
  "$@"
}

if [[ "${MODE}" == "design-system" ]]; then
  if ((${#FORMAT_PATHS[@]} == 0)); then
    FORMAT_PATHS=("${DESIGN_SYSTEM_FILES[@]}")
  fi

  run_stage "Formatting verification" \
    dart format --output=none --set-exit-if-changed "${FORMAT_PATHS[@]}"
  run_stage "Design-system analysis" \
    dart analyze packages/pharmaconnect_design_system
  run_stage "Focused design-system tests" \
    flutter test --no-pub \
      packages/pharmaconnect_design_system/test/pharmaconnect_theme_test.dart
  run_stage "Mobile app entrypoint analysis" \
    flutter analyze --no-pub apps/mobile/lib/app/mobile_app.dart
  run_stage "Admin app entrypoint analysis" \
    flutter analyze --no-pub apps/admin/lib/app/admin_app.dart
elif [[ "${MODE}" == "custom" ]]; then
  if (
    (${#FORMAT_PATHS[@]} == 0) &&
    (${#ANALYZE_PATHS[@]} == 0) &&
    (${#TEST_PATHS[@]} == 0)
  ); then
    echo "VALIDATION FAILED: custom mode requires at least one scoped path"
    exit 1
  fi

  if ((${#FORMAT_PATHS[@]} > 0)); then
    run_stage "Formatting verification" \
      dart format --output=none --set-exit-if-changed "${FORMAT_PATHS[@]}"
  fi

  for path in "${ANALYZE_PATHS[@]}"; do
    run_stage "Analysis: ${path}" flutter analyze --no-pub "${path}"
  done

  for path in "${TEST_PATHS[@]}"; do
    run_stage "Test: ${path}" flutter test --no-pub "${path}"
  done
else
  echo "VALIDATION FAILED: unsupported mode ${MODE}"
  exit 1
fi

if [[ -n "${GITHUB_BASE_REF:-}" ]]; then
  run_stage "Git whitespace validation" \
    git diff --check "origin/${GITHUB_BASE_REF}...HEAD"
else
  run_stage "Git whitespace validation" git diff --check
fi

CURRENT_STAGE="complete"
trap - ERR
echo
echo "VALIDATION PASSED"

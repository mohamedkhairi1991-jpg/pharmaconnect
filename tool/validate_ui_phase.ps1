[CmdletBinding()]
param(
  [ValidateSet('design-system', 'auth-ui', 'doctor-catalog-ui', 'custom')]
  [string]$Mode = 'design-system',
  [string[]]$FormatPath = @(),
  [string[]]$AnalyzePath = @(),
  [string[]]$TestPath = @()
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $repoRoot

$designSystemFiles = @(
  'packages/pharmaconnect_design_system/lib/src/color/pharmaconnect_colors.dart',
  'packages/pharmaconnect_design_system/lib/src/spacing/pharmaconnect_spacing.dart',
  'packages/pharmaconnect_design_system/lib/src/theme/pharmaconnect_theme.dart',
  'packages/pharmaconnect_design_system/lib/pharmaconnect_design_system.dart',
  'packages/pharmaconnect_design_system/test/pharmaconnect_theme_test.dart',
  'packages/pharmaconnect_design_system/lib/src/border/pharmaconnect_borders.dart',
  'packages/pharmaconnect_design_system/lib/src/elevation/pharmaconnect_elevation.dart',
  'packages/pharmaconnect_design_system/lib/src/radius/pharmaconnect_radii.dart',
  'packages/pharmaconnect_design_system/lib/src/status/pharmaconnect_semantic_status.dart',
  'packages/pharmaconnect_design_system/lib/src/typography/pharmaconnect_typography.dart',
  'apps/mobile/lib/app/mobile_app.dart',
  'apps/admin/lib/app/admin_app.dart'
)

$authUiFiles = @(
  'apps/mobile/lib/features/authentication/presentation/auth_support.dart',
  'apps/mobile/lib/features/authentication/presentation/sign_in_page.dart',
  'apps/mobile/lib/features/authentication/presentation/sign_up_page.dart',
  'apps/mobile/lib/features/authentication/presentation/forgot_password_page.dart',
  'apps/mobile/lib/features/authentication/presentation/reset_password_page.dart',
  'apps/mobile/lib/features/authentication/presentation/check_email_page.dart',
  'apps/mobile/lib/features/authentication/presentation/session_pages.dart',
  'apps/admin/lib/features/authentication/presentation/auth_support.dart',
  'apps/admin/lib/features/authentication/presentation/sign_in_page.dart',
  'apps/admin/lib/features/authentication/presentation/forgot_password_page.dart',
  'apps/admin/lib/features/authentication/presentation/reset_password_page.dart',
  'apps/admin/lib/features/authentication/presentation/session_pages.dart',
  'apps/mobile/test/sign_in_page_test.dart',
  'apps/admin/test/sign_in_page_test.dart',
  'packages/pharmaconnect_l10n/lib/src/generated/app_localizations.dart',
  'packages/pharmaconnect_l10n/lib/src/generated/app_localizations_en.dart',
  'packages/pharmaconnect_l10n/lib/src/generated/app_localizations_ar.dart'
)

$doctorCatalogUiFiles = @(
  'apps/mobile/lib/features/catalog/presentation/catalog_entry_pages.dart',
  'apps/mobile/lib/features/catalog/presentation/doctor_catalog_pages.dart',
  'apps/mobile/test/catalog_home_test.dart',
  'apps/mobile/test/catalog_product_detail_test.dart'
)

function Invoke-ValidationStage {
  param(
    [Parameter(Mandatory)]
    [string]$Name,
    [Parameter(Mandatory)]
    [scriptblock]$Action
  )

  Write-Host ''
  Write-Host "== $Name =="
  try {
    & $Action
    if ($LASTEXITCODE -ne 0) {
      throw "Command exited with code $LASTEXITCODE."
    }
  } catch {
    Write-Host "VALIDATION FAILED: $Name"
    exit 1
  }
}

if ($Mode -eq 'design-system') {
  if ($FormatPath.Count -eq 0) {
    $FormatPath = $designSystemFiles
  }

  Invoke-ValidationStage 'Formatting verification' {
    dart format --output=none --set-exit-if-changed @FormatPath
  }
  Invoke-ValidationStage 'Design-system analysis' {
    dart analyze packages/pharmaconnect_design_system
  }
  Invoke-ValidationStage 'Focused design-system tests' {
    flutter test --no-pub packages/pharmaconnect_design_system/test/pharmaconnect_theme_test.dart
  }
  Invoke-ValidationStage 'Mobile app entrypoint analysis' {
    flutter analyze --no-pub apps/mobile/lib/app/mobile_app.dart
  }
  Invoke-ValidationStage 'Admin app entrypoint analysis' {
    flutter analyze --no-pub apps/admin/lib/app/admin_app.dart
  }
} elseif ($Mode -eq 'auth-ui') {
  if ($FormatPath.Count -eq 0) {
    $FormatPath = $authUiFiles
  }

  Invoke-ValidationStage 'Authentication UI formatting verification' {
    dart format --output=none --set-exit-if-changed @FormatPath
  }
  Invoke-ValidationStage 'Mobile authentication analysis' {
    flutter analyze --no-pub apps/mobile/lib/features/authentication
  }
  Invoke-ValidationStage 'Admin authentication analysis' {
    flutter analyze --no-pub apps/admin/lib/features/authentication
  }
  Invoke-ValidationStage 'Localization analysis' {
    dart analyze packages/pharmaconnect_l10n
  }
  Invoke-ValidationStage 'Mobile authentication presentation tests' {
    flutter test --no-pub apps/mobile/test/sign_in_page_test.dart
  }
  Invoke-ValidationStage 'Admin authentication presentation tests' {
    flutter test --no-pub apps/admin/test/sign_in_page_test.dart
  }
  Invoke-ValidationStage 'Mobile authentication routing tests' {
    flutter test --no-pub apps/mobile/test/auth_routing_test.dart
  }
  Invoke-ValidationStage 'Admin authentication routing tests' {
    flutter test --no-pub apps/admin/test/auth_routing_test.dart
  }
} elseif ($Mode -eq 'doctor-catalog-ui') {
  if ($FormatPath.Count -eq 0) {
    $FormatPath = $doctorCatalogUiFiles
  }

  Invoke-ValidationStage 'Doctor catalog UI formatting verification' {
    dart format --output=none --set-exit-if-changed @FormatPath
  }
  Invoke-ValidationStage 'Doctor catalog presentation analysis' {
    flutter analyze --no-pub apps/mobile/lib/features/catalog/presentation
  }
  Invoke-ValidationStage 'Doctor catalog home tests' {
    flutter test --no-pub apps/mobile/test/catalog_home_test.dart
  }
  Invoke-ValidationStage 'Doctor catalog detail tests' {
    flutter test --no-pub apps/mobile/test/catalog_product_detail_test.dart
  }
  Invoke-ValidationStage 'Mobile catalog access routing tests' {
    flutter test --no-pub apps/mobile/test/auth_routing_test.dart
  }
} else {
  if (
    $FormatPath.Count -eq 0 -and
    $AnalyzePath.Count -eq 0 -and
    $TestPath.Count -eq 0
  ) {
    Write-Host 'VALIDATION FAILED: custom mode requires at least one scoped path'
    exit 1
  }

  if ($FormatPath.Count -gt 0) {
    Invoke-ValidationStage 'Formatting verification' {
      dart format --output=none --set-exit-if-changed @FormatPath
    }
  }

  foreach ($path in $AnalyzePath) {
    Invoke-ValidationStage "Analysis: $path" {
      flutter analyze --no-pub $path
    }
  }

  foreach ($path in $TestPath) {
    Invoke-ValidationStage "Test: $path" {
      flutter test --no-pub $path
    }
  }
}

Invoke-ValidationStage 'Git whitespace validation' {
  if ($env:GITHUB_BASE_REF) {
    git diff --check "origin/$($env:GITHUB_BASE_REF)...HEAD"
  } else {
    git diff --check
  }
}

Write-Host ''
Write-Host 'VALIDATION PASSED'

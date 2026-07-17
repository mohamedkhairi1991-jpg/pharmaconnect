[CmdletBinding()]
param(
  [ValidateSet('design-system', 'custom')]
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

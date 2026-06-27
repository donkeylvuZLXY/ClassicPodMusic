$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$required = @(
    "ClassicPodMusic.xcodeproj\project.pbxproj",
    "ClassicPodMusic\ClassicPodMusicApp.swift",
    "ClassicPodMusic\ContentView.swift",
    "ClassicPodMusic\MusicLibraryModel.swift",
    "ClassicPodMusic\Info.plist",
    "ClassicPodMusic\ClassicPodMusic.entitlements",
    ".github\workflows\build-unsigned-ipa.yml",
    "scripts\build_unsigned_ipa.sh",
    "BUILD_IPA_WITHOUT_MAC_CN.md"
)

$missing = @()
foreach ($item in $required) {
    $path = Join-Path $root $item
    if (-not (Test-Path $path)) {
        $missing += $item
    }
}

if ($missing.Count -gt 0) {
    Write-Host "Missing required files:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Upload check passed. Required files are present:" -ForegroundColor Green
$required | ForEach-Object { Write-Host " - $_" }

Write-Host ""
Write-Host "Remember to upload the contents of this folder to GitHub, including the hidden .github folder." -ForegroundColor Yellow

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$webDir = Join-Path $projectRoot "web"
$flutterSrcDir = Join-Path $projectRoot "flutter-web-src"
$outputDir = Join-Path $webDir "public\flutter-app"
$tempDir = Join-Path $projectRoot "temp_flutter_web"

# Clean previous outputs
if (Test-Path $outputDir) {
    Remove-Item -Path $outputDir -Recurse -Force
}
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}

# Remove Svelte build artifacts to prevent recursive copies
$svelteDirsToClean = @("dist", "node_modules", "public")
foreach ($dir in $svelteDirsToClean) {
    $p = Join-Path $webDir $dir
    if (Test-Path $p) { Remove-Item -Path $p -Recurse -Force }
}

# Backup Svelte index.html
$svelteIndex = Join-Path $webDir "index.html"
$backupIndex = Join-Path $webDir "index.html.svelte-backup"
Copy-Item -Path $svelteIndex -Destination $backupIndex -Force

# Copy Flutter web template
$flutterIndex = Join-Path $flutterSrcDir "index.html"
Copy-Item -Path $flutterIndex -Destination $svelteIndex -Force

# Build Flutter web to temp directory (outside web/)
Write-Host "Building Flutter web..." -ForegroundColor Green
Set-Location $projectRoot
flutter build web --output $tempDir --no-tree-shake-icons
$buildOk = $LASTEXITCODE -eq 0

# Restore Svelte index.html
Move-Item -Path $backupIndex -Destination $svelteIndex -Force

if (-not $buildOk) {
    Write-Host "Flutter build failed!" -ForegroundColor Red
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Copy only the Flutter build output into web/public/flutter-app/
Write-Host "Copying build output to $outputDir..." -ForegroundColor Green
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
Get-ChildItem -Path $tempDir | Copy-Item -Destination $outputDir -Recurse -Force

# Clean up temp
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

# Generate sqflite web worker and download correct SQLite WASM
Write-Host "Setting up sqflite web binaries..." -ForegroundColor Green
dart run sqflite_common_ffi_web:setup --dir "$outputDir" --no-sqlite3-wasm 2>$null
Write-Host "Downloading sqlite3.wasm from v3.3.0 release..." -ForegroundColor Green
curl -L -o "$outputDir\sqlite3.wasm" "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.0/sqlite3.wasm" 2>$null

# Also copy sqlite3.wasm to Svelte dist root (sqflite loads it from /sqlite3.wasm)
$svelteDist = Join-Path $webDir "dist"
if (Test-Path $svelteDist) {
    Copy-Item -Path "$outputDir\sqlite3.wasm" -Destination "$svelteDist\sqlite3.wasm" -Force
}

# Copy Svelt biome images for Svelte page background
$bgImgs = @("campoSvelt.png", "florestaSvelt.png", "oceanoSvelt.png", "pantanalSvelt.png")
$assetsCenarios = Join-Path $projectRoot "assets\images\cenarios"
$publicImgs = Join-Path $webDir "public\images"
New-Item -ItemType Directory -Path $publicImgs -Force | Out-Null
foreach ($img in $bgImgs) {
    $src = Join-Path $assetsCenarios $img
    if (Test-Path $src) { Copy-Item -Path $src -Destination $publicImgs -Force }
}

Write-Host "Done! Flutter web app built to: $outputDir" -ForegroundColor Green

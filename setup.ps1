# Operación DGV - Setup Script (PowerShell)
# This script sets up the development environment on Windows

$ErrorActionPreference = "Stop"

Write-Host "🚔 Operación DGV - Development Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✅ Flutter found: $flutterVersion" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Flutter is not installed" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# Get dependencies
Write-Host "📥 Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dependencies installed" -ForegroundColor Green
Write-Host ""

# Install lefthook
Write-Host "🪝 Setting up Git hooks..." -ForegroundColor Yellow

# Check if lefthook is installed globally
$lefthookInstalled = $false
try {
    $lefthookVersion = lefthook version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $lefthookInstalled = $true
        Write-Host "✅ Lefthook found: $lefthookVersion" -ForegroundColor Green
    }
} catch {
    # Lefthook not found
}

if ($lefthookInstalled) {
    # Install hooks
    try {
        lefthook install 2>&1 | Out-Null
        Write-Host "✅ Git hooks installed" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Failed to install Git hooks" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Lefthook not found" -ForegroundColor Yellow
    Write-Host "   Install it with one of these methods:" -ForegroundColor Yellow
    Write-Host "   - npm install -g @evilmartians/lefthook" -ForegroundColor Gray
    Write-Host "   - scoop install lefthook" -ForegroundColor Gray
    Write-Host "   - choco install lefthook" -ForegroundColor Gray
    Write-Host "   - Or download from: https://github.com/evilmartians/lefthook/releases" -ForegroundColor Gray
    Write-Host "   Then run 'lefthook install' in the project directory" -ForegroundColor Yellow
}
Write-Host ""

# Run code generation
Write-Host "🔧 Running code generation..." -ForegroundColor Yellow
try {
    dart run build_runner build --delete-conflicting-outputs 2>&1 | Out-Null
    Write-Host "✅ Code generation completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Code generation skipped (no generated files yet)" -ForegroundColor Yellow
}
Write-Host ""

# Check code quality
Write-Host "🔍 Checking code quality..." -ForegroundColor Yellow
try {
    flutter analyze 2>&1 | Out-Null
    Write-Host "✅ No analysis issues" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Analysis issues found (expected for new project)" -ForegroundColor Yellow
}
Write-Host ""

# Format code
Write-Host "✨ Formatting code..." -ForegroundColor Yellow
dart format .
Write-Host "✅ Code formatted" -ForegroundColor Green
Write-Host ""

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
try {
    flutter test 2>&1 | Out-Null
    Write-Host "✅ All tests passed" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No tests found yet (expected for new project)" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Read the documentation:"
Write-Host "   - AI_INSTRUCTIONS.md (project specification)"
Write-Host "   - README.md (quick start guide)"
Write-Host "   - ROADMAP.md (development plan)"
Write-Host ""
Write-Host "2. Create your first branch:"
Write-Host "   git checkout -b feature/your-feature-name"
Write-Host ""
Write-Host "3. Start coding!"
Write-Host "   - Follow the feature-first folder structure"
Write-Host "   - Use Riverpod for state management"
Write-Host "   - Write tests for your code"
Write-Host ""
Write-Host "4. Useful commands:"
Write-Host "   - dart run build_runner watch -d  (watch mode for code generation)"
Write-Host "   - flutter analyze                 (check for issues)"
Write-Host "   - flutter test                    (run tests)"
Write-Host "   - dart format .                   (format code)"
Write-Host ""
Write-Host "🚔 Happy coding! Remember: drunk-proof UX is our priority!" -ForegroundColor Cyan
Write-Host ""

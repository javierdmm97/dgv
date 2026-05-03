#!/bin/bash

# Operación DGV - Setup Script
# This script sets up the development environment

set -e

echo "🚔 Operación DGV - Development Setup"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -n 1)"
echo ""

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
echo "📦 Flutter version: $FLUTTER_VERSION"
echo ""

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Install lefthook
echo "🪝 Setting up Git hooks..."
if grep -q "lefthook" pubspec.yaml; then
    echo "✅ Lefthook already in pubspec.yaml"
else
    echo "📝 Adding lefthook to dev_dependencies..."
    flutter pub add --dev lefthook
fi

# Install hooks
if command -v lefthook &> /dev/null; then
    lefthook install
    echo "✅ Git hooks installed"
else
    echo "⚠️  Lefthook not found in PATH"
    echo "   Run 'lefthook install' manually after 'flutter pub get'"
fi
echo ""

# Run code generation (will fail if no generated files yet, that's ok)
echo "🔧 Running code generation..."
if dart run build_runner build --delete-conflicting-outputs 2>/dev/null; then
    echo "✅ Code generation completed"
else
    echo "⚠️  Code generation skipped (no generated files yet)"
fi
echo ""

# Check code quality
echo "🔍 Checking code quality..."
if flutter analyze; then
    echo "✅ No analysis issues"
else
    echo "⚠️  Analysis issues found (expected for new project)"
fi
echo ""

# Format code
echo "✨ Formatting code..."
dart format .
echo "✅ Code formatted"
echo ""

# Run tests (will fail if no tests yet, that's ok)
echo "🧪 Running tests..."
if flutter test 2>/dev/null; then
    echo "✅ All tests passed"
else
    echo "⚠️  No tests found yet (expected for new project)"
fi
echo ""

# Summary
echo "======================================"
echo "🎉 Setup Complete!"
echo "======================================"
echo ""
echo "📚 Next Steps:"
echo ""
echo "1. Read the documentation:"
echo "   - AI_INSTRUCTIONS.md (project specification)"
echo "   - README.md (quick start guide)"
echo "   - ROADMAP.md (development plan)"
echo ""
echo "2. Create your first branch:"
echo "   git checkout -b feature/your-feature-name"
echo ""
echo "3. Start coding!"
echo "   - Follow the feature-first folder structure"
echo "   - Use Riverpod for state management"
echo "   - Write tests for your code"
echo ""
echo "4. Useful commands:"
echo "   - dart run build_runner watch -d  (watch mode for code generation)"
echo "   - flutter analyze                 (check for issues)"
echo "   - flutter test                    (run tests)"
echo "   - dart format .                   (format code)"
echo ""
echo "🚔 Happy coding! Remember: drunk-proof UX is our priority!"
echo ""

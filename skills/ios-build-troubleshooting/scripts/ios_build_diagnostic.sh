#!/bin/bash
# =============================================================================
# iOS Build Diagnostic Script
# Quickly identifies common iOS build issues in Flutter projects
# =============================================================================

set -e

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          iOS Build Diagnostic Tool v1.0                            ║"
echo "║          For Flutter Projects                                      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: Not in a Flutter project directory${NC}"
    exit 1
fi

echo "=== 1. Flutter/Dart Versions ==="
flutter --version
echo ""

echo "=== 2. Checking pubspec.yaml for Known Problematic Packages ==="
echo "Looking for packages that often cause Dart SDK conflicts..."

PROBLEM_PACKAGES=(
    "google_mobile_ads"
    "google_fonts"
    "flutter_local_notifications"
    "app_links"
    "workmanager"
    "home_widget"
    "flutter_svg"
    "image_picker"
    "awesome_notifications"
    "flutter_lints"
)

for pkg in "${PROBLEM_PACKAGES[@]}"; do
    result=$(grep -E "^\s+$pkg:" pubspec.yaml 2>/dev/null || echo "")
    if [ -n "$result" ]; then
        echo -e "${YELLOW}Found: $result${NC}"
    fi
done
echo ""

echo "=== 3. Checking for Files That Should NOT Be in Git ==="

# Check Generated.xcconfig
if git ls-files ios/Flutter/Generated.xcconfig --error-unmatch 2>/dev/null; then
    echo -e "${RED}❌ Generated.xcconfig is tracked in git - PROBLEM!${NC}"
    echo "   Fix: git rm --cached ios/Flutter/Generated.xcconfig"
else
    echo -e "${GREEN}✓ Generated.xcconfig not in git${NC}"
fi

# Check Podfile.lock
if git ls-files ios/Podfile.lock --error-unmatch 2>/dev/null; then
    echo -e "${YELLOW}⚠ Podfile.lock is tracked in git${NC}"
    echo "   Consider: git rm --cached ios/Podfile.lock (for CI/CD)"
else
    echo -e "${GREEN}✓ Podfile.lock not in git${NC}"
fi
echo ""

echo "=== 4. iOS Deployment Target ==="
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    targets=$(grep IPHONEOS_DEPLOYMENT_TARGET ios/Runner.xcodeproj/project.pbxproj | sort | uniq)
    echo "$targets"
else
    echo -e "${RED}project.pbxproj not found${NC}"
fi
echo ""

echo "=== 5. Podfile Configuration ==="
if [ -f "ios/Podfile" ]; then
    platform=$(grep "^platform" ios/Podfile | head -1)
    echo "Platform: $platform"
else
    echo -e "${RED}Podfile not found${NC}"
fi
echo ""

echo "=== 6. CI Script Permissions ==="
if [ -d "ios/ci_scripts" ]; then
    echo "CI Scripts found:"
    ls -la ios/ci_scripts/*.sh 2>/dev/null || echo "No .sh files"
    
    # Check if executable
    for script in ios/ci_scripts/*.sh; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                echo -e "${GREEN}✓ $script is executable${NC}"
            else
                echo -e "${RED}❌ $script is NOT executable${NC}"
                echo "   Fix: git update-index --chmod=+x $script"
            fi
        fi
    done
else
    echo "No ios/ci_scripts directory"
fi
echo ""

echo "=== 7. xcconfig Optional Includes Check ==="
for config in ios/Flutter/Debug.xcconfig ios/Flutter/Release.xcconfig; do
    if [ -f "$config" ]; then
        if grep -q '#include?' "$config"; then
            echo -e "${GREEN}✓ $config uses optional #include?${NC}"
        elif grep -q '#include "Pods' "$config"; then
            echo -e "${YELLOW}⚠ $config uses required #include (may fail before pod install)${NC}"
        fi
    fi
done
echo ""

echo "=== 8. AppIntents Check ==="
if find ios -name "*.swift" -exec grep -l "AppIntent\|AppShortcut" {} \; 2>/dev/null | head -1; then
    echo "AppIntents found. Checking for common issues..."
    
    # Check for applicationName in phrases
    swift_files=$(find ios -name "*.swift" -exec grep -l "phrases:" {} \; 2>/dev/null)
    for file in $swift_files; do
        phrases_without_app=$(grep -n "\".*\"" "$file" | grep -v "applicationName" | grep -v "//" | head -3)
        if [ -n "$phrases_without_app" ]; then
            echo -e "${YELLOW}⚠ $file may have phrases without applicationName${NC}"
        fi
    done
else
    echo "No AppIntents found"
fi
echo ""

echo "=== 9. Bundle ID Check ==="
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    bundle_ids=$(grep -o 'PRODUCT_BUNDLE_IDENTIFIER = [^;]*' ios/Runner.xcodeproj/project.pbxproj | sort | uniq)
    echo "$bundle_ids"
fi
echo ""

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                    Diagnostic Complete                             ║"
echo "╚════════════════════════════════════════════════════════════════════╝"

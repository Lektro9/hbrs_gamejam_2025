#!/bin/bash
set -e

# Load environment variables
set -a
source .env
set +a

GIT_VERSION=$(git rev-parse --short HEAD)

echo "🔖 Version: $GIT_VERSION"

# Clean and prepare build directory
rm -rf "$EXPORT_DIR"
mkdir -p "$EXPORT_DIR"

# Write version file into the project so Godot exports it
echo "$GIT_VERSION" > "$PROJECT_PATH/version.txt"

echo "🚀 Exporting Godot project to Web..."
"$GODOT_EXECUTABLE" --headless --path "$PROJECT_PATH" --verbose --export-release "$EXPORT_PRESET" "../$EXPORT_DIR/index.html"
echo "✅ Export done. Files in $EXPORT_DIR"

# Upload to itch.io with version tag
echo "📦 Uploading to itch.io..."
butler push "$EXPORT_DIR" "$ITCH_USER/$ITCH_GAME:web" --userversion "$GIT_VERSION"

echo "🎉 Upload complete!"

# Cleanup: remove the version file
rm -f "$PROJECT_PATH/version.txt"

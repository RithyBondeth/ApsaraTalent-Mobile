#!/bin/sh
set -eu

config="$PROJECT_DIR/Runner/GoogleService-Info.plist"
case "${CONFIGURATION}:${PLATFORM_NAME}" in
  Release:iphoneos|Profile:iphoneos)
    case "$PRODUCT_BUNDLE_IDENTIFIER" in
      ""|com.example.*)
        echo "error: Set the registered APSARA_IOS_BUNDLE_ID in Flutter/ReleaseIdentity.xcconfig."
        exit 1 ;;
    esac
    if [ -z "${DEVELOPMENT_TEAM:-}" ] || [ ! -f "$config" ]; then
      echo "error: Configure the Apple team and Runner/GoogleService-Info.plist before releasing."
      exit 1
    fi ;;
esac

destination="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/GoogleService-Info.plist"
if [ -f "$config" ]; then
  bundle=$(/usr/libexec/PlistBuddy -c 'Print :BUNDLE_ID' "$config")
  if [ "$bundle" != "$PRODUCT_BUNDLE_IDENTIFIER" ]; then
    echo "error: Firebase BUNDLE_ID does not match this app's bundle identifier."
    exit 1
  fi
  cp "$config" "$destination"
else
  # Do not retain a previous environment's configuration in an incremental build.
  rm -f "$destination"
fi

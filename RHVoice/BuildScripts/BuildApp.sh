#!/bin/bash
BUILD_NUMBER=$1
PLATFORM="${2}" # Can be empty

rm -fr BuildOutput

echo "BUILD_NUMBER=${BUILD_NUMBER}"
echo "PLATFORM=${PLATFORM}"

export BUILD_NUMBER

build_platform() {
  local PLATFORM="$1"

  echo "=== Building for $PLATFORM ==="

  xcodebuild clean archive \
    -configuration "Release" \
    -target RHVoiceApp \
    -scheme RHVoiceApp \
    -allowProvisioningUpdates \
    -archivePath "BuildOutput/RHVoiceApp${PLATFORM}.xcarchive" \
    -destination "generic/platform=${PLATFORM}"

  xcodebuild -exportArchive \
    -allowProvisioningUpdates \
    -archivePath "BuildOutput/RHVoiceApp${PLATFORM}.xcarchive" \
    -exportPath "BuildOutput/binary/$PLATFORM" \
    -exportOptionsPlist "RHVoice/BuildScripts/Configs/Regular/${PLATFORM}ExportOptions.plist"

  zip --symlinks -vr "BuildOutput/RHVoiceApp${PLATFORM}.zip" "BuildOutput/RHVoiceApp${PLATFORM}.xcarchive"
}

if [ -z "$PLATFORM" ]; then
  build_platform "iOS"
  build_platform "macOS"
else
  build_platform "$PLATFORM"
fi

open BuildOutput

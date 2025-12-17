#  Copyright (C) 2022  Non-Routine LLC (contact@nonroutine.com)

#!/bin/sh -x -e

xcodebuild clean analyze \
         -configuration DebugRegular \
         -scheme RHVoiceApp \
         -sdk iphonesimulator \
         -destination "platform=iOS Simulator,name=iPad mini (6th generation)" \
         CLANG_ANALYZER_OUTPUT=plist-html \
         CLANG_ANALYZER_OUTPUT_DIR="src/apple/iOS/App/RHVoice/BuildOutput/clang" \

#  Copyright (C) 2022  Non-Routine LLC (contact@nonroutine.com)

#!/bin/sh -x -e

if which infer >/dev/null; then
    infer --version
    INFERCONFIG="$(dirname "$0")/inferconfig.json"
    export INFERCONFIG
    infer run --project-root $1 -- xcodebuild clean build \
                                  -configuration DebugRegular \
                                  -scheme RHVoiceApp \
                                  -sdk iphonesimulator \
                                  -destination "platform=iOS Simulator,name=iPad mini (6th generation)"
    unset INFERCONFIG
else
   echo "warning: infer is not installed"
fi

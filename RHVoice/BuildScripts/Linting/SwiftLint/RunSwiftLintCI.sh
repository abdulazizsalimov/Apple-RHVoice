#  Copyright (C) 2022  Non-Routine LLC (contact@nonroutine.com)

#!/bin/sh -x -e

if which swiftlint >/dev/null; then
    swiftlint --version
    REPORT_TYPE="checkstyle" swiftlint --config $(dirname "$0")/swiftlint.yml > $1
else
   # If SwiftLint was installed via brew it is needed to make symbolic lynk from SwiftLint in brew path to system path:
   # You may use next command to do this:
   # sudo ln -s /opt/homebrew/bin/swiftlint /usr/local/bin/
   echo "warning: SwiftLint is not installed"
fi

#  Copyright (C) 2022  Non-Routine LLC (contact@nonroutine.com)

#!/bin/sh -x -e

if [ ! -z "$CI_BUILD" ]; then
   echo "No automatic fixing on Jenkins! Skipping"
   exit 0
fi


if which swiftlint >/dev/null; then
    swiftlint --version
    swiftlint $1 --config $(dirname "$0")/swiftlint.yml
else
   # If SwiftLint was installed via brew it is needed to make symbolic lynk from SwiftLint in brew path to system path:
   # You may use next command to do this:
   # sudo ln -s /opt/homebrew/bin/swiftlint /usr/local/bin/
   echo "warning: SwiftLint is not installed"
fi

#  Copyright (C) 2025  Non-Routine LLC (contact@nonroutine.com)

#!/bin/sh -x -e

if which mobsfscan >/dev/null; then
    mobsfscan --version
    CONFIG="$(dirname "$0")/mobsf.yml"
    mobsfscan --sarif -o $2 --config $CONFIG $1
else
   echo "warning: infer is not installed"
fi

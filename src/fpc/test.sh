#!/bin/bash
# Plays the 350 point walkthrough with the Free Pascal version (random seed
# 1234) and compares the transcript with tests/expected.txt.
# -> build/test/fpc.*
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/fpc"
mkdir -p "$BUILD/test"
# A copy, so the game starts with a fresh ADVWIZ.DTA (no saved games). The
# game reads from a redirected stdin, so the input lines are inserted into
# the transcript for comparison.
TMP=$(mktemp -d)
cp "$BUILD"/fpc/* "$TMP/"
(cd "$TMP" && ./advent $SEED < "$WALK" |
   "$PYTHON" "$ROOT/tools/echo-input.py" "$WALK" > "$BUILD/test/fpc.txt")
rm -rf "$TMP"
check fpc

#!/bin/bash
# Plays the 350 point walkthrough with the CP/M version under tnylpo (random
# seed 1234) and compares the transcript with tests/expected.txt.
# -> build/test/cpm.*
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/cpm"
mkdir -p "$BUILD/test"
# A copy, so the game starts with a fresh ADVWIZ.DTA (no saved games).
TMP=$(mktemp -d)
cp "$BUILD"/cpm/* "$TMP/"
(cd "$TMP" && tnylpo -b advent $SEED < "$WALK" > "$BUILD/test/cpm.txt")
rm -rf "$TMP"
check cpm

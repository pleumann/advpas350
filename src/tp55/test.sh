#!/bin/bash
# Plays the 350 point walkthrough with the Turbo Pascal 5.5 version under
# emu2 (random seed 1234) and compares the transcript with
# tests/expected.txt.  -> build/test/tp55.*
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/tp55"
mkdir -p "$BUILD/test"
# A copy, so the game starts with a fresh ADVWIZ.DTA (no saved games). The
# game reads from a redirected stdin, so the input lines are inserted into
# the transcript for comparison.
TMP=$(mktemp -d)
cp "$BUILD"/tp55/* "$TMP/"
crlf "$WALK" "$TMP/walk.txt"
(cd "$TMP" && "$EMU2" advent.exe $SEED < walk.txt |
   "$PYTHON" "$ROOT/tools/echo-input.py" "$WALK" > "$BUILD/test/tp55.txt")
rm -rf "$TMP"
check tp55

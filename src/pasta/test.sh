#!/bin/bash
# Plays the 350 point walkthrough with the Agon version in the Fab Agon CLI
# emulator (random seed 1234) and compares the transcript with
# tests/expected.txt.  -> build/test/agon.*
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/agon"
mkdir -p "$BUILD/test"
"$ROOT/tools/run-agon.sh" "$BUILD/agon/advent.bin" "$WALK" $SEED > "$BUILD/test/agon.txt"
check agon

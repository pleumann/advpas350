#!/bin/bash
# Runs the Agon version in the Fab Agon CLI emulator, with build/agon as the
# SD card, so saved games are kept there. Arguments are passed to the game,
# e.g. a random seed. Leave the emulator with Ctrl-C.
#
# usage: src/pasta/run.sh [<seed>]
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/agon"
{ echo "advent $*"; cat; } |
  "$AGON_CLI" --mos "$FAB/firmware/mos_platform.bin" --sdcard "$BUILD/agon" -u

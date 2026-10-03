#!/bin/bash
# Runs the Turbo Pascal 5.5 version under emu2 in build/tp55, so saved games
# are kept there. Arguments are passed to the game, e.g. a random seed.
#
# usage: src/tp55/run.sh [<seed>]
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/tp55"
cd "$BUILD/tp55" && exec "$EMU2" advent.exe "$@"

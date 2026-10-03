#!/bin/bash
# Runs the CP/M version under tnylpo in build/cpm, so saved games are kept
# there. Arguments are passed to the game, e.g. a random seed.
#
# usage: src/tp3/run.sh [<seed>]
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/cpm"
cd "$BUILD/cpm" && exec tnylpo advent "$@"

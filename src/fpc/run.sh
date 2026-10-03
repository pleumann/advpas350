#!/bin/bash
# Runs the Free Pascal version in build/fpc, so saved games are kept there.
# Arguments are passed to the game, e.g. a random seed.
#
# usage: src/fpc/run.sh [<seed>]
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
need_build "$BUILD/fpc"
cd "$BUILD/fpc" && exec ./advent "$@"

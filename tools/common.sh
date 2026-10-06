# Common settings and functions for the build, run and test scripts in the
# source trees (src/*/build.sh etc.) and tools/build.sh. Meant to be sourced.
#
# All tool locations can be overridden by environment variables:
#
#   PASTA     the pasta80 binary
#   TP3DIR    CP/M Turbo Pascal 3 (turbo.com, turbo.msg, turbo.ovr)
#   TP55DIR   Turbo Pascal 5.5 (TPC.EXE, TURBO.TPL)
#   EMU2      the emu2 DOS emulator
#   FAB       the Fab Agon emulator source tree (for firmware/mos_platform.bin)
#   AGON_CLI  its CLI emulator binary
#   PYTHON    Python 3

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BUILD="$ROOT/build"
DAT="$ROOT/original/files/adventure.dat"
WALK="$ROOT/tests/walkthrough.txt"
SEED=1234

PASTA=${PASTA:-/Users/joerg/Projekte/pasta80/pasta80}
TP55DIR=${TP55DIR:-$HOME/Downloads/tp55/Disk1}
EMU2=${EMU2:-$HOME/Projekte/emu2-cpm86/emu2}
FAB=${FAB:-/Users/joerg/Projekte/fab-agon-emulator}
# The stock CLI emulator feeds at most one input line per second.  Point
# AGON_CLI to a build with a shorter delay to speed things up.
AGON_CLI=${AGON_CLI:-$FAB/target/release/agon-cli-emulator}
# Python 3, which is just "python" on some systems (e.g. Windows).
PYTHON=${PYTHON:-$(command -v python3 || command -v python)}

# Compiles quietly with PASTA/80, showing the output only if something went
# wrong.
compile() {
  local log
  if ! log=$("$PASTA" "$@" 2>&1); then
    echo "$log"
    exit 1
  fi
  echo "$log" | grep -oE '(Program|Heap|Stack|Overlay) +[0-9]* *:.*' || true
}

# Copies a text file, converting its line endings to CRLF (needed by Turbo
# Pascal 3 and 5.5).
crlf() {
  perl -pe 's/\r?\n/\r\n/' "$1" > "$2"
}

# Fails unless the given build directory exists.
need_build() {
  [ -d "$1" ] || { echo "$1 not found, run build.sh first"; exit 1; }
}

# Compares the transcript build/test/<name>.txt with the expected one (game
# output only). Returns 1 if they differ.
check() {
  "$ROOT/tools/normalize.sh" "$BUILD/test/$1.txt" > "$BUILD/test/$1.norm"
  if diff -u "$ROOT/tests/expected.txt" "$BUILD/test/$1.norm" > "$BUILD/test/$1.diff"; then
    echo "$1: transcript matches, $(grep 'You scored' "$BUILD/test/$1.norm")"
  else
    echo "$1: transcript differs, see build/test/$1.diff"
    return 1
  fi
}

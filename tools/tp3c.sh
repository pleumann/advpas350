#!/bin/bash
# Compiles a program with CP/M Turbo Pascal 3 under tnylpo by remote-controlling
# the TURBO.COM menu. Adapted from AdvPas500/tools/tp3c.sh.
#
# usage: tools/tp3c.sh <dir> <main> [<builddir>]   (main without .pas)
#
# The sources are copied into the build directory (default <dir>/build-tp3)
# with CRLF line endings and a ^Z appended, which TP3 needs. The .COM file ends
# up there, too. Prints the compiler summary or the error message with line
# number and source line.

set -e
TP3DIR=${TP3DIR:-$HOME/Retro/tp3cpm}
SRC=$(cd "$1" && pwd)
MAIN=$(echo "$2" | tr 'A-Z' 'a-z')
BUILD=${3:-$SRC/build-tp3}

rm -rf "$BUILD"
mkdir -p "$BUILD"
cp "$TP3DIR/turbo.com" "$TP3DIR/turbo.msg" "$TP3DIR/turbo.ovr" "$BUILD/"
for f in "$SRC"/*.pas; do
  b=$(basename "$f" | tr 'A-Z' 'a-z')
  perl -pe 's/\r?\n/\r\n/' "$f" > "$BUILD/$b"
  printf '\032' >> "$BUILD/$b"
done

cd "$BUILD"
# Y = load error messages, O C Q = compile to .COM file, M = main file,
# C = compile; on error: ESC, ^K^D leaves the editor; Q = quit.
( printf 'Y'; sleep 1
  printf 'O'; sleep 0.3; printf 'C'; sleep 0.3; printf 'Q'; sleep 0.3
  printf 'M%s\r' "$MAIN"; sleep 0.5
  printf 'C'; sleep "${TP3WAIT:-20}"
  printf '\033'; sleep 0.5; printf '\013\004'; sleep 0.5
  printf 'Q'; sleep 1 ) | tnylpo -b turbo > tp3.log 2>&1 || true

if grep -a -q 'Error [0-9]*:' tp3.log; then
  grep -a -o 'Error [0-9]*: [^.]*\.' tp3.log | head -1
  # Status line: line number printed at row 0, column 11 (ESC Y space +).
  LINE=$(perl -ne 'print "$1\n" if /\eY \+(\d+)/' tp3.log | head -1)
  FILE=$(perl -ne 'print "$1\n" if /\eY J([A-Z]:[A-Z0-9.]+)/' tp3.log | head -1)
  echo "File: $FILE  Line: $LINE"
  perl -ne 'print "> $1\n" if /\eE\eY.(.*?)\e/' tp3.log | head -1
  exit 1
else
  tr -d '\r' < tp3.log | grep -a -A8 'Compiling' | grep -a -v '^$'
  [ -e "$MAIN.com" ] || { echo "no .COM produced"; exit 1; }
fi

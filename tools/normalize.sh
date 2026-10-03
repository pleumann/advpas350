#!/bin/bash
# Reduces a game transcript to the game's own output, so transcripts from
# different emulators and compilers can be compared: everything before "Be
# patient" (emulator banners, MOS commands) is dropped, as are carriage
# returns, blank lines, trailing blanks and a final MOS prompt.
#
# usage: tools/normalize.sh <transcript>
sed -n '/Be patient/,$p' "$1" | tr -d '\r' | sed 's/[[:space:]]*$//' |
  grep -v '^$' | grep -v '^/ \*$'

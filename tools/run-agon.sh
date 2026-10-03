#!/bin/bash
# Runs the Agon build of the game in the Fab Agon CLI emulator, feeding the
# given input file as keyboard input (one line per prompt, see play.py), and
# prints the transcript.
#
# usage: tools/run-agon.sh <bin-file> <input-file> [<arguments>...]
#
# The .DTA files are taken from the directory of the .bin file.
# A fresh copy of ADVWIZ.DTA is used for every run, so there are no saved
# games around unless the input creates them.

. "$(dirname "$0")/common.sh"
BIN=$1
INPUT=$2
shift 2
ARGS="$*"
NAME=$(basename "$BIN" .bin)
SD=$(mktemp -d)

cp "$BIN" "$SD/"
cp "${BIN%.bin}.ovr" "$SD/"
cp "$(dirname "$BIN")"/*.dta "$SD/"

INPUT_ALL=$(mktemp)
{ echo "$NAME $ARGS"; cat "$INPUT"; } > "$INPUT_ALL"

python3 "$ROOT/tools/play.py" "$INPUT_ALL" -- \
  "$AGON_CLI" \
    --mos "$FAB/firmware/mos_platform.bin" --sdcard "$SD" -u

rm -f "$INPUT_ALL"
rm -rf "$SD"

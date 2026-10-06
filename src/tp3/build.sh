#!/bin/bash
# Builds the Turbo Pascal 3 version for CP/M.  -> build/cpm/
#
# Compiles ADVFLS and the game with TP3 under tnylpo (see tools/tp3c.sh),
# creates the data files (*.DTA) with ADVFLS and checks them against the
# original 1983 RSX files.
#
# Needs tnylpo and CP/M Turbo Pascal 3 (TP3DIR).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/cpm"
rm -rf "$OUT"
mkdir -p "$OUT"
TMP=$(mktemp -d)

echo "=== CP/M (Turbo Pascal 3): data files"
"$ROOT/tools/tp3c.sh" "$HERE" advfls "$TMP/fls" > /dev/null
# TP3 needs CRLF line endings in text files.
crlf "$DAT" "$TMP/fls/adventur.dat"
(cd "$TMP/fls" && tnylpo advfls > advfls.log)
"$PYTHON" "$ROOT/tools/verify-data.py" "$ROOT/original/files" "$TMP/fls"
cp "$TMP"/fls/*.dta "$OUT/"

echo "=== CP/M (Turbo Pascal 3): game"
# End address $E800, so the game also runs on CP/M systems with a smaller TPA
# (it only needs memory up to $E800). It needs about 8.7K for heap and
# stack, which would allow $E500, so this leaves some reserve.
TP3END=E800 "$ROOT/tools/tp3c.sh" "$HERE" advent "$TMP/game" | grep -E 'Code|Free|Data'
mv "$TMP/game/advent.com" "$OUT/"
rm -rf "$TMP"

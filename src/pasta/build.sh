#!/bin/bash
# Builds the PASTA/80 versions for the Agon and the Spectrum Next (both with
# overlays).  -> build/agon/, build/next/advent.run/
#
# The data files (*.DTA) are created by ADVFLS, compiled for CP/M and run
# under tnylpo, and checked against the original 1983 RSX files.
#
# Needs pasta80 (PASTA) and tnylpo.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/agon"
NEXT="$BUILD/next"
rm -rf "$OUT" "$NEXT"
mkdir -p "$OUT" "$NEXT"

echo "=== Agon (PASTA/80): data files"
TMP=$(mktemp -d)
compile --cpm --release "$HERE/advfls.pas"
mv "$HERE/advfls.com" "$TMP/"
cp "$DAT" "$TMP/adventur.dat"
(cd "$TMP" && tnylpo advfls > advfls.log)
"$PYTHON" "$ROOT/tools/verify-data.py" "$ROOT/original/files" "$TMP"
cp "$TMP"/*.dta "$OUT/"
rm -rf "$TMP"

echo "=== Agon (PASTA/80): game"
compile --agon --ovr --release "$HERE/advent.pas"
mv "$HERE/advent.bin" "$HERE/advent.ovr" "$OUT/"

# The Next's resident part only fits if the program starts at $6000. The
# .run directory gets the data files, since the game opens them without a
# path.
echo "=== Spectrum Next (PASTA/80): game"
compile --zxnext --ovr --run --start '$6000' --release "$HERE/advent.pas"
mv "$HERE/advent.run" "$NEXT/"
cp "$OUT"/*.dta "$NEXT/advent.run/"

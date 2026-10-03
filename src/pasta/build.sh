#!/bin/bash
# Builds the PASTA/80 version for the Agon (with overlays).  -> build/agon/
#
# The data files (*.DTA) are created by ADVFLS, compiled for CP/M and run
# under tnylpo, and checked against the original 1983 RSX files.
#
# Needs pasta80 (PASTA) and tnylpo.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/agon"
rm -rf "$OUT"
mkdir -p "$OUT"

echo "=== Agon (PASTA/80): data files"
TMP=$(mktemp -d)
compile --cpm --release "$HERE/advfls.pas"
mv "$HERE/advfls.com" "$TMP/"
cp "$DAT" "$TMP/adventur.dat"
(cd "$TMP" && tnylpo advfls > advfls.log)
python3 "$ROOT/tools/verify-data.py" "$ROOT/original/files" "$TMP"
cp "$TMP"/*.dta "$OUT/"
rm -rf "$TMP"

echo "=== Agon (PASTA/80): game"
compile --agon --ovr --release "$HERE/advent.pas"
mv "$HERE/advent.bin" "$HERE/advent.ovr" "$OUT/"

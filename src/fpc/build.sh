#!/bin/bash
# Builds the Free Pascal version for the host.  -> build/fpc/
#
# Compiles ADVFLS and the game with fpc and creates the data files
# (*.DTA) with ADVFLS. Skipped if fpc isn't found.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/fpc"
rm -rf "$OUT"
command -v fpc > /dev/null || { echo "=== Host (Free Pascal): fpc not found, skipped"; exit 0; }

echo "=== Host (Free Pascal)"
mkdir -p "$OUT/units"
for p in advfls advent; do
  fpc -FE"$OUT" -FU"$OUT/units" "$HERE/$p.pas" > "$OUT/$p.log" 2>&1 ||
    { cat "$OUT/$p.log"; exit 1; }
done
cd "$OUT"
cp "$DAT" ADVENTUR.DAT
./advfls > /dev/null
rm -rf units *.log ADVENTUR.DAT advfls

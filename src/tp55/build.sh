#!/bin/bash
# Builds the Turbo Pascal 5.5 version for DOS.  -> build/tp55/
#
# Compiles ADVFLS and the game with TPC under emu2 and creates the data files
# (*.DTA) with ADVFLS. Skipped if TPC.EXE (TP55DIR) or emu2 (EMU2) isn't
# found.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/tp55"
rm -rf "$OUT"
if [ ! -e "$TP55DIR/TPC.EXE" ] || [ ! -x "$EMU2" ]; then
  echo "=== DOS (Turbo Pascal 5.5): TPC.EXE or emu2 not found, skipped"
  exit 0
fi

echo "=== DOS (Turbo Pascal 5.5)"
mkdir -p "$OUT"
cd "$OUT"
cp "$HERE"/*.pas "$TP55DIR/TPC.EXE" "$TP55DIR/TURBO.TPL" .
"$EMU2" TPC.EXE advfls.pas < /dev/null > /dev/null
"$EMU2" TPC.EXE advent.pas < /dev/null | tr '\r' '\n' | grep 'bytes code'
# TP 5.5 needs CRLF line endings in text files.
crlf "$DAT" ADVENTUR.DAT
"$EMU2" advfls.exe < /dev/null > /dev/null
rm -f *.pas TPC.EXE TURBO.TPL ADVENTUR.DAT advfls.exe

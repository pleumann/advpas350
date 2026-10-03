#!/bin/bash
# Packs the Agon, CP/M and DOS builds into zip files for a release, each with
# the game, its data files and a short README.txt.  -> build/release/
#
# usage: tools/package.sh   (after tools/build.sh, ideally with --test)

set -e
. "$(dirname "$0")/common.sh"
OUT="$BUILD/release"
rm -rf "$OUT"
mkdir -p "$OUT"

URL=https://github.com/pleumann/advpas350

# package <build dir> <name> <system> <files> <how to run>
package() {
  local dir="$OUT/advpas350-$2"
  [ -d "$BUILD/$1" ] || { echo "build/$1 not found, run tools/build.sh first"; exit 1; }
  mkdir -p "$dir"
  cp $4 "$dir/"
  cat > "$dir/README.txt" <<EOF
Colossal Cave Adventure (350 points) for $3

Barry C. Breen's "Adventures in Pascal" (OMSI Pascal, RSX-11M, 1980-1983),
ported to $3. Sources, documentation and other platforms:

  $URL

$5

An optional number on the command line is used as the random seed, so the
same number gives the same game (e.g. "advent 1234"). The game keeps up to
three suspended games in ADVWIZ.DTA.
EOF
  perl -pi -e 's/\r?\n/\r\n/' "$dir/README.txt"
  (cd "$OUT" && zip -qr "advpas350-$2.zip" "advpas350-$2")
  rm -rf "$dir"
  echo "build/release/advpas350-$2.zip"
}

package agon agon "the Agon Light" \
  "$BUILD/agon/advent.bin $BUILD/agon/advent.ovr $BUILD/agon/*.dta" \
"Copy all files into one directory on the SD card, change into it and type
\"advent\". The game opens its data files without a path, so it must be
started from that directory. Needs MOS 3."

package cpm cpm "CP/M (Z80)" \
  "$BUILD/cpm/advent.com $BUILD/cpm/*.dta" \
"Copy all files to a CP/M disk and type \"advent\". Needs a Z80 and a TPA up
to at least \$E800 (Turbo Pascal 3 end address)."

package tp55 dos "MS-DOS" \
  "$BUILD/tp55/advent.exe $BUILD/tp55/*.dta" \
"Copy all files into one directory, change into it and type \"advent\"."

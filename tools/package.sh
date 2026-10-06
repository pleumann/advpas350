#!/bin/bash
# Packs builds into zip files for a release, each with the game, its data
# files and a short README.txt.  -> build/release/
#
# usage: tools/package.sh [<target>...]   (after the builds, ideally tested)
#
# Targets are agon, cpm, dos and fpc; the default is all of them. The name of
# the fpc zip depends on the system it was built on: advpas350-macos.zip
# (universal binary) or advpas350-macos-arm64.zip, advpas350-linux-x86_64.zip,
# advpas350-linux-arm64.zip or advpas350-windows.zip.

set -e
. "$(dirname "$0")/common.sh"
OUT="$BUILD/release"
mkdir -p "$OUT"

URL=https://github.com/pleumann/advpas350

# Zips a directory inside $OUT (zip isn't available everywhere, e.g. not in
# Git Bash on Windows, so Python's zipfile is the fallback).
makezip() {
  rm -f "$OUT/$1.zip"
  if command -v zip > /dev/null; then
    (cd "$OUT" && zip -qr "$1.zip" "$1")
  else
    (cd "$OUT" && "$PYTHON" -m zipfile -c "$1.zip" "$1")
  fi
}

# package <build dir> <name> <system> <files> <how to run>
package() {
  local dir="$OUT/advpas350-$2"
  [ -d "$BUILD/$1" ] || { echo "build/$1 not found, run its build.sh first"; exit 1; }
  rm -rf "$dir"
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
  makezip "advpas350-$2"
  rm -rf "$dir"
  echo "build/release/advpas350-$2.zip"
}

package_fpc() {
  local arch name system how
  arch=$(uname -m)
  [ "$arch" = aarch64 ] && arch=arm64
  case $(uname -s) in
    Darwin)
      if [ "$(lipo -archs "$BUILD/fpc/advent" 2>/dev/null | wc -w)" -gt 1 ]; then
        name=macos
        system="macOS (Apple Silicon and Intel)"
      else
        name=macos-$arch
        system="macOS ($arch)"
      fi
      how="Unzip, open a terminal in the directory and type \"./advent\". The
program isn't signed or notarized, so macOS may refuse to run it at first.
Then remove the quarantine flag with \"xattr -d com.apple.quarantine advent\"
or allow it under System Settings, Privacy & Security."
      ;;
    Linux)
      name=linux-$arch
      system="Linux ($arch)"
      how="Unzip, open a terminal in the directory and type \"./advent\"."
      ;;
    MINGW*|MSYS*|CYGWIN*)
      name=windows
      system="Windows"
      how="Unzip, open a command prompt in the directory and type \"advent\"."
      ;;
    *)
      echo "Unknown system $(uname -s), fpc not packaged"
      return
      ;;
  esac
  package fpc "$name" "$system" "$BUILD/fpc/advent* $BUILD/fpc/*.DTA" "$how
The game opens its data files without a path, so it must be started from
that directory."
}

for t in ${*:-agon cpm dos fpc}; do
  case $t in
    agon)
      package agon agon "the Agon Light" \
        "$BUILD/agon/advent.bin $BUILD/agon/advent.ovr $BUILD/agon/*.dta" \
"Copy all files into one directory on the SD card, change into it and type
\"advent\". The game opens its data files without a path, so it must be
started from that directory. Needs MOS 3."
      ;;
    cpm)
      package cpm cpm "CP/M (Z80)" \
        "$BUILD/cpm/advent.com $BUILD/cpm/*.dta" \
"Copy all files to a CP/M disk and type \"advent\". Needs a Z80 and a TPA up
to at least \$E800 (Turbo Pascal 3 end address)."
      ;;
    dos)
      package tp55 dos "MS-DOS" \
        "$BUILD/tp55/advent.exe $BUILD/tp55/*.dta" \
"Copy all files into one directory, change into it and type \"advent\"."
      ;;
    fpc)
      package_fpc
      ;;
    *)
      echo "Unknown target $t (agon, cpm, dos, fpc)"
      exit 1
      ;;
  esac
done

#!/bin/bash
# Builds the Free Pascal version for the host.  -> build/fpc/
#
# Compiles ADVFLS and the game with fpc and creates the data files
# (*.DTA) with ADVFLS. On macOS, the game becomes a universal binary (arm64
# and x86_64) if fpc can compile for both and lipo is available. Skipped if
# fpc isn't found.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../tools/common.sh"
OUT="$BUILD/fpc"
rm -rf "$OUT"
command -v fpc > /dev/null || { echo "=== Host (Free Pascal): fpc not found, skipped"; exit 0; }

echo "=== Host (Free Pascal)"

# fpc <output dir> <program> [<options>...]
fpcc() {
  local dir=$1 prog=$2
  shift 2
  mkdir -p "$dir/units"
  fpc "$@" -FE"$dir" -FU"$dir/units" "$HERE/$prog.pas" > "$dir/$prog.log" 2>&1 ||
    { cat "$dir/$prog.log"; exit 1; }
}

fpcc "$OUT" advfls

if [ "$(uname -s)" = Darwin ] && command -v lipo > /dev/null &&
   fpc -Paarch64 -iV > /dev/null 2>&1 && fpc -Px86_64 -iV > /dev/null 2>&1; then
  for arch in aarch64 x86_64; do
    fpcc "$OUT/$arch" advent -P$arch
  done
  lipo -create -output "$OUT/advent" "$OUT/aarch64/advent" "$OUT/x86_64/advent"
  rm -rf "$OUT/aarch64" "$OUT/x86_64"
  echo "Universal binary: $(lipo -archs "$OUT/advent")"
else
  fpcc "$OUT" advent
fi

cd "$OUT"
cp "$DAT" ADVENTUR.DAT
./advfls > /dev/null
rm -rf units *.log ADVENTUR.DAT advfls advfls.exe

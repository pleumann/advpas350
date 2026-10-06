#!/bin/bash
# Builds the port of Adventure for all platforms, by calling build.sh (and,
# with --test, test.sh) in each source tree:
#
#   src/fpc    Host (Free Pascal), optional      -> build/fpc/
#   src/tp3    CP/M (Turbo Pascal 3)             -> build/cpm/
#   src/tp55   DOS (Turbo Pascal 5.5), optional  -> build/tp55/
#   src/pasta  Agon (PASTA/80)                   -> build/agon/
#
# Each tree creates its data files (*.DTA) with its own ADVFLS. The tests play
# the 350 point walkthrough with the random seed 1234 and compare the
# transcripts with tests/expected.txt (-> build/test/).
#
# usage: tools/build.sh [--test]
#
# See tools/common.sh for the tools needed and how to point to them.

set -e
. "$(dirname "$0")/common.sh"
TREES="fpc tp3 tp55 pasta"

for t in $TREES; do
  "$ROOT/src/$t/build.sh"
done

[ "$1" = "--test" ] || exit 0

echo "=== Test (seed $SEED)"
rm -rf "$BUILD/test"
FAILED=0
for t in $TREES; do
  case $t in
    pasta) out=agon ;;
    tp3) out=cpm ;;
    *) out=$t ;;
  esac
  # Skipped builds (missing compiler) leave no output directory.
  [ -d "$BUILD/$out" ] || continue
  "$ROOT/src/$t/test.sh" || FAILED=1
done
exit $FAILED

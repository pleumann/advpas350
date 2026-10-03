# Colossal Cave Adventure in Pascal

This repository contains ports of [Barry C. Breen's "Adventures in Pascal"](https://www.ibiblio.org/pub/academic/computer-science/history/pdp-11/rsx/decus/rsx82b/351130/) (1980-1983) to various old and modern Pascal compilers. The original is known as BREE0350 in [Arthur O'Dwyer's collection of Adventure versions](https://github.com/Quuxplusone/Advent). It is a translation of Kent Blackett's FORTRAN-IV-PLUS version of Crowther and Woods' Colossal Cave Adventure (350 points), written in OMSI Pascal V1.2 for RSX-11M on a PDP-11/23 and distributed via DECUS. The original distribution is in [original](original) (see [README.md](original/README.md) there), the sources extracted from it in [src/omsi](src/omsi). The ported sources are in [src](src).

The goal was to stay as close to the original as possible for each port,
applying changes only where the specific compiler needs them. There is one file per original module, with the same name (in lower case), and all comments have been kept. Changes are marked with comments starting with `CHANGED:`, so `grep CHANGED: src/tp3/*.pas` lists them for one platform. Only purely mechanical changes are not marked individually:
removed `EXTERNAL` declarations, added `OVERLAY` prefixes (PASTA/80 only), disabled `{$C ...}` blocks and removed form feeds.

The ports have been conducted with the help of Claude Code Opus 5.5.

## Status

The following compilers are currently supported:

- [Free Pascal](https://www.freepascal.org)
- [PASTA/80](https://github.com/pleumann/pasta80)
- [Turbo Pascal 3](https://en.wikipedia.org/wiki/Turbo_Pascal#Version_3)
- [Turbo Pascal 5.5](https://en.wikipedia.org/wiki/Turbo_Pascal#Version_55)

The following table shows the status per compiler and target.

| Compiler | Target        | Status |
|----------|---------------|--------|
| Free Pascal | Any   | Works (`{$MODE TP}` in the source), completes the 350 point walkthrough. Tested on macOS only. |
| PASTA/80 | Agon          | Works, with overlays (`advent.bin` 24,223 bytes, `advent.ovr` 65,536 bytes for eight 8K slots). Completes the 350 point walkthrough. |
| PASTA/80 | Spectrum Next | Compiles with overlays, but the resident part (22.7K) doesn't leave room for the heap, which needs about 7.5K. Needs more resident memory, e.g. a program start below $8000. |
| PASTA/80 | CP/M          | Too large (about 63.8K without overlays, and PASTA/80 has no overlays on disk yet). |
| PASTA/80 | Spectrum 128K | Not yet. Has overlays, but no file I/O and too little resident memory. Maybe with esxDOS. |
| PASTA/80 | Spectrum 48K  | Not yet. Has no, no file I/O and too little resident memory. Maybe with esxDOS. |
| Turbo Pascal 3 | CP/M | Works (`advent.com` 43,136 bytes, no overlays needed), completes the 350 point walkthrough. |
| Turbo Pascal 5.5 | DOS           | Works (33K code), completes the 350 point walkthrough. |

## Source trees

The sources in `src` exist four times, once per compiler. Each tree compiles
as is, without any preprocessing, and each one deviates from the original only
where its compiler requires it. The trees are maintained by hand; the
walkthrough test (see below) makes sure that they all play the same game.

| Directory | Compiler | Target |
|-----------|----------|--------|
| [src/fpc](src/fpc) | Free Pascal (TP mode) | macOS (Linux etc. untested) |
| [src/pasta](src/pasta) | PASTA/80 | Agon (later Spectrum Next and 128K) |
| [src/tp3](src/tp3) | Turbo Pascal 3 | CP/M |
| [src/tp55](src/tp55) | Turbo Pascal 5.5 | DOS |

The original sources in [src/omsi](src/omsi) make comparisons easy:
`diff src/omsi/subs1.pas src/tp3/subs1.pas` shows exactly what the port changed
for one platform, and `diff src/tp3/subs1.pas src/fpc/subs1.pas` what differs
between two platforms. Note that the main program is `main.pas` in the
original and `advent.pas` in the port.

Each tree has the same files:

| File | Contents |
|------|----------|
| `advent.pas` | Main program (formerly MAIN). Includes all other modules. |
| `advgbl.pas` | Global declarations (formerly ADVGBL). |
| `compat.pas` | New. Helpers that emulate OMSI's file buffer semantics, plus `SAYLINE` for text output. |
| `advfls.pas` | Separate program that creates the data files from `ADVENTURE.DAT` (formerly ADVFLS, now also does POOF's job). |
| everything else | One file per original module, e.g. `subs1.pas` for SUBS1. |

Helper scripts are in [tools](tools), the walkthrough test in [tests](tests).

## Building

Each source tree (except `src/omsi`) has three scripts that can be called from
anywhere:

| Script | Does |
|--------|------|
| `build.sh` | Builds the data files and the game from scratch into `build/agon`, `build/cpm`, `build/fpc` or `build/tp55`. |
| `run.sh [seed]` | Starts the game from there, in the emulator if needed. Saved games are kept in that directory. |
| `test.sh` | Plays the 350 point walkthrough and compares the transcript with the expected one (see [Testing](#testing)). |

`tools/build.sh` calls the build scripts of all trees, and with `--test` also
the test scripts:

```bash
$ tools/build.sh           # Data files and all versions
$ tools/build.sh --test    # Additionally plays the 350 point walkthrough on each
$ src/tp3/build.sh         # Only the CP/M version
$ src/tp3/run.sh 1234      # Play it under tnylpo, with random seed 1234
```

The scripts share their settings via [tools/common.sh](tools/common.sh). They need [PASTA/80](https://github.com/pleumann/pasta80) (with
[sjasmplus](https://github.com/z00m128/sjasmplus)),
[tnylpo](https://gitlab.com/gbrein/tnylpo) and Turbo Pascal 3 for CP/M (the
directory containing `TURBO.COM`, `TURBO.MSG` and `TURBO.OVR` goes into
`TP3DIR`). Free Pascal and Turbo Pascal 5.5 (`TP55DIR` with `TPC.EXE` and
`TURBO.TPL`, run under [emu2](https://github.com/dmsc/emu2) given by `EMU2`)
are optional; their build scripts skip them if they're missing. `PASTA` points
to the `pasta80` binary if it isn't the default one. Running and testing the
Agon version needs the
[Fab Agon emulator](https://github.com/tomm/fab-agon-emulator) (`FAB`,
`AGON_CLI`, see [tools/run-agon.sh](tools/run-agon.sh)). Doing it by hand works
like this:

**Data files.** The game reads its text, vocabulary and tables from random
access files, just like the original. These are created by ADVFLS. Each tree
has its own version and creates its own data files. For PASTA/80, ADVFLS is
compiled for CP/M and run under tnylpo:

```bash
$ cd src/pasta
$ pasta80 --cpm advfls.pas
$ cp ../../original/files/adventure.dat ADVENTUR.DAT    # 8.3 name for CP/M
$ tnylpo advfls
```

This creates `ADVTXT.DTA`, `KATAB.DTA`, `ADVDAT.DTA`, `ADVENT.DTA` and
`ADVWIZ.DTA` (the latter holds saved games). [tools/verify-data.py](tools/verify-data.py)
compares the first four record by record with the original 1983 files in
`original/files`. They are identical. Turbo Pascal 3 uses the same typed
file format; its ADVFLS gives the same records (only unused bytes behind the
strings differ). Free Pascal and Turbo Pascal 5.5 use typed files without a
header, so their files are different. Both Turbo Pascals need `ADVENTUR.DAT`
with CRLF line endings; with LF only, TP3's ADVFLS hangs.

**Agon.** `pasta80 --agon --ovr --release advent.pas` in `src/pasta` gives
`advent.bin` and `advent.ovr`. This needs a PASTA/80 version that includes the
fix for nested far calls in `rtl/overlays.asm` (October 2026, see below); with
an older version the game hangs after the first command. Copy `advent.bin`,
`advent.ovr` and the five `.DTA` files into the same directory on the SD card,
change into it and type `advent`. The game opens its files without a path, so
it must be started from that directory. MOS 3 is required; MOS 2.x reports
"Invalid executable".

**CP/M.** `tools/tp3c.sh src/tp3 advent` compiles the game with Turbo Pascal 3
under tnylpo by remote-controlling the `TURBO.COM` menu (it converts the line
endings to CRLF, which TP3 needs, in a build directory). Copy `advent.com` and
the five `.DTA` files to a CP/M disk and run
`advent`. Of course the sources can also be compiled with TP3 directly.

**Host and DOS.** `fpc advent.pas` in `src/fpc`, and `tpc advent.pas` in
`src/tp55`.

**Random seed.** All versions take an optional integer on the command line
(`advent 1234`), which is used as the seed of the random number generator.
The same seed gives exactly the same game on every platform. Without it, the
seed is random. (The Spectrum targets of PASTA/80 have no command line, so
there the seed will always be random.)

## Changes compared to the original

### All platforms

- **Separate compilation.** The original modules were compiled separately
  with ADVGBL in front of each and linked into an overlaid task (see
  ADVBLD.ODL). Now `advent.pas` includes everything. The `EXTERNAL`
  declarations are gone, and the include order follows the call dependencies,
  since Pascal requires declaration before use.
- **Forward declarations.** Besides the `FORWARD` declarations within
  modules that the original already had, two call cycles across modules remain: `SAYIT` calls `PARSE`
  recursively (`PARSE` is declared `FORWARD` in `advent.pas`), and `SAVE`
  calls `SAVNAME` and `SAVVAR`, which call back into VERBS4 (declared
  `FORWARD` in `verbs4.pas`). Like in Turbo Pascal 3.0, the body of a forward
  declared routine doesn't repeat the parameter list, so it is kept as a
  comment there.
- **File buffer variables.** Turbo Pascal has no `F^`, `GET` and `PUT`, and
  `RESET`/`REWRITE` don't take a file name. All accesses go through `SEEK`,
  `READ` and `WRITE` now, with the records `TXTREC` and `KATREC` taking the
  place of the buffer variables for the text and vocabulary files. The
  helpers `SEEKTXT`, `GETTXT` and `SEEKKAT` in `compat.pas` emulate OMSI's
  semantics, where `SEEK` also loads the record into the buffer.
- **Record numbers.** OMSI numbers file records from 1, Turbo Pascal from 0.
  Every data file has a dummy record 0, so all record numbers (and hence all
  pointers stored in the data files) are the same as in the original.
- **Character arrays.** `WORD = ARRAY[1..5] OF CHAR` and
  `LINE = ARRAY[1..72] OF CHAR` became `STRING[5]` and `STRING[72]`, since
  PASTA/80 can't compare character arrays with string literals or write them
  with `WRITELN`. The other ports do the same to keep the sources alike. Words are always padded to five characters, so comparisons
  like `WRD1='WEST '` work unchanged. Input lines are padded to 72 characters
  like OMSI did.
- **Procedure parameters.** `ASK` received `RSPEAK` or `MSPEAK` as a
  procedure parameter, which Turbo Pascal doesn't support. A Boolean flag
  selects the output procedure now.
- **`UNSIGNED = 0..65535`** is gone. It was only used for dates, times and the
  random number seed. The seed is an `INTEGER` now.
- **Random numbers.** `RAN` still uses the original generator
  (`SEED*13077+6925`), now with `AND 32767` instead of `MOD 32768`, since
  `SEED` is a signed integer. This gives exactly the same numbers as OMSI's
  unsigned arithmetic, with all four compilers. The seed comes from the
  command line or the runtime's `RANDOM` instead of the time of day.
- **Minor stuff.** The octal constant `33B` became `#27`. The `{$C ...}` blocks
  with embedded MACRO-11 code are disabled (`{ $C ...}`).

### Per platform

| Issue | PASTA/80 | TP3 | Free Pascal | TP 5.5 |
|-------|----------|-----|-------------|--------|
| OMSI's `EXIT` leaves the innermost loop | `BREAK` | `GOTO 9` (no `BREAK`) | `BREAK` | `GOTO 9` (no `BREAK`) |
| Loop variable of the enclosing procedure (`GETWORD`, `GETDT`, ADVFLS' `NEWREC`) | as is | as is | local variable | local variable |
| `VAR` parameter as loop variable (`SAVNAME`) | as is | local variable | local variable | local variable |
| `ARRAY[-1..LOCSIZ]` | constant `CARRIED=-1` | as is | as is | as is |
| Local procedure `OBJECT` in PARSE (reserved word) | as is | as is | `OBJCT` | `OBJCT` |
| Boolean evaluation | complete (default) | complete (default) | complete via `{$B+}` | complete via `{$B+}` |
| Pointer accessed before checking for NIL (5 places) | as is | as is | checked first | checked first |
| Directives | `{$A-}` (locals on stack), `{$M 2048}` | `{$A-}`, `{$C-}` | `{$MODE TP}`, `{$B+}` | `{$B+}` |
| Overlays | `OVERLAY` prefixes | none | none | none |

Some notes on these:

- **Complete boolean evaluation.** Free Pascal and Turbo Pascal 5.5
  short-circuit by default. This would skip calls of the random number
  generator in some conditions, so games with the same seed would differ from
  the other versions.
- **NIL pointers.** Five places in the original access a pointer before
  checking it for NIL, e.g. `(LINK2^.VERBVAL<>K) AND (LINK2<>NIL)` in
  `SEARCH`. On the PDP-11 and the Z80 this just reads some word near address
  0, so PASTA/80 and TP3 keep the original. On modern systems it crashes, so
  the Free Pascal and Turbo Pascal 5.5 versions check first (in `SEARCH`,
  `MOVE`, `TAKEIT`, `BACKUP` and `INITIALIZE`), with the same results.
- **`{$A-}`** means "locals on the stack" in PASTA/80 and TP3. It is needed
  for the recursion `SAYIT` -> `PARSE`, and on the Agon because static locals
  of an overlay would be reset when the overlay is reloaded. In Free Pascal and
  Turbo Pascal 5.5 `$A` means alignment and would change the record layout.
- **`{$M 2048}`** reduces PASTA/80's stack to 2K, which is plenty (checked with
  `{$K+}` during the full walkthrough).
- **`{$C-}`** turns off TP3's ^C check, which would otherwise eat characters
  typed ahead.
- **`{$MODE TP}`** makes Free Pascal accept the bodies of `FORWARD` declared
  routines without a parameter list and assignments to `FOR` loop variables
  (the original leaves loops this way in VERBS3 and LOOP0). It also keeps
  `INTEGER` at 16 bits.
- **Overlays.** With `--ovr`, PASTA/80 puts the game into eight overlays, all
  below 8K. The grouping loosely follows ADVBLD.ODL: base routines (SUBS0,
  SUBS1, SPEAK, GETIN, ASK, ...) stay resident, the rest is grouped by usage
  (input parsing, main loop, verbs, travel, initialization etc.). Without
  `--ovr` the `OVERLAY` markers are ignored. The TP3 version fits into a CP/M
  TPA without overlays.
- **Compiler workaround.** `src/pasta/advent.pas` contains a never executed
  reference to `DOOBJ` and `DOVERB` (marked as such). It works around a bug in
  PASTA/80's dependency analysis: a call from a nested procedure to a
  `FORWARD` procedure whose body hasn't been compiled yet makes the compiler
  drop everything that is only called from that body. Remove the workaround
  once the compiler has been fixed. Compiled with `HEAPINFO` defined, the
  PASTA/80 version also shows how much heap `INITIALIZE` uses (about 7.2K for
  the travel table).

### Removed: wizardry

The original contained a lot of code for running the game on a multi-user
system: prime time (cave hours) with demonstration games, holidays, a message
of the day, a magic mode for maintenance, a wizard check with magic word and
number, and a latency for restoring saved games. All of this has been
removed, along with the modules MAGICM, WIZMAG, PRIMET and DATIME and the
separate programs POOF, PEEK and 100FLS.

- `START` only checks for saved games now.
- `HOURS` (the "hours" command) prints what the original printed with the
  initial settings created by POOF: open all day.
- The "magic mode" check in `RESPONSE` is gone.
- `DEMO` is always false, so demonstration games never happen.

### Saving and restoring games

"Suspend" works like in the original, including the three named slots and
the wizard who appears when you restore. Saved games still live in
`ADVWIZ.DTA`, with the same record layout. ADVFLS creates the initial file
(formerly POOF's job), and only the parts needed for saved games are written.
Date and time of saving are no longer recorded (zeroes keep the layout), and
there's no latency anymore. Hence magic message 50 ("...but you will have to")
followed by "wait at least N minutes before continuing." has been replaced by
"I can suspend your Adventure so you can resume later."

### Removed: VT-100 database

The original asked "Are you using a VT100?" and then used a second set of
text files with double width and double height characters. This is not
supported, so the question is gone. Note that `ADVENTURE.100` in the
distribution is identical to `ADVENTURE.DAT`, so the VT-100 source text seems
to be lost. The compiled VT-100 texts still exist in `ADVTXT.100`, though.

### ADVFLS

- Reads `ADVENTURE.DAT` line by line and splits it up itself, since PASTA/80's
  `READ` can neither read comma-separated integers nor integers directly
  followed by text.
- Uses the file name `ADVENTUR.DAT`, since CP/M only allows 8.3 names.
- Creates `ADVWIZ.DTA` (see above).

## Things worth knowing

- **The data is verified.** The files created by the ported ADVFLS are
  identical, record by record, to the 1983 files from RSX. This also shows that
  `STRING[72]` truncates long lines exactly like the original did.
- **Quirks of the original are preserved.** For instance, the first line of
  `ADVENTURE.DAT` is a lone "1", which gives location 1 an empty first line.
  `ADVTXT.DTA` in the original distribution contains four stale records beyond
  the end of the data (from an older, longer version of the file).
- **Loading messages.** "Be patient...", "Now loading sections 1-7" and
  "Now loading section 8" to "12" are original. The latter are magic messages
  32 to 36 from `ADVENTURE.DAT`.
- **Overlay fix in PASTA/80.** Porting the game revealed a bug in the far call
  trampoline (`rtl/overlays.asm`): calling the same overlay twice from root
  code, with that overlay calling another overlay, left the wrong overlay
  banked in. This has been fixed, and `tests/overlays.pas` in the PASTA/80 test
  suite covers it now (as of October 2026, not yet in a release). A forward declaration and its body must be in the same
  overlay, otherwise calls end up in the wrong code. All forward declarations
  in this port fulfill that.
- **CP/M memory.** TP3 reports about 34.9K code (plus its 8K runtime), 6.4K
  data and 14.8K free memory for heap and stack, compiled under tnylpo. TP3
  places the data at the end address of the system it compiled on, so on a
  CP/M machine with a smaller TPA the end address needs to be adjusted (TP3's
  options menu). The game needs roughly 7.2K heap plus some stack, so the end
  address can't go much below $E400 (calculated, not tested on real
  hardware).
- **Original limitations stay.** The lamp lasts 330 turns (1000 if you ask
  for instructions, which costs 5 points). The 350 point walkthrough in
  `tests/walkthrough.txt` needs 424 turns. The lamp runs out of power just
  after reaching the plover room, which is lit, so waiting for the cave to
  close there works. With this random seed, getting out of Witt's End takes
  33 attempts, and the game offers a hint on the way (answered with "no").

## Testing

`src/*/test.sh` (or `tools/build.sh --test` for all of them) plays
`tests/walkthrough.txt` with each version, using
the random seed 1234 from the command line: in the Fab Agon CLI emulator, under
tnylpo, on the host and under emu2. It compares the transcripts with
`tests/expected.txt` (results in `build/test`). Since the random number generator is the same
everywhere, there is a single expected transcript for all platforms.
[tools/normalize.sh](tools/normalize.sh) strips emulator banners and blank lines
before the comparison, and [tools/echo-input.py](tools/echo-input.py) inserts the
input lines into the transcripts of the host and DOS versions, which read from
a redirected stdin. The walkthrough collects all 15 treasures, deals with the
troll, bear, dragon, pirate and dwarves, drops the magazine at Witt's End,
waits for the cave to close and ends with the blast at the right end of the
repository: 350 out of 350 points.

The stock Agon CLI emulator feeds at most one input line per second, so its
run of the 427 input lines takes more than seven minutes. Setting `AGON_CLI` to a build with a shorter delay
(the constant is in `agon-cli-emulator/src/main.rs`) brings this down to about
20 seconds. [tools/play.py](tools/play.py) only sends the next line after the
game has printed its prompt, so nothing gets lost either way.

[tools/route.py](tools/route.py) finds routes between locations using the
travel table, which helps with writing walkthroughs.

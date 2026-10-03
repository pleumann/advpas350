"""Plays a game script against an emulator, expect-style: each input line is
only sent after the game has printed its input prompt, so no keystrokes get
lost.  The transcript goes to stdout.

usage: play.py [--prompt P] [--timeout S] <input-file> -- <emulator command...>

The first line of the input file is sent at the first prompt as well, so for
the Agon it should be the MOS command that starts the game.
"""
import os, re, select, subprocess, sys, time

args = sys.argv[1:]
prompts = [b'->', b'/ *']        # game prompt, MOS prompt
timeout = 30.0
while args[0].startswith('--'):
    if args[0] == '--prompt':
        prompts = [p.encode() for p in args[1].split(',')]; args = args[2:]
    elif args[0] == '--timeout':
        timeout = float(args[1]); args = args[2:]
    else:
        break
script = args[0]
cmd = args[args.index('--') + 1:]

lines = [l.rstrip('\n') for l in open(script)]
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        stderr=subprocess.STDOUT)
fd = proc.stdout.fileno()
buf = b''
out = sys.stdout.buffer

def emit(data):
    data = data.replace(b'\r', b'')
    data = b'\n'.join(l for l in data.split(b'\n') if b'nknown packet' not in l)
    out.write(data); out.flush()

status = 0
T0 = time.time()
while True:
    r, _, _ = select.select([fd], [], [], timeout)
    if not r:
        sys.stderr.write('\n*** timeout waiting for output (%d lines left)\n' % len(lines))
        status = 1
        break
    data = os.read(fd, 4096)
    if not data:
        break
    emit(data)
    buf = (buf + data)[-200:]
    tail = buf.rstrip(b' ')
    if any(tail.endswith(p) for p in prompts):
        buf = b''
        if not lines:
            break
        line = lines.pop(0)
        if os.environ.get('PLAY_DEBUG'): sys.stderr.write('[%.2f] %s\n' % (time.time() - T0, line))
        time.sleep(0.02)
        proc.stdin.write(line.encode() + b'\r\n')
        proc.stdin.flush()

proc.kill()
sys.exit(status)

"""Inserts the input lines into a game transcript after each "->" prompt, as
an echoing terminal would show them. Needed for versions that read their
input from a redirected stdin (Free Pascal, Turbo Pascal 5.5 under emu2), so
their transcripts can be compared with the ones from the emulators.

usage: echo-input.py <input-file> < transcript > transcript-with-input
"""
import sys

commands = open(sys.argv[1]).read().split('\n')
text = sys.stdin.read().replace('\r', '')
out, pos, i = [], 0, 0
while True:
    j = text.find('->', pos)
    if j < 0 or i >= len(commands):
        break
    out.append(text[pos:j + 2] + commands[i] + '\n')
    i += 1
    pos = j + 2
out.append(text[pos:])
sys.stdout.write(''.join(out))

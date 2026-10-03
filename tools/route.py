"""Helper for writing walkthroughs: finds the shortest unconditional route
between two locations using the travel table in ADVENTURE.DAT.
usage: route.py <adventure.dat> <from-loc> <to-loc>
       route.py <adventure.dat> <loc>          (describes a location)
Conditional motions (COND<>0) and special destinations are ignored, so the
result may need manual adjustments (e.g. for the crystal bridge or troll).
"""
import sys, collections

lines = open(sys.argv[1]).read().splitlines()
sections, cur = [], []
for l in lines[1:]:
    if l.strip() == '-1':
        sections.append(cur); cur = []
    else:
        cur.append(l)

def text(sec, n):
    out = []
    for l in sections[sec]:
        num = ''.join(c for c in l[:4] if c.isdigit())
        i = len(num)
        while i < len(l) and l[i].isdigit(): i += 1
        if l[:i].isdigit() and int(l[:i]) == n: out.append(l[i:])
    return out

words = collections.defaultdict(list)          # motion verb number -> words
for l in sections[6]:
    i = 0
    while l[i].isdigit(): i += 1
    v = int(l[:i])
    if v < 1000: words[v].append(l[i:].strip())

edges = collections.defaultdict(list)          # loc -> [(newloc, verb word)]
seen = set()                                    # (loc, verb) already decided
for l in sections[7]:
    nums = [int(x) for x in l.split(',')]
    loc, cond, new, verbs = nums[0], nums[1], nums[2], [v for v in nums[3:] if v]
    for v in verbs:
        # Only the first entry for a verb counts.  If that one is conditional
        # (random, object-dependent) or special, the verb is unreliable.
        if (loc, v) in seen: continue
        seen.add((loc, v))
        if cond == 0 and new <= 300 and words[v]:
            edges[loc].append((new, min(words[v], key=len)))

if len(sys.argv) == 3:
    n = int(sys.argv[2])
    print('\n'.join(text(0, n)))
    print('short:', ' '.join(text(1, n)))
    print('exits:', ', '.join('%s->%d' % (w, d) for d, w in edges[n]))
    sys.exit()

src, dst = int(sys.argv[2]), int(sys.argv[3])
prev = {src: None}
queue = collections.deque([src])
while queue:
    loc = queue.popleft()
    if loc == dst: break
    for new, w in edges[loc]:
        if new not in prev:
            prev[new] = (loc, w); queue.append(new)
if dst not in prev:
    sys.exit('no unconditional route')
path, loc = [], dst
while prev[loc]:
    loc, w = prev[loc][0], prev[loc][1]
    path.append(w)
print('\n'.join(reversed(path)))

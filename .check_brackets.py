import sys
from collections import deque
p = r"d:/Repos/Predicthealth/app/java/PredictHealthJava.java"
pairs = {'(':')','[':']','{':'}'}
openers = set(pairs.keys())
closers = set(pairs.values())
stack = deque()
errors = []
with open(p,'r', encoding='utf-8') as f:
    for i,line in enumerate(f, start=1):
        for j,ch in enumerate(line, start=1):
            if ch in openers:
                stack.append((ch,i,j))
            elif ch in closers:
                if not stack:
                    errors.append((i,j,'extra_closer',ch))
                else:
                    last, li, lj = stack.pop()
                    if pairs[last] != ch:
                        errors.append((i,j,'mismatch', last+"->"+ch))
# after file
if stack:
    for last, li, lj in stack:
        errors.append((li,lj,'unclosed', last))
if not errors:
    print('All brackets balanced')
    sys.exit(0)
print('Found bracket issues:')
for e in errors:
    print(e)
sys.exit(1)

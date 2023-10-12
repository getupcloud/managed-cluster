#!/usr/bin/env python3

import os
import sys
import json
import json
import glob
from hcl2.parser import hcl2

def flatten(l):
    return [item for sublist in l for item in sublist]

if len(sys.argv) > 1:
    sources = sys.argv[1:]
else:
    prefix = os.environ.get("CLUSTER_DIR", "./")
    sources = [ os.path.join(prefix, "variable*.tf") ]


variables = []
for f in flatten([ glob.glob(i) for i in sources ]):
    with open(f, 'r') as f:
        data = hcl2.parse(f.read())
        for v in data.get('variable', []):
            variables.append(v)

variables = sorted(variables, key=lambda a: tuple(a.keys())[0])
print(json.dumps(variables))

def read_var(v):
    if v['default'] != null:
        return v
    return v

for v in variables:
    v = read_var(v)



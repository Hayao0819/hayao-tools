#!/usr/bin/env python3

import hashlib, time

iv = 0
k = 28

ts = time.perf_counter()
while True:
    hv = hashlib.sha256(str(iv).encode()).hexdigest()
    if int(hv, 16) % (2**k) == 0:
        print("nonce=", iv)
        print("hash=", hv)
        break
    iv += 1
te = time.perf_counter()
print("time=", te - ts)

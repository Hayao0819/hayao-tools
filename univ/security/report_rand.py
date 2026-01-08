#!/usr/bin/env python3


"""
乱数でマイニングの擬似コード
"""

import hashlib
import time
import os
import base64


iv = ""
k = 24


def generate_raw_random_string(length=16):
    random_bytes = os.urandom(length)
    return base64.urlsafe_b64encode(random_bytes).decode("utf-8")[:length]


def update_iv():
    global iv
    iv = generate_raw_random_string(16)


ts = time.perf_counter()
while True:
    hv = hashlib.sha256(str(iv).encode()).hexdigest()
    if int(hv, 16) % (2**k) == 0:
        print("nonce=", iv)
        print("hash=", hv)
        break
    update_iv()
te = time.perf_counter()
print("time=", te - ts)

#!/usr/bin/env python3

import sys
import shutil


def main():
    for f in sys.argv[1:]:
        print(f"Copying {f} to {f}.bak")
        shutil.copyfile(f, f + ".bak")

if __name__ == "__main__":
    main()

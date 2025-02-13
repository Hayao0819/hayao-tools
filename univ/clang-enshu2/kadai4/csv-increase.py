#!/usr/bin/env python3

import csv
import sys

def main():
    csv_data = []
    reader = csv.reader(sys.stdin)
    for row in reader:
        csv_data.append([int(row[0]), float(row[1])])

    # 増加率を計算
    for i in range(1, len(csv_data)):
        previous_value = csv_data[i - 1][1]
        current_value = csv_data[i][1]
        increase_rate = (current_value/previous_value )
        print(f"{csv_data[i-1][0]} -> {csv_data[i][0]}, {increase_rate:.2f}")

if __name__ == "__main__":
    main()

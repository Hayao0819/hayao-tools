import matplotlib.pyplot as plt
import csv
import sys
import os
from typing import List


def read_data_from_stdin() -> (List[int], List[float]):
    x_values = []
    y_values = []

    reader = csv.reader(sys.stdin)
    for row in reader:
        x_values.append(int(row[0]))
        y_values.append(float(row[1]))

    return x_values, y_values


def plot_and_save_graph(x_values: List[int], y_values: List[float], output_file: str) -> None:
    output_dir = os.path.dirname(output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    plt.figure(figsize=(10, 6))
    plt.plot(x_values, y_values, marker='o', label="Data points")
    plt.title("Graph of Y vs X", fontsize=14)
    plt.xlabel("X Values", fontsize=12)
    plt.ylabel("Y Values", fontsize=12)
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend()
    plt.savefig(output_file, format="png", dpi=300)
    print(f"Graph saved to: {output_file}")


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python script.py <output_file>")
        sys.exit(1)

    output_file = sys.argv[1]
    x_values, y_values = read_data_from_stdin()
    plot_and_save_graph(x_values, y_values, output_file)


if __name__ == "__main__":
    main()

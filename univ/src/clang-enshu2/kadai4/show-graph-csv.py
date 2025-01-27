import numpy as np
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

def plot_and_save_graph_with_fit(x_values: List[int], y_values: List[float], output_file: str) -> None:
    output_dir = os.path.dirname(output_file)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    # Perform least squares linear fit
    A = np.vstack([x_values, np.ones(len(x_values))]).T
    m, c = np.linalg.lstsq(A, y_values, rcond=None)[0]

    # # Generate additional functions for x^1.25 and x*log(x)
    # x_range = np.linspace(min(x_values), max(x_values), 500)
    # y_power = x_range ** 1.25
    # y_log = x_range * np.log(x_range)

    # Plot original data and linear fit
    plt.figure(figsize=(10, 6))
    plt.plot(x_values, y_values, marker='o', label="Data points")

    # Plot linear fit
    fit_y_values = [m * x + c for x in x_values]
    plt.plot(x_values, fit_y_values, label=f"Linear fit: y = {m}x + {c}", color="red")

    # Plot additional graphs
    # plt.plot(x_range, y_power, label=r"$y = x^{1.25}$", color="green", linestyle="--")
    # plt.plot(x_range, y_log, label=r"$y = x \log{x}$", color="blue", linestyle="-.")

    # Add titles and labels
    plt.title("Graph of Y vs X", fontsize=14)
    plt.xlabel("X Values", fontsize=12)
    plt.ylabel("Y Values", fontsize=12)
    
    # Grid and legend
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend()
    plt.savefig(output_file, format="png", dpi=300)
    print(f"Graph with linear fit saved to: {output_file}")

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: python script.py <output_file>")
        sys.exit(1)

    output_file = sys.argv[1]
    x_values, y_values = read_data_from_stdin()
    plot_and_save_graph_with_fit(x_values, y_values, output_file)

if __name__ == "__main__":
    main()

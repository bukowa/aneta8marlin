import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import argparse
import os

def parse_marlin_output(text_output):
    """
    Parses Marlin's G29 T output robustly.
    It identifies only the actual data rows and ignores headers or other text.
    """
    data_rows = []
    lines = text_output.strip().split('\n')

    for line in lines:
        clean_line = line.strip()
        if clean_line.startswith("Recv:"):
            clean_line = clean_line[5:].strip()
        if clean_line.startswith("echo:"):
            clean_line = clean_line[5:].strip()

        parts = clean_line.split()

        # A valid data row starts with a digit and the next part contains a decimal.
        # This correctly distinguishes data from the integer-only header.
        if len(parts) >= 2 and parts[0].isdigit() and '.' in parts[1]:
            try:
                row_values = [float(p) for p in parts[1:]]
                data_rows.append(row_values)
            except ValueError:
                continue

    if not data_rows:
        return None

    return np.array(data_rows)


def plot_heatmap(data_array, filename=""):
    """
    Generates and displays a heatmap with the Y-axis oriented
    to match a standard 3D printer bed (0 at the bottom).
    """
    if data_array is None or data_array.size == 0:
        print("Could not find any valid mesh data in the input.")
        return

    plt.figure(figsize=(10, 8))
    ax = sns.heatmap(
        data_array,
        cmap='coolwarm',
        annot=True,
        fmt=".3f",
        linewidths=.5,
        cbar_kws={'label': 'Z-Offset from Zero (mm)'}
    )

    # --- THIS IS THE KEY CHANGE ---
    # Invert the Y-axis to place the origin (0,0) at the bottom-left corner.
    ax.invert_yaxis()
    # ----------------------------

    title = 'Bed Leveling Mesh Heatmap'
    if filename:
        title += f'\n(from {os.path.basename(filename)})'
    ax.set_title(title, fontsize=16)

    # Update labels for clarity
    ax.set_xlabel('X Probe Points (0 = Left Side)')
    ax.set_ylabel('Y Probe Points (0 = Front of Bed)')

    print("Displaying heatmap. Close the plot window to exit.")
    plt.show()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate a heatmap from a Marlin G29 T output file.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        'filepath',
        nargs='?',
        default='mesh.txt',
        help="Path to the text file containing G29 T output.\n"
             "If omitted, defaults to 'mesh.txt'."
    )
    args = parser.parse_args()

    try:
        print(f"Attempting to read mesh data from: {args.filepath}")
        with open(args.filepath, 'r') as f:
            file_content = f.read()

        bed_data = parse_marlin_output(file_content)
        plot_heatmap(bed_data, filename=args.filepath)

    except FileNotFoundError:
        print(f"\n--- ERROR ---")
        print(f"File not found: '{args.filepath}'")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
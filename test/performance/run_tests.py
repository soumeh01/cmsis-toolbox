import os
import csv
import subprocess
import platform
import datetime
import argparse
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

# def plot_execution_times(csv_file="performance_record.csv", output_file="execution_times_plot.png"):
#     """Reads execution times from a CSV file and plots a line graph, saving the output to a file."""
#     # Load the CSV file
#     df = pd.read_csv(csv_file)

#     # Convert Date column to datetime for better plotting
#     df['Date'] = pd.to_datetime(df['Date'])


#     # Set Date as the index for plotting
#     df.set_index('Date', inplace=True)

#     # Convert non-numeric values (like 'N/A') to NaN
#     df.replace("N/A", None, inplace=True)

#     # Convert execution times to float (ignoring NaN values)
#     df = df.astype(float)

#     # Plot the data
#     plt.figure(figsize=(10, 5))
#     for column in df.columns:
#         plt.plot(df.index, df[column], marker='o', linestyle='-', label=column)

#     # Formatting
#     plt.xlabel("Date")
#     plt.ylabel("Execution Time (seconds)")
#     plt.title("Scenario Execution Times Over Time")
#     plt.xticks(rotation=45)  # Rotate dates for better visibility
#     plt.legend(title="OS-Scenario", bbox_to_anchor=(1.05, 1), loc="upper left")  # Move legend outside
#     plt.grid(True)

#     # Save the plot
#     plt.tight_layout()
#     plt.savefig(output_file, bbox_inches="tight")
#     print(f"Plot saved as {output_file}")

def get_os():
    """Return a short OS name."""
    os_name = platform.system()
    return {"Windows": "Win", "Linux": "Linux", "Darwin": "MacOS"}.get(os_name, "Unknown")

def execute_command(command):
    """Execute a shell command and measure execution time."""
    start_time = datetime.datetime.now()
    try:
        subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print ("error:\n", e.output)
        return "N/A"  # Return N/A if the command fails
    end_time = datetime.datetime.now()
    return round((end_time - start_time).total_seconds(), 2)

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Run performance tests and record execution times")
    parser.add_argument('-i', '--example_root_dir', type=str, required=True, help='Root folder path to example directory')
    parser.add_argument('-o', '--output_file', type=str, default="./performance_record.csv", help='Path to the output csv file')
    return parser.parse_args()

def main():
    args = parse_arguments()
    os_type = get_os()
    cwd = Path.cwd()
    date_today = datetime.datetime.now().strftime("%m/%d/%Y")
    
    scenarios = {
        "Case1": "build-cpp/solution.csolution.yml",
        "Case2": "build-c/solution.csolution.yml"
    }
    
    csv_file = cwd / args.output_file
    csv_file = csv_file.resolve()
    # Read existing headers if file exists, otherwise create new ones
    try:
        with open(csv_file, "r") as f:
            reader = csv.reader(f)
            headers = next(reader)
    except (FileNotFoundError, StopIteration):
        headers = ["Date"]  # Start with Date column

    # Generate OS-Scenario headers
    for scenario in scenarios.keys():
        column_name = f"{os_type}-{scenario}"
        if column_name not in headers:
            headers.append(column_name)

    # Execute scenarios and store results
    results = {header: "N/A" for header in headers}  # Default all columns to N/A
    results["Date"] = date_today

    for scenario, example in scenarios.items():
        csolution = cwd / args.example_root_dir / example
        csolution = csolution.resolve()
        command = "cbuild setup -S " + str(csolution) + " --update-rte" + " --packs"
        exec_time = execute_command(command)
        results[f"{os_type}-{scenario}"] = exec_time

    # Write to CSV file
    write_new_file = not os.path.exists(csv_file)  # Check if file needs a header row

    with open(csv_file, "a", newline="") as f:
        writer = csv.writer(f)
        
        if write_new_file:
            writer.writerow(headers)  # Write headers if file is new
        
        row = [results[header] for header in headers]  # Order values correctly
        writer.writerow(row)

    print(f"Execution times recorded in {csv_file}")
    # plot_execution_times("performance_record.csv", "execution_times_plot.png")

if __name__ == "__main__":
    main()

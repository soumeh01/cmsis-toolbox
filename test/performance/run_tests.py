import os
import csv
import sys
import subprocess
import platform
import datetime
import argparse
from pathlib import Path
import pandas as pd
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Defining a TEST EXAMPLES to be executed
TEST_CASES = {
    "Case1": "build-cpp/solution.csolution.yml",
    "Case2": "build-c/solution.csolution.yml"
}

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
        return "N/A" # Return N/A if the command fails
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
    
    csv_file = cwd / args.output_file
    csv_file = csv_file.resolve()
    # Read existing headers if file exists, otherwise create new ones
    try:
        with open(csv_file, "r") as f:
            reader = csv.reader(f)
            headers = next(reader)
    except (FileNotFoundError, StopIteration):
        # Start with Date column
        headers = ["Date"]

    # Generate OS-Scenario headers
    for scenario in TEST_CASES.keys():
        column_name = f"{os_type}-{scenario}"
        if column_name not in headers:
            headers.append(column_name)

    # Execute scenarios and store results (Default all columns to N/A)
    results = {header: "N/A" for header in headers}
    results["Date"] = date_today

    for scenario, example in TEST_CASES.items():
        csolution = cwd / args.example_root_dir / example
        csolution = csolution.resolve()
        command = "cbuild setup -S " + str(csolution) + " --update-rte" + " --packs"
        exec_time = execute_command(command)
        results[f"{os_type}-{scenario}"] = exec_time

    # Write to CSV file and check if file needs a header row
    write_new_file = not os.path.exists(csv_file)

    with open(csv_file, "a", newline="") as f:
        writer = csv.writer(f)
        
        if write_new_file:
            # Write headers if file is new
            writer.writerow(headers)
        
        row = [results[header] for header in headers]
        writer.writerow(row)

    print(f"Execution times recorded in {csv_file}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}")
        sys.exit(1)

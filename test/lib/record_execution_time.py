import os
import csv
import subprocess
import platform
import datetime
from pathlib import Path
import pandas as pd
import logging
from urllib.parse import urlparse

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def get_os():
    """Return a short OS name."""
    os_name = platform.system()
    return {"Windows": "Win", "Linux": "Linux", "Darwin": "MacOS"}.get(os_name, "Unknown")

def execute_command(command):
    """Execute a shell command and measure execution time."""
    start_time = datetime.datetime.now()
    try:
        logging.info(f"Executing command: {command}")
        result = subprocess.run(
            command, shell=True, check=True, 
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
        )
        output = result.stdout.strip()
        errStr = result.stderr.strip()
        print(output)
    except subprocess.CalledProcessError as e:
        error_msg = e.stdout.strip() if e.stdout else "Unknown error"
        logging.error(f"Command failed: {error_msg}")
        return "N/A" # Return N/A if the command fails
    end_time = datetime.datetime.now()
    return round((end_time - start_time).total_seconds(), 2)

def record_execution_times(inputs: list, output_file: str):
    """Record execution times in a CSV file."""
    os_type = get_os()
    cwd = Path.cwd()
    date_today = datetime.datetime.now().strftime("%m/%d/%Y")

    csv_file = cwd / output_file
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
    for input in inputs:
        parts = input.split(',')
        parsed_url = urlparse(parts[0])
        scenario = parsed_url.path.rstrip('/').split('/')[-1]
        column_name = f"{os_type}-{scenario}"
        if column_name not in headers:
            headers.append(column_name)

    # Execute scenarios and store results (Default all columns to N/A)
    results = {header: "N/A" for header in headers}
    results["Date"] = date_today

    for input in inputs:
        parts = input.split(',')
        parsed_url = urlparse(parts[0])
        scenario = parsed_url.path.rstrip('/').split('/')[-1]

        csolution = parts[-1] + "/" + parts[1]
        csolution = Path(csolution).resolve()
        command = "cbuild setup -S " + str(csolution) + " --update-rte" + " --packs" + " --toolchain AC6"
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

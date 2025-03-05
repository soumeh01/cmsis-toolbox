import pandas as pd
import glob
import argparse
import logging
import os
import matplotlib.pyplot as plt

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def plot_execution_trend(csv_file="consolidated_perf_report.csv", output_file="performance_plot.png"):
    """Reads execution times from a CSV file and plots a line graph, saving the output to a file."""
    # Load the CSV file
    df = pd.read_csv(csv_file)

    # Convert Date column to datetime for better plotting
    df['Date'] = pd.to_datetime(df['Date'])


    # Set Date as the index for plotting
    df.set_index('Date', inplace=True)

    # Convert non-numeric values (like 'N/A') to NaN
    df.replace("N/A", None, inplace=True)

    # Convert execution times to float (ignoring NaN values)
    df = df.astype(float)

    # Plot the data
    plt.figure(figsize=(10, 5))
    for column in df.columns:
        plt.plot(df.index, df[column], marker='o', linestyle='-', label=column)

    # Formatting
    plt.xlabel("Date")
    plt.ylabel("Execution Time (seconds)")
    plt.title("Scenario Execution Times Over Time")
    plt.xticks(rotation=45)  # Rotate dates for better visibility
    plt.legend(title="OS-Scenario", bbox_to_anchor=(1.05, 1), loc="upper left")  # Move legend outside
    plt.grid(True)

    # Save the plot
    plt.tight_layout()
    plt.savefig(output_file, bbox_inches="tight")
    print(f"Plot saved as {output_file}")

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Run performance tests and record execution times")
    parser.add_argument('-d', '--perf_record_dir', type=str, required=True, help='Root folder path to all csv files')
    return parser.parse_args()

def main():
    args = parse_arguments()

    # Iterate over immediate subdirectories
    for entry in os.scandir(args.perf_record_dir):
        if entry.is_dir():
            # Define the pattern to match your CSV files
            csv_files = glob.glob(entry.path + '/*_amd64.csv', recursive=False)

            # Initialize an empty DataFrame
            merged_df = pd.DataFrame()
            for file in csv_files:
                # Read each CSV file into a DataFrame
                df = pd.read_csv(file)
                # Merge the current DataFrame with the accumulated DataFrame
                if merged_df.empty:
                    merged_df = df
                else:
                    merged_df = pd.merge(merged_df, df, on="Date", how="outer")
            # Save the merged DataFrame to a new CSV file
            merged_df.to_csv(entry.path + "/merged.csv", index=False)

    # Define the pattern to match your CSV files
    merged_csv_files = glob.glob(args.perf_record_dir + '/**/merged.csv', recursive=True)
    print(merged_csv_files)
    if len(merged_csv_files) != 1:
        logging.error("Expected only one merged CSV file, but found multiple or none")
        return
    
    past_consolidated_csv_files = glob.glob(args.perf_record_dir + '/**/last_run_consolidated_performance_report.csv', recursive=True)
    if len(past_consolidated_csv_files) > 1:
        logging.error("Expected none or only one last run performance report file")
        return

    consolidated_df = pd.read_csv(merged_csv_files[0])
    if len(past_consolidated_csv_files) == 1:
        last_consolidated_df = pd.read_csv(past_consolidated_csv_files[0])
        # Check if columns are the same
        if list(consolidated_df.columns) == list(last_consolidated_df.columns):
            consolidated_df = pd.concat([last_consolidated_df, consolidated_df], ignore_index=True)
        else:
            logging.error(f"Error merging failed, The headers doesn't match {merged_csv_files[0]} and {past_consolidated_csv_files[0]}")
            return

    # Save the consolidated DataFrame to a new CSV file
    consolidated_df.to_csv("consolidated_perf_report.csv", index=False)

if __name__ == "__main__":
    main()

import pandas as pd
import glob
import argparse
import logging
import os

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

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
            csv_files = glob.glob(entry.path + '/*.csv', recursive=False)

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
    csv_files = glob.glob(args.perf_record_dir + '/**/merged.csv', recursive=True)
    # Initialize an empty DataFrame
    consolidated_df = pd.DataFrame()
    # Iterate over the list of CSV files
    for file in csv_files:
        # Read each CSV file into a DataFrame
        df = pd.read_csv(file)
        # Merge the current DataFrame with the accumulated DataFrame
        if consolidated_df.empty:
            consolidated_df = df
        else:
            # Check if columns are the same
            if list(consolidated_df.columns) == list(df.columns):
                consolidated_df = pd.concat([consolidated_df, df], ignore_index=True)
            else:
                logging.error(f"Error merging failed, The headers doesn't match in {file}")
                return

    # Save the merged DataFrame to a new CSV file
    consolidated_df.to_csv("consolidated_perf_report.csv", index=False)


if __name__ == "__main__":
    main()

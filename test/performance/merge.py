import pandas as pd
import glob
import argparse

def parse_arguments():
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(description="Run performance tests and record execution times")
    parser.add_argument('-d', '--perf_record_dir', type=str, required=True, help='Root folder path to all csv files')
    return parser.parse_args()

def main():
    args = parse_arguments()

    # Define the pattern to match your CSV files
    csv_files = glob.glob(args.perf_record_dir + '/*.csv', recursive=False)
    print(csv_files)

    # Initialize an empty DataFrame
    merged_df = pd.DataFrame()

    # Iterate over the list of CSV files
    for file in csv_files:
        # Read each CSV file into a DataFrame
        df = pd.read_csv(file)
        # Merge the current DataFrame with the accumulated DataFrame
        if merged_df.empty:
            merged_df = df
        else:
            merged_df = pd.merge(merged_df, df, on="Date", how="outer")

    # Save the merged DataFrame to a new CSV file
    merged_df.to_csv("merged.csv", index=False)


if __name__ == "__main__":
    main()

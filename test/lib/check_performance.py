import json
import sys
import argparse

# Define reference thresholds in milliseconds
REFERENCE_THRESHOLDS = {
    "windows": {
        "Hello": 14995,
        "vscode-get-started": 3280
    },
    "linux": {
        "Hello": 9911,
        "vscode-get-started": 1707
    },
    "darwin": {
        "Hello": 12958,
        "vscode-get-started": 2884
    },
    # Add other OS-specific thresholds if needed
}

PERMISSIBLE_LIMIT = 1.10  # Allow +10%


def load_json_file(file_path: str):
    """Load and parse a JSON file."""
    try:
        with open(file_path, "r") as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: File not found - {file_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Failed to parse JSON - {file_path}", file=sys.stderr)
        sys.exit(1)

def compare_performance_results(ref_file, curr_file):
    ref_data = load_json_file(ref_file)
    curr_data = load_json_file(curr_file)

    # Compare results
    errors = []
    for ref, curr in zip(ref_data["results"], curr_data["results"]):
        command = curr_data["command"]
        ref_time = ref["mean"]
        curr_time = curr["mean"]

        if curr_time > ref_time * PERMISSIBLE_LIMIT:
            errors.append(f"⚠️ Performance regression detected in `{command}`: "
                        f"{curr_time:.3f}s (was {ref_time:.3f}s)")
    return errors
    
def compare_performance_results(perf_data):
    """
    Compare performance results against reference thresholds.
    Returns a list of failure messages if any exceed the permissible limit.
    """
    failures = []

    # Open file in write mode once to overwrite previous content
    with open("performance_results.md", "w", encoding="utf-8") as f:
        f.write("# Performance Report\n\n")
        f.write("## Results\n\n")
        f.write("|Test Example|OS Type|Threshold|Duration|Status|\n")
        f.write("|:----:|:----:|:----:|:-----:|:---:|\n")

    # Open file in append mode to avoid overwriting in the loop
    with open("performance_results.md", "a", encoding="utf-8") as f:
        for test in perf_data:
            example = test.get("example", "Unknown Example")
            os_type = test.get("os", "Unknown OS")
            reference_threshold = REFERENCE_THRESHOLDS.get(os_type, {}).get(example)

            if reference_threshold:
                limit = reference_threshold * PERMISSIBLE_LIMIT

                for record in test.get("performance", []):
                    if record.get("tool") == "cbuild" and "setup" in record.get("args", []):
                        time_ms = record.get("time_ms", 0)

                        # Check if performance exceeds threshold
                        if time_ms > limit:
                            failures.append(
                                f"cbuild setup exceeded limit for '{example}' ({os_type}): "
                                f"{time_ms}ms > {limit:.2f}ms (Threshold: {reference_threshold}ms)"
                            )
                            status = "❌"  # Unicode character
                        else:
                            status = "✅"  # Unicode character

                        # Write result to file
                        f.write(f"|{example}|{os_type}|{limit:.2f}ms|{time_ms}ms|{status}|\n")

    return failures


def main():
    parser = argparse.ArgumentParser(description="Compare performance results")
    parser.add_argument("-r", "--reference_data_file", type=str, required=True, help="Path to reference JSON file")
    parser.add_argument("-c", "--current_data_file", type=str, required=True, help="Path to current JSON file")
    args = parser.parse_args()

    ref_data = load_json_file(args.reference_data_file)
    curr_data = load_json_file(args.current_data_file)
    failures = compare_performance_results(ref_data, curr_data)

    if failures:
        print("\n".join(failures))
        sys.exit(1)  # Fail the GitHub job
    else:
        print("All cbuild setup executions are within permissible limits.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        sys.exit(1)

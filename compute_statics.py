"""
Code to compute all descriptive statistics from a file containing numbers. 
The results shall be print on a screen and on a file named StatisticsResults.txt.
"""

import argparse
import time
import pyclasses.read_and_save as rs

def main():
    """Main function to parse arguments, compute statistics, and save results."""
    parser = argparse.ArgumentParser(description="Creata compute descriptive statistics from file.")
    parser.add_argument("filename", help="Path to the file containing numerical data.")
    args = parser.parse_args()
    start_time = time.time()
    numbers = rs.GeneralClass.get_numbers(args.filename)
    results = rs.GeneralClass.get_compute_statistics(numbers)
    execution_time = time.time() - start_time
    if results:
        print("Descriptive Statistics:")
        print(f"Mean: {results[0]}")
        print(f"Median: {results[1]}")
        print(f"Mode: {results[2]}")
        print(f"Standard Deviation: {results[3]}")
        print(f"Variance: {results[4]}")
        print(f"Execution Time: {execution_time:.4f} seconds")
        rs.GeneralClass.save_results(
            "StatisticsResults.txt", results, execution_time, "compute_statics"
            )
    else:
        print("No valid numbers found in the file.")

if __name__ == "__main__":
    main()

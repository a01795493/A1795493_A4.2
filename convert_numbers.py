"""
Code to convert the numbers to binary and hexadecimal base. 
The results shall be print on a screen and on a file named ConvertionResults.txt.
"""

import argparse
import time
import pyclasses.read_and_save as rs

def main():
    """Main function to read numbers from a file and convert them to binary and hexadecimal."""
    parser = argparse.ArgumentParser(description="Convert numbers to binary and hexadecimal.")
    parser.add_argument("filename", help="Path to the file containing numerical data.")
    args = parser.parse_args()
    start_time = time.time()
    numbers = rs.GeneralClass.get_numbers(args.filename)
    results = rs.GeneralClass.get_convertion(numbers)
    execution_time = time.time() - start_time
    if results:
        print("Conversions:")
        for num, binary, hexa in results:
            print(f"{num} -> Binary: {binary}, Hexadecimal: {hexa}")
        print(f"Execution Time: {execution_time:.4f} seconds")
        rs.GeneralClass.save_results(
            "ConvertionResults.txt", results, execution_time, "convert_numbers"
            )
    else:
        print("No valid numbers found in the file.")

if __name__ == "__main__":
    main()

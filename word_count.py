"""
Code to identify all distinct words and the frequency of them 
(how many times the word “X” appears in the file). 
The results shall be print on a screen and on a file named WordCountResults.txt.
"""

import argparse
import time
import pyclasses.read_and_save as rs

def main():
    """Main function to read words from a file and count their frequency."""
    parser = argparse.ArgumentParser(description="Count word frequency in a file.")
    parser.add_argument("filename", help="Path to the file containing text data.")
    args = parser.parse_args()
    start_time = time.time()
    words = rs.GeneralClass.get_words(args.filename)
    word_counts = rs.GeneralClass.get_count_word_freq(words)
    execution_time = time.time() - start_time
    if word_counts:
        print("Word Frequencies:")
        for word, count in sorted(word_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"{word}: {count}")
        print(f"Execution Time: {execution_time:.4f} seconds")
        rs.GeneralClass.save_results(
            "WordCountResults.txt", word_counts, execution_time, "word_count")
    else:
        print("No words found in the file.")

if __name__ == "__main__":
    main()

""""
This module contains a class that reads numbers from a file and saves results to a file.
"""
import re
from collections import defaultdict
class GeneralClass:
    """
    A class to read numbers from a file and save results to a file.
    """
    @staticmethod
    def get_numbers(filename):
        """Reads numbers from a file and returns them as a list."""
        numbers = []
        with open(filename, 'r',  encoding='utf-8') as file:
            for line in file:
                try:
                    numbers.append(int(line.strip()))
                except ValueError:
                    print(f"Invalid data found and skipped: {line.strip()}")
        return numbers
    @staticmethod
    def get_words(filename):
        """Reads words from a file and returns them as a list."""
        words = []
        with open(filename, 'r', encoding='utf-8') as file:
            for line in file:
                words.extend(re.findall(r'\b\w+\b', line.lower()))
        return words
    @staticmethod
    def save_results(filename, results, execution_time, program_name):
        """Function to save the results to a file."""
        with open(filename, 'w', encoding='utf-8') as file:
            if program_name == 'compute_statics':
                file.write("Descriptive Statistics:\n")
                file.write(f"Mean: {results[0]}\n")
                file.write(f"Median: {results[1]}\n")
                file.write(f"Mode: {results[2]}\n")
                file.write(f"Standard Deviation: {results[3]}\n")
                file.write(f"Variance: {results[4]}\n")
                file.write(f"Execution Time: {execution_time:.4f} seconds\n")
            elif program_name == "convert_numbers":
                file.write("Number | Binary | Hexadecimal\n")
                for num, binary, hexa in results:
                    file.write(f"{num} | {binary} | {hexa}\n")
                file.write(f"Execution Time: {execution_time:.4f} seconds\n")
            elif program_name == "word_count":
                file.write("Word | Frequency\n")
                for word, count in sorted(results.items(), key=lambda x: x[1], reverse=True):
                    file.write(f"{word} | {count}\n")
                file.write(f"Execution Time: {execution_time:.4f} seconds\n")
    @staticmethod
    def get_compute_statistics(numbers):
        """Generate descriptive statistics from a list of numbers without using python libraries."""
        if not numbers:
            return None
        mean = sum(numbers) / len(numbers)
        sorted_numbers = sorted(numbers)
        mid = len(sorted_numbers) // 2
        median = (sorted_numbers[mid] if len(numbers) % 2 != 0
                else (sorted_numbers[mid - 1] + sorted_numbers[mid]) / 2)
        frequency = {}
        for num in numbers:
            frequency[num] = frequency.get(num, 0) + 1
        mode = max(frequency, key=frequency.get)
        variance = sum((x - mean) ** 2 for x in numbers) / len(numbers)
        std_dev = variance ** 0.5
        return mean, median, mode, std_dev, variance
    @staticmethod
    def get_convertion(numbers):
        """Converts numbers to binary and hexadecimal representations."""
        conversions = [(num, bin(num)[2:], hex(num)[2:]) for num in numbers]
        return conversions
    @staticmethod
    def get_count_word_freq(words):
        """Counts the frequency of each distinct word."""
        frequency = defaultdict(int)
        for word in words:
            frequency[word] += 1
        return frequency
    
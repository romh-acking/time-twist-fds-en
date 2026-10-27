import sys
import re
from collections import Counter

def sortByFrequency(strings, writing_file):
    with open(writing_file, "r", encoding="utf-8") as file:
        writing = file.read().lower()

    counts = {
        string: writing.count(string.lower())
        for string in strings
    }

    return sorted(
        strings,
        key=lambda string: counts[string],
        reverse=True,
    )

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <script-file>")
        sys.exit(1)

    print("Input dictionary")
    # Read multiple lines until an empty line is entered
    strings = []

    while True:
        line = input()
        if line == "":
            break
        line = line.replace("(STOP)", "")
        strings.append(line)

    result = sortByFrequency(strings, sys.argv[1])

    with open("out.txt", "w", encoding="utf-8") as file:
        file.write("(STOP)\n".join(result))
        file.write("(STOP)")

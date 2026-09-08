import re

CHAR_LENGTH = 8

def hexToDec(hex):
    hex = hex.replace("{", "").replace("}", "")
    return int("0x" + hex, 0)

def getWordLength(word):
    wordLength = 0
    for char in filter(None,  re.split("(\[.*?\])|(\(.*?\))|(.)",  word)):
        charLength = 0
        if not char.startswith("("):
            charLength = CHAR_LENGTH
        wordLength += charLength
    return wordLength
    
def main():
    print("Paste your line below.")

    # Read multiple lines until an empty line is entered
    data = ''
    while not data:
        data = input()

    chunks = re.split("(\(.*?\))|(\s+(?![^\(]*\))(?![^\[]*\]))|({.*?})|(\<.*?\>)", data)
    chunks = [x for x in chunks if x != '' and x != None]

    iii = 0
    maxLineLength = 24*8
    lineLength = 0
    newLine = ""
    lineNumber = 0

    while iii < len(chunks):
        word = chunks[iii]

        if word == "(LINE)":
            if lineNumber == 3:
                word = "(SCROLL)"
                lineNumber -= 2
                
            newLine += word
            iii += 1
            lineLength = 0
            lineNumber += 1
            continue

        if word == " " and lineLength == 0:
            iii += 1
            continue
            
        wordLength = getWordLength(word)

        if lineLength + wordLength < maxLineLength:
            lineLength += wordLength
            newLine += word
            iii += 1
            continue

        if (newLine.endswith(" ")):
            newLine = newLine.strip()
            lineLength -= CHAR_LENGTH

        if lineNumber == 3:
            newLine += "(SCROLL)"
            lineNumber -= 2
        else:
            newLine += "(LINE)"

        lineNumber += 1
        lineLength = 0

    with open("out.txt", "w") as file:
        file.write(newLine)

    return

main()

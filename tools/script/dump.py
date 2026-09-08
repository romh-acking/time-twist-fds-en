import getopt
import sys
import math
import os
import json

FILE_RAM_LOCATION = 0xA200
LABEL_DICTIONARY = 0x16

global byte_data
global bits
global dictionary
global customLabel
global ramFileWriteOrder
global outputOutOfBoundMetadata
global fileOutOfBounds

dictionary = {}
addressCache = {}
textSegmentPointer = []
externalPointerMetadata = {}

hardcodedPointers = {
    0x002E,
    0x0030,
}

STRING_9 = "＿・\"—おがぎぐげござじずぜぞだぢづでどなにぬねのばびぶべぼ゛゜ぱぴぷぺぽぁぃぅぇぉっゃゅょ1234567890ー！？」「‥♡　"
STRING_6 = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん、。"

def generateLocationComment(fileAddress):
    return f"// File Address: 0x{fileAddress:04X}; RAM Address: 0x{FILE_RAM_LOCATION+fileAddress:04X}"

def generateLabel(labelFile, pointerLocation):
    return f"Label_{labelFile}_0x{pointerLocation:04X}"

def generatePointerTag(pointerFile, label):
    return f'<Pointer file="{pointerFile}" id="{label}">'

def readPointer(addr):
    start = (byte_data[addr + 1] << 8 | byte_data[addr]) - FILE_RAM_LOCATION

    return start * 8

def decToHex(int):
    return f'{{0x{int:02X}}}'


def dump(filename, textPointer=[], embeddedTextpointer=[], attempt=0):

    script = ''

    i = 0xFFFF

    addresses = {}

    script += f'// Pointer table (0x32 bytes)\n'

    for key in range(0x00, 0x32, 2):
        p = readPointer(key)

        if p <= 0:
            script += f'{decToHex(byte_data[key + 0])}{decToHex(byte_data[key + 1])}\n'
            continue

        if p // 8 > len(byte_data):
            label = generateLabel(filename, key)
            tag = generatePointerTag(fileOutOfBounds, label)

            script += f'{tag}\n'

            address = f"0x{p//8:04X}"

            if fileOutOfBounds not in externalPointerMetadata:
                externalPointerMetadata[fileOutOfBounds] = {}

            if not address in externalPointerMetadata[fileOutOfBounds]:
                externalPointerMetadata[fileOutOfBounds][address] = []
            
            if label not in externalPointerMetadata[fileOutOfBounds][address]:
                externalPointerMetadata[fileOutOfBounds][address].append(label)
                
            continue

        tag = generatePointerTag(filename, generateLabel(filename, key))
        script += f'{tag}\n'

        if attempt == 0:
            if p not in addresses:
                addresses[p] = []
                addressCache[p] = []

            addresses[p].append(key)
                
            if key not in addressCache[p]:
                addressCache[p].append(key)

    for key in addressCache:
        i = min(i, key)

    if i < 0:
        raise "i cannot be less than zero"

    dialogueId = 1

    currentLabelId = -1
    labelStartPointerRead = False
    while i < len(bits):
        a = i // 8

        if a == 0x2b9b or a == 0x2b95:
            print()

        # Internal pointer handling for screen transition (START)
        # 9E8A  LDA ($3C),Y
        if a == 0x000025DB and filename == '00.dkb':
            addr = readPointer(a)

            tag = generatePointerTag(filename, generateLabel(filename, a))

            script += f'\n{tag}\n'

            if addr not in addressCache:
                addressCache[addr] = []
                addressCache[addr].append(a)

            i += 16
            continue

        # Internal pointer handling for screen transition (END)

        temp = {}

        if not (i % 8 == 1 and bits[i:].startswith("1111")):
            if attempt == 0:
                temp = addresses
            else:
                temp = addressCache

            match = math.ceil(i / 8) * 8

            if match in temp:
                script += f"\n{generateLocationComment(i//8)}"

                for pointerId in temp[match]:
                    if i % 8 != 0:
                        while i % 8:
                            i += 1
                    
                    script += f"\n{generateLabel(filename, pointerId)}:\n"

                    currentLabelId = pointerId
                    labelStartPointerRead = False
                    dialogueId = 1

                del temp[match]

            if filename in externalPointerMetadata:
                entry = externalPointerMetadata[filename]
                match = f'0x{match//8:04X}'
                if match in entry:
                    script += f"\n{generateLocationComment(i//8)}"
                    for label in entry[match]:
                        script += f"\n{label}:\n"

            if not labelStartPointerRead and pointerId in hardcodedPointers:
                a = i // 8
                addr = readPointer(a) // 8

                labelStartPointerRead = True
                if addr > 0:
                    f = filename
                    if addr > len(byte_data):
                        f = fileOutOfBounds

                    label = generateLabel(filename, a)
                    tag = generatePointerTag(f, label)

                    script += f'\n{tag}\n'

                    if addr < len(byte_data):
                        if addr*8 not in addressCache:
                            addressCache[addr*8] = []
                            addressCache[addr*8].append(a)
                    else:
                        address = f"0x{addr:04X}"

                        if not f in externalPointerMetadata:
                            externalPointerMetadata[f] = {}

                        if not address in externalPointerMetadata[f]:
                            externalPointerMetadata[f][address] = []

                        if label not in externalPointerMetadata[f][address]:
                            externalPointerMetadata[f][address].append(label)
                    
                    i += 16
                    continue

        isStop = False
        text = ''

        if (currentLabelId not in textPointer and currentLabelId not in embeddedTextpointer and currentLabelId not in textSegmentPointer):
            aaa = int(bits[i:i+8], 2)
            text = f"{{0x{aaa:02X}}}"
            i += 8
        elif (currentLabelId in embeddedTextpointer):
            a = i // 8
            addr = readPointer(a)
            tag = generatePointerTag(filename, generateLabel(filename, a))
            script += f'\n{tag}\n'

            if addr not in addressCache:
                addressCache[addr] = []

            textSegmentPointer.append(a)

            if a not in addressCache[addr]:
                addressCache[addr].append(a)
            
            i += 16
            continue
        elif bits[i:].startswith("1111"):  # 7-bit
            code = int(bits[i+4:i+7], 2)
            i += 7
            if code == 0:
                text = "(LINE)"
            elif code == 1:
                text = "(WAIT #1)"
            elif code == 2:
                text = "(WAIT #2)"
            elif code == 3:
                text = "(WAIT SCROLL)"
            elif code == 4:
                text = "(SCROLL)"
            elif code == 5:
                text = "(STOP)\n"
                while i % 8:
                    i += 1
                print(
                    end=f"Current address: File: {i // 8:04X}; RAM: {i // 8 + FILE_RAM_LOCATION:04X}\n")
                isStop = True
                dialogueId = dialogueId + 1
            elif code == 6:
                text = "(WAIT #3)"
            elif code == 7:
                text = "(FLAG 07)"
        elif bits[i:].startswith("1110"):  # 9-bit
            code = int(bits[i+4:i+9], 2)

            if code in dictionary:
                text = dictionary[code]
            else:
                text = f"(Dict {{{code}}})"
            i += 9
        elif bits[i:].startswith("110"):  # 9-bit
            code = int(bits[i+3:i+9], 2)
            i += 9
            text = STRING_9[code]

        else:  # 6-bit
            code = int(bits[i:i+6], 2)
            text = STRING_6[code]
            i += 6

        if (currentLabelId == LABEL_DICTIONARY) and not isStop:
            if dialogueId not in dictionary:
                dictionary[dialogueId] = ''
            dictionary[dialogueId] += text

        # print(end=text)
        script += text

    return script


def main():
    options = "iodt:"
    long_options = ["input=", "output=", "textPointer=",
                    "externalPointerMetadata=", "fileOutOfBounds=",
                    "embeddedTextpointer="]
    argumentList = sys.argv[1:]

    inputFilePath = ""
    outputFilePath = ""
    textPointer = []
    embeddedTextPointer = []
    externalPointerMetadataFile = ''

    global externalPointerMetadata
    global fileOutOfBounds

    try:
        # Parsing argument
        arguments, _ = getopt.getopt(argumentList, options, long_options)

        # checking each argument
        for currentArgument, currentValue in arguments:
            if currentArgument in ("-i", "--input"):
                inputFilePath = currentValue
            elif currentArgument in ("-o", "--output"):
                outputFilePath = currentValue
            elif currentArgument in ("--textPointer",):
                textPointer = [int(x, 16) for x in currentValue.split(",")]
            elif currentArgument in ("--externalPointerMetadata"):
                externalPointerMetadataFile = currentValue
            elif currentArgument in ("--fileOutOfBounds"):
                fileOutOfBounds = currentValue
            elif currentArgument in ("--embeddedTextpointer"):
                embeddedTextPointer = [int(x, 16) for x in currentValue.split(",")]

    except getopt.error as err:
        print(str(err))

    global byte_data
    with open(inputFilePath, 'rb') as file:
        byte_data = file.read()

    global bits
    bits = ''.join(f"{b:08b}" for b in byte_data)

    # 0x14: Menu commands
    # 0x16: Dictionary

    filename = os.path.basename(inputFilePath)

    if os.path.exists(externalPointerMetadataFile):
        with open(externalPointerMetadataFile, 'r') as file:
             externalPointerMetadata = json.load(file)

    dump(filename, textPointer, embeddedTextPointer, 0)
    script = dump(filename, textPointer, embeddedTextPointer, 1)

    with open(outputFilePath, 'w', encoding="utf-8") as file:
        file.write(script)

    with open(externalPointerMetadataFile, 'w') as file:
        json.dump(externalPointerMetadata, file, indent=4)


main()

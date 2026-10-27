import getopt
import sys
import math
import os
import json

FILE_RAM_LOCATION_START = 0xA200

MAIN_POINTER_TABLE_SIZE = 0x32
LABEL_DICTIONARY = 0x16
LABEL_SCRIPT_POINTER = 0x20

SCRIPTING_LANGUAGE_POINTER_ID = 0x06

global byte_data
global bits
global dictionary
global customLabel
global ramFileWriteOrder
global outputOutOfBoundMetadata
global fileOutOfBounds

global textPointer
global embeddedTextPointer
global embeddedPointer

dictionary = {}
addressCache = {}
externalPointerMetadata = {}

segmentPointer = []
textSegmentPointer = []

textPointer = []
embeddedTextPointer = []
embeddedPointer = []

scriptLanguagePointer = []

hardcodedPointers = {
    0x002E,
    0x0030,
}

STRING_9 = "＿・\"—おがぎぐげござじずぜぞだぢづでどなにぬねのばびぶべぼ゛゜ぱぴぷぺぽぁぃぅぇぉっゃゅょ1234567890ー！？」「‥♡　"
STRING_6 = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん、。"

def isListInList(list1, list2):
    for item in list1:
        if item in list2:
            return True
    return False

def generateLocationComment(fileAddress):
    return f"// File Address: 0x{fileAddress:04X}; RAM Address: 0x{FILE_RAM_LOCATION_START+fileAddress:04X}"

def generateLabel(labelFile, pointerLocation):
    if labelFile == "":
        raise Exception(f"File cannot be empty: {labelFile}")

    return f"Label_{labelFile}_0x{pointerLocation:04X}"

def generatePointerTag(pointerFile, label):
    if pointerFile == "":
        raise Exception(f"File cannot be empty: {pointerFile}")
        
    return f'<Pointer file="{pointerFile}" id="{label}">'

def readPointer(addr):
    start = (byte_data[addr + 1] << 8 | byte_data[addr]) - FILE_RAM_LOCATION_START

    return start * 8

def decToHex(int):
    return f'{{0x{int:02X}}}'

def dump(filename, attempt=0):

    script = ''
    scriptPointerTableStart = -1

    i = 0xFFFF

    addresses = {}

    script += f'// Pointer table (0x32 bytes)\n'

    for key in range(0x00, MAIN_POINTER_TABLE_SIZE, 2):
        p = readPointer(key)

        if p <= 0:
            script += f'{decToHex(byte_data[key + 0])}{decToHex(byte_data[key + 1])}\n'
            continue

        if key == LABEL_SCRIPT_POINTER:
            scriptPointerTableStart = p//8

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
        raise Exception("i cannot be less than zero")

    dialogueId = 1

    currentLabelId = []
    currentMainLabelId = []
    labelStartPointerRead = False

    #externalPointerMetadata={}
    #script=""
    #bits = ''.join(f"{b:08b}" for b in [0x2F,0x33,0x30,0xFE,0x37,0xFB,0xF1,0x1E,0x40,0x7C,0x79,0x40,0xFD,0x0F,0x71,0xBF,0x9A,0x03,0x77,0x19,0xBF,0x19,0xAD,0xC6,0xFF,0x24,0x60,0xE6,0xEE,0x33,0x7E,0x0D,0xA3,0x7E,0x36,0xAE,0xD3,0x68,0xFA,0xC9,0x69,0x8C,0x1C,0xDD,0xC6,0x6F,0xC1,0x69,0xD0,0x2C,0xCC,0x7D,0x3C,0x04,0x53,0xB6,0x3F,0xA0,0x24,0x27,0x2D,0x63,0xE8,0xF0,0x1E,0xE2,0x1B,0x6C,0xFA,0xF1,0x9A,0xDC,0x43,0x6D,0x9F,0x40,0xF1,0xE0,0xDD,0x52,0x65,0xA4,0x3E,0x3C,0xA0,0x7E,0x80,0xFA,0x2F,0x5A,0x13,0x38,0xB8,0x7E,0x80,0xFA,0xFA,0xC9,0x69,0x8C,0x1E,0xE4,0xE6,0xCD,0xD1,0xF4,0x13,0x3A,0x1D,0x1F,0x40,0x37,0x71,0x9B,0xFA,0x12,0x20,0x71,0xE6,0x7D,0x28,0x12,0xF5,0xA2,0xCD,0xF4,0xAB,0x71,0x93])
    #i = 0
    #pointerId = -1
    #currentLabelId = []
    #textSegmentPointer= {-1: ""}
    #addresses={}
    #externalPointerMetadata={}

    while i < len(bits):
        a = i // 8

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
                currentLabelId = []
                currentMainLabelIdTemp = []

                if match not in scriptLanguagePointer:
                    script += f"\n{generateLocationComment(i//8)}"

                for pointerId in temp[match]:
                    if i % 8 != 0:
                        while i % 8:
                            i += 1

                    label = generateLabel(filename, pointerId)
                    if match not in scriptLanguagePointer:
                        script += f"\n{label}:\n"
                    else:
                        script += f"{label}:"

                    currentLabelId.append(pointerId)

                    if pointerId < MAIN_POINTER_TABLE_SIZE:
                        currentMainLabelIdTemp.append(pointerId)
                        
                    labelStartPointerRead = False
                    dialogueId = 1

                del temp[match]
            
            if len(currentMainLabelIdTemp) > 0:
                currentMainLabelId = currentMainLabelIdTemp

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

        if (not isListInList(currentLabelId, textPointer) and 
            not isListInList(currentLabelId, embeddedTextPointer) and 
            not isListInList(currentLabelId, embeddedPointer) and 
            not isListInList(currentLabelId, textSegmentPointer)):
            aaa = int(bits[i:i+8], 2)

            if SCRIPTING_LANGUAGE_POINTER_ID in currentMainLabelId:
                def readGroupPointer(id, isGroup, argCount):
                    tempI = i
                    
                    extractedId = []

                    for _ in range(0,len(id)):
                        extractedId.append(int(bits[tempI:tempI+8], 2))
                        tempI += 8
                    
                    if not extractedId == id:
                        return

                    pointerCount = 0

                    text = ""
                    for a in extractedId:
                        text += f"{{0x{a:02X}}}"

                    while argCount != 0:
                        aaa = int(bits[tempI:tempI+8], 2)
                        text += f"{{0x{aaa:02X}}}"
                        tempI += 8
                        argCount -= 1

                    while True:
                        a = tempI // 8
                        addr = readPointer(a)

                        # Arbitrary upper limit
                        if addr // 8 < 0 or addr // 8 > scriptPointerTableStart:
                            break

                        if addr not in addressCache:
                            addressCache[addr] = []

                        if a not in addressCache[addr]:
                            addressCache[addr].append(a)
            
                        if addr not in scriptLanguagePointer:
                            scriptLanguagePointer.append(addr)

                        tag = generatePointerTag(filename, generateLabel(filename, a))
                        text += tag
                        
                        tempI += 16
                        pointerCount += 1

                        if not isGroup:
                            break
                    
                    if pointerCount == 0:
                        return

                    return {"text": text, "tempI": tempI, "pointerCount": pointerCount}

                retVal = readGroupPointer([0x30], True, 0)
                
                for args in (
                    ([0x40], True, 4),
                    ([0x40, 0x73], True, 4),
                    ([0x40, 0x76], True, 9),
                    ([0x41], False, 1),

                    # Branching if
                    ([0x49], False, 1), 
                    ([0x4A], False, 1),

                    ([0x50], False, 0),
                    ([0x54], False, 0),
                    ([0x77], False, 6)
                ):
                    if retVal:
                        break
                    retVal = readGroupPointer(*args)
                
                if retVal and retVal["pointerCount"] > 0:
                    script += retVal["text"]
                    i = retVal["tempI"]
                    continue

            text = f"{{0x{aaa:02X}}}"
            i += 8
        elif (isListInList(currentLabelId, embeddedPointer)):
            a = i // 8
            addr = readPointer(a)
            tag = generatePointerTag(filename, generateLabel(filename, a))
            script += f'\n{tag}\n'

            if addr not in addressCache:
                addressCache[addr] = []

            if a not in addressCache[addr]:
                addressCache[addr].append(a)
            
            i += 16
            continue
        elif (isListInList(currentLabelId, embeddedTextPointer)):
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
                text = f"(Dict {code})"
            i += 9
        elif bits[i:].startswith("110"):  # 9-bit
            code = int(bits[i+3:i+9], 2)
            i += 9
            text = STRING_9[code]

        else:  # 6-bit
            code = int(bits[i:i+6], 2)
            text = STRING_6[code]
            i += 6

        if (LABEL_DICTIONARY in currentLabelId) and not isStop:
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
                    "embeddedTextPointer=", "embeddedPointer=", "dictionary="]
    argumentList = sys.argv[1:]

    inputFilePath = ""
    outputFilePath = ""
    externalPointerMetadataFile = ''

    global externalPointerMetadata
    global fileOutOfBounds

    global embeddedTextPointer
    global textPointer
    global embeddedPointer

    fileOutOfBounds = ""

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
            elif currentArgument in ("--embeddedTextPointer"):
                embeddedTextPointer = [int(x, 16) for x in currentValue.split(",")]
            elif currentArgument in ("--embeddedPointer"):
                embeddedPointer = [int(x, 16) for x in currentValue.split(",")]

    except getopt.error as err:
        raise Exception(err)

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

    dump(filename, 0)
    script = dump(filename, 1)

    with open(outputFilePath, 'w', encoding="utf-8") as file:
        file.write(script)

    with open(externalPointerMetadataFile, 'w') as file:
        json.dump(externalPointerMetadata, file, indent=4)


main()

import getopt
import sys
import re
import os
import json

STOP_CODE = 5

FILE_RAM_LOCATION = 0xA200
LABEL_DICTIONARY = 0x16

CHARSET_9 = "＿・\"—おがぎぐげござじずぜぞだぢづでどなにぬねのばびぶべぼ゛゜ぱぴぷぺぽぁぃぅぇぉっゃゅょ1234567890ー！？」「‥♡　"
CHARSET_6 = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん、。"

CHARSET_EN_9 = "＿・\"—おがぎぐげござじずぜぞだぢづでどなにぬねのばびぶべぼ゛゜ぱぴぷぺぽぁぃぅぇぉっゃゅょ1234567890ー!?」「‥♡ "
CHARSET_EN_6 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:'まみむめもやゆよらりるれろわをん、。"

script = ''
bits = ''
dictionary = {}

global externalPointerMetadata
externalPointerMetadata = {}

def parse_bool(value):
    return value.strip().lower() == "true"

def hexToBits(hex_str):
    return bin(int(hex_str, 16))[2:].zfill(len(hex_str) * 4)

def intToBitsWithPadding(val, padding):
    return bin(val)[2:].zfill(padding)

def bitToHex(bit_str):
    while len(bit_str) % 8:
        bit_str += '0'

    integer_value = int(bit_str, 2)

    num_bytes = len(bit_str) // 8

    hex_string = f"{integer_value:0{num_bytes * 2}X}"
    return hex_string

def hexStringToIntArray(hex_str):
    return [int(hex_str[i:i+2], 16) for i in range(0, len(hex_str), 2)]


def padByte(i):
    global bits
    
    if i % 8 != 0:
        while i % 8:
            bits += '0'
            i += 1
    return i

def replaceDictValues(match):
    block = match.group(1)

    for key, value in dictionary.items():
        pattern = re.compile(re.escape(value), re.IGNORECASE)
        block = pattern.sub(f"(Dict {key})", block)

    return block 

def write(script, filename, dryRun, fixedData, isFirstRun):
    global bits

    pointerLocation = {}

    dialogueId = 1
    i = 0x0
    dictionaryBuffer = ''
    labelId = -1

    splitted = re.split(fr"(Label_[0-9]+\.dk[a-z]_0x{LABEL_DICTIONARY:04X}\:)", script)

    if len(splitted) == 3:
        global dictionary

        # Process every block beginning after \n and ending before (STOP)
        splitted[0] = re.sub(
            r"(?<=\n)(.*?)(?=\(STOP\))",
            replaceDictValues,
            splitted[0],
        )

    script = splitted[0] + splitted[1] + splitted[2]
    script = re.sub(r"//.*?\n", "", script)
    script = script.replace("\n", "", -1)

    split = list(filter(None, re.split(
        r"(Label_.*?:|<.*?>|{.*?}|\(.*?\)|[\u3040-\u309F\u30A0-\u30FF0-9‥A-Za-z\"！？　 ,.?!])", script)))

    for a in split:
        if a.startswith("<Pointer"):
            i = padByte(i)

            match = re.match(r'<Pointer file="(.*?) id="(.*?)">', a)
            #file = match.group(1)
            label = match.group(2)

            pointerLocation[i // 8] = label

            bits += '1111111111111111'
            i += 16
        elif a.startswith("Label_"):
            dialogueId = 1
            dictionaryBuffer = ''
            i = padByte(i)

            label = re.match(r'(Label_.*?):', a).group(1)
            match = re.match(r"Label_(.*?)_(.*?):", a)
            #file = match.group(1)
            hexVal = match.group(2)
 
            # First run won't have the dictionary and is therefore inaccurate
            if label in fixedData and not isFirstRun:
                addr = fixedData[label] * 8

                if i > addr:
                    raise ValueError(f"fixed label out of range: {label}; {hex(i//8)} > {hex(addr//8)}")


                while i != addr:
                    if i > addr:
                        raise f"{i} > {addr}"

                    bits += '1111'
                    bits += intToBitsWithPadding(STOP_CODE, 3)
                    i += 7
                    i = padByte(i)
                
            externalPointerMetadata[label] = f"0x{i // 8:04X}"
            labelId = int(hexVal, 16)

        elif a.startswith("{"):
            dictionaryBuffer = ''
            hexVal = re.match(r"{0x(.*?)}", a).group(1)
            bits += hexToBits(hexVal)
            i += 8
        elif a.startswith("(Dict "):  # 9-bit
            bits += '1110'
            val = int(re.match(r"\(Dict (.*?)\)", a).group(1))
            bits += intToBitsWithPadding(val, 5)
            i += 9
        elif a.startswith("("):  # 7-bit
            bits += '1111'

            code = 0
            isStop = False
            if a == "(LINE)":
                code = 0
            elif a == "(WAIT #1)":
                code = 1
            elif a == "(WAIT #2)":
                code = 2
            elif a == "(WAIT SCROLL)":
                code = 3
            elif a == "(SCROLL)":
                code = 4
            elif a == "(STOP)":
                if dictionaryBuffer != '':
                    dictionary[dialogueId] = dictionaryBuffer
                code = STOP_CODE
                dialogueId = dialogueId + 1
                isStop = True
            elif a == "(WAIT #3)":
                code = 6
            elif a == "(FLAG 07)":
                code = 7
            else:
                assert Exception("Invalid control code.")

            bits += intToBitsWithPadding(code, 3)
            i += 7

            if isStop:
                if i % 8 != 0:
                    while i % 8:
                        bits += '0'
                        i += 1
                
            dictionaryBuffer = ''
        else:
            if labelId == 0x16:
                dictionaryBuffer += a

            a = a.upper()

            if re.search(rf"([{CHARSET_6}])", a):
                index = CHARSET_6.index(a)
                bits += intToBitsWithPadding(index, 6)
                i += 6
            elif re.search(rf"([{CHARSET_9}])", a):
                index = CHARSET_9.index(a)
                bits += '110'
                bits += intToBitsWithPadding(index, 6)
                i += 9
            elif re.search(rf"([{CHARSET_EN_6}])", a):
                index = CHARSET_EN_6.index(a)
                bits += intToBitsWithPadding(index, 6)
                i += 6
            elif re.search(rf"([{CHARSET_EN_9}])", a):
                index = CHARSET_EN_9.index(a)
                bits += '110'
                bits += intToBitsWithPadding(index, 6)
                i += 9

    hhh = hexStringToIntArray(bitToHex(bits))

    if not dryRun:
        for key in pointerLocation:
            label = pointerLocation[key]

            localAddr = 0
            if label in externalPointerMetadata:
                localAddr = int(externalPointerMetadata[label], 16)
            else:
                raise ValueError(f'Not found: {label}')

            laloc = localAddr + FILE_RAM_LOCATION
            
            hhh[key + 0] = laloc & 0xFF
            hhh[key + 1] = (laloc & 0xFF00) >> 8

    return hhh

def main():
    options = "io:"
    long_options = [
        "input=", 
        "output=", 
        "externalPointerMetadata=",
        "dryRun=",
        "fixedData=",
    ]
    argumentList = sys.argv[1:]

    inputFilePath = ""
    outputFilePath = ""
    externalPointerMetadataFile = ""
    dryRun = False
    fixedData = {}

    global externalPointerMetadata

    try:
        # Parsing argument
        arguments, _ = getopt.getopt(argumentList, options, long_options)

        # checking each argument
        for currentArgument, currentValue in arguments:
            if currentArgument in ("-i", "--input"):
                inputFilePath = currentValue
            elif currentArgument in ("-o", "--output"):
                outputFilePath = currentValue
            elif currentArgument in ("--externalPointerMetadata"):
                externalPointerMetadataFile = currentValue
            # Dry runs allow us to build up pointer metadata
            elif currentArgument in ("--dryRun"):
                dryRun = parse_bool(currentValue)
            elif currentArgument in ("--fixedData"):
                split = currentValue.split(",")

                for i in range(0, len(split), 2):
                    addr = split[i + 1]
                    fixedData[split[i]] = int(addr, 16)
                 
    except getopt.error as err:
        print(str(err))
        exit()

    if os.path.exists(externalPointerMetadataFile):
        with open(externalPointerMetadataFile, 'r') as file:
             externalPointerMetadata = json.load(file)

    script = ''
    with open(inputFilePath, 'r', encoding='utf-8') as file:
        script = file.read()
    
    filename = os.path.basename(inputFilePath).replace(".txt", "", -1)

    write(script, filename, dryRun, fixedData, True)
    global bits
    bits = ''
    out = write(script, filename, dryRun, fixedData, False)

    if not dryRun:
        with open(outputFilePath, 'wb') as file:
            file.write(bytes(out))

    with open(externalPointerMetadataFile, 'w') as file:
        json.dump(externalPointerMetadata, file, indent=4)

main()

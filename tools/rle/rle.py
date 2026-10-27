import getopt
import sys

RLECode = 0xc0

def rle_compress(data: bytes) -> bytes:
    if not data:
        return b''

    compressed = bytearray()
    prev_byte = data[0]
    count = 1

    for byte in data[1:]:
        if byte == prev_byte and count < 0x3E:
            count += 1
        else:
            if count > 2:
                compressed.extend([RLECode + count, prev_byte])
            else:
                if prev_byte >= RLECode:
                    compressed.extend([RLECode + count, prev_byte])
                elif count == 2:
                    compressed.extend([prev_byte, prev_byte])
                else:
                    compressed.extend([prev_byte])

            prev_byte = byte
            count = 1

    if count > 1:
        compressed.extend([RLECode + count, prev_byte])
    else:
        compressed.extend([prev_byte])

    compressed.extend([0xFF])

    return bytes(compressed)

def main():
    options = ""
    long_options = ["input=", "output="]
    argumentList = sys.argv[1:]

    input = []
    output = []

    try:
        # Parsing argument
        arguments, _ = getopt.getopt(argumentList, options, long_options)

        # checking each argument
        for currentArgument, currentValue in arguments:
            if currentArgument in ("--input"):
                input = currentValue
            elif currentArgument in ("--output"):
                output = currentValue

    except getopt.error as err:
        print(str(err))

    # Read binary file
    with open(input, 'rb') as f:
        original_data = f.read()

    # Compress using RLE
    compressed_data = rle_compress(original_data)

    # Save compressed output
    with open(output, 'wb') as f:
        f.write(compressed_data)

    print("Compression complete.")

main()
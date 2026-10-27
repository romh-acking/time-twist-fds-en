import json
from enum import Enum

class DiskSide(str, Enum):
    A = 0
    B = 1
    C = 2
    D = 3

filename = "./disks/fileInfo.json"

with open(filename, "r", encoding="utf-8") as file:
    diskContent = json.load(file)

item = {
      "FileNumber": 9,
      "FileID": 72,
      "FileName": "TT4B\u0000\u0000\u0000\u0000",
      "FileAddress": "0xA200",
      "FileSize": hex(len(diskContent)),
      "FileType": "0x00",
      "PCAddressStart": "0x0"
    }
    
diskContent[int(DiskSide.D.value)].append(item)

with open(filename, "w", encoding="utf-8") as file:
    file.writelines(json.dumps(diskContent, indent=2))
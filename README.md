# Time Twist - Translation Project

![](1.png)
![](2.png)

This GitHub project contains all the tools you need to get started on your translation project of Time Twist.

Unlike other translation attempts and tools for the game, AI was *not* used to create the tools inside of this project.

## Project state
* Menu options have been expanded, to fit longer strings such as calendar month names.
* Text for the intro has been inserted (`01.dkb.txt`) as a proof of concept.
* The translation from this repository was used and can be used to continue this project:
  * [Dialogue strings](https://github.com/sudgy/nintendo_translations/blob/master/time_twist_messages.txt)
  * [Menu options](https://github.com/sudgy/nintendo_translations/blob/master/time_twist_options.txt)

The biggest hurdle will be handling the space limitations of the big disk files (e.g. `00.dkb`). These contain sections of assembly code that cannot be moved. Using the dictionary table (pointer `0x16`) only helps so much. Perhaps the `STRING_9` charset could be repurposed to expand the dictionary.

The game used multiple control codes such as `(WAIT #1)`, `(WAIT SCROLL)`, and `(SCROLL)` to adjust how text is displayed. In fact, there is a wait control code to support resuming from each line. Using the single line hack, the wait control codes cannot be used to the fullest capacity because they don't support 7 lines. 

## Compilation Instructions
The tools are coded in C#. You'll have to mess with Wine or mono if you want them to run in Linux. You'll also have to rewrite the bat files.

Include the game's two disk image files in the roms folder:
* `Time Twist - Rekishi no Katasume de... - Zenpen (1991)(Pax Softnica-Nintendo).fds`
  * First disk (you boot from this)
* `Time Twist - Rekishi no Katasume de... - Kouhen (1991)(Pax Softnica-Nintendo).fds`
  * Second disk (will return an error screen if you attempt to boot from this)

The bat files:
* If you want to dump the script for whatever reason, you can dump it by executing the bat file `Dump.bat` by double clicking it.
* To generate an FDS file with the translation, execute the bat file `Write.bat` by double clicking it.

If the disk utility returns an error, you probably have a bad dump with junk data on the disk. For the second disk, data after `0xC69B` and `0x1C5CF` should be zero. Data after these addresses are junk that should be blanked.

## Tools
* `fdsBuilder/FDSBuilderC-Sharp.exe`
  * Used to extract and insert files into the fds disk image file
* `script/dump.py`
  * Converts the decompresses the game's script files
  * Arguments:
    * `input`
      * Input disk image file
    * `output`
      * Output `.txt` file
    * `textPointer`
      * The compressed script files have 25 pointers at the top. The ids passed here indicate which pointers are text pointers
    * `externalPointerMetadata`
      * The location of the externalPointerMetadata file.
      * This keeps the pointers in sync across the many script files, as they cross reference each other.
    * `fileOutOfBounds`
      * In the game, a main file will be written. Afterwards, subsequent (smaller) files will be written on top of it, while also referencing data and code from the non-overwritten parts. To accommodate this scenario, this argument indicates what file is to be read when reading outside of the current file's boundaries. 
    * `embeddedTextPointer`
      * The game has multiple bitstreams of text information. These are broken up to save time because every time a line is read, the bitstreams are iterated over. This argument indicates which pointer ids (at the top of the file) are text pointer tables.
* `script/line.py`
  * A tool that formats lines and inserts linebreaks and scroll control codes for you.
* `script/write.py`
    * `input`
      * Input `.txt` file
    * `output`
      * Output disk image file
    * `externalPointerMetadata`
      * The location of the externalPointerMetadata file.
      * This keeps the pointers in sync across the many script files, as they cross reference each other.
    * `dryRun`
      * When set to `true`, an output file will not be created.
      * A dry run is used for building up the `externalPointerMetadata` file.
    * `fixedData`
      * Defines which labels are fixed to what location.
      * Assembly code is stored in certain script files and cannot be moved without disassembling the code.

## Etc
The folder `zzz_extras` contains table files for a debug emulator's RAM viewer. This allows you to see text in the game's text buffer at `0x8747`. Simply load the table files in the memory viewer and jump to the address.

## Credit
* Tooling: FCC
* Translation: sudgy

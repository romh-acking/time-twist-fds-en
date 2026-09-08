::Folders
set projectFolder=%cd%

::Roms
set baseImage1=roms\Time Twist - Rekishi no Katasume de... - Zenpen (1991)(Pax Softnica-Nintendo).fds
set baseImage2=roms\Time Twist - Rekishi no Katasume de... - Kouhen (1991)(Pax Softnica-Nintendo).fds
set baseImageMerged=roms\Time Twist.fds
set FDSBuilderFolder=%projectFolder%\tools\fdsBuilder
set scriptDumper=%projectFolder%\tools\script\dump.py
set scriptFolder=%projectFolder%\script
set diskDirectory=%projectFolder%\disks

cd "%projectFolder%"

copy /b "%baseImage1%" + "%baseImage2%" "%baseImageMerged%"

::Extract FDS files
"%FDSBuilderFolder%\FDSBuilderC-Sharp.exe" ^
--inputDiskImage "%projectFolder%\%baseImageMerged%" ^
--extract ^
--diskDirectory "%DiskDirectory%"

del "%scriptFolder%\dump.metadata.json"

:::: Dump script
for /l %%A in (0,1,1) do (
	:: A
	python "%scriptDumper%" --input "%DiskDirectory%/a/01.dka" --output "%scriptFolder%/01.dka.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/a/02.dka" --output "%scriptFolder%/02.dka.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x24"		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "01.dka"
	python "%scriptDumper%" --input "%DiskDirectory%/a/08.dka" --output "%scriptFolder%/08.dka.txt" --textPointer=0x14,0x16,0x0A	 												--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "01.dka"

	:: B
	python "%scriptDumper%" --input "%DiskDirectory%/b/00.dkb" --output "%scriptFolder%/00.dkb.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/b/01.dkb" --output "%scriptFolder%/01.dkb.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x24" 		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"
	python "%scriptDumper%" --input "%DiskDirectory%/b/02.dkb" --output "%scriptFolder%/02.dkb.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"
	python "%scriptDumper%" --input "%DiskDirectory%/b/03.dkb" --output "%scriptFolder%/03.dkb.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"

	:: C
	python "%scriptDumper%" --input "%DiskDirectory%/c/01.dkc" --output "%scriptFolder%/01.dkc.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/c/02.dkc" --output "%scriptFolder%/02.dkc.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x24"		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "01.dkc"

	:: D
	python "%scriptDumper%" --input "%DiskDirectory%/d/00.dkd" --output "%scriptFolder%/00.dkd.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkd"
	python "%scriptDumper%" --input "%DiskDirectory%/d/01.dkd" --output "%scriptFolder%/01.dkd.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x24"		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkd"
	python "%scriptDumper%" --input "%DiskDirectory%/d/02.dkd" --output "%scriptFolder%/02.dkd.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkd"
	python "%scriptDumper%" --input "%DiskDirectory%/d/03.dkd" --output "%scriptFolder%/03.dkd.txt" --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextpointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkd"
)

@pause

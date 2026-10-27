::Folders
set projectFolder=%cd%

::Roms
set baseImage1=roms\Time Twist - Rekishi no Katasumi de... - Zenpen (Japan).fds
set baseImage2=roms\Time Twist - Rekishi no Katasumi de... - Kouhen (Japan).fds
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
	python "%scriptDumper%" --input "%DiskDirectory%/a/01.dka" --output "%scriptFolder%/01.dka.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/a/02.dka" --output "%scriptFolder%/02.dka.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x24"		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "01.dka"
	python "%scriptDumper%" --input "%DiskDirectory%/a/08.dka" --output "%scriptFolder%/08.dka.txt" --dictionary=0x16 --textPointer=0x14,0x16															--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "01.dka" --embeddedPointer=0x20

	:: B
	python "%scriptDumper%" --input "%DiskDirectory%/b/00.dkb" --output "%scriptFolder%/00.dkb.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/b/01.dkb" --output "%scriptFolder%/01.dkb.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x24" 		--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"
	python "%scriptDumper%" --input "%DiskDirectory%/b/02.dkb" --output "%scriptFolder%/02.dkb.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"
	python "%scriptDumper%" --input "%DiskDirectory%/b/03.dkb" --output "%scriptFolder%/03.dkb.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkb"

	:: C
	python "%scriptDumper%" --input "%DiskDirectory%/c/02.dkc" --output "%scriptFolder%/02.dkc.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/c/03.dkc" --output "%scriptFolder%/03.dkc.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "03.dkc"
	python "%scriptDumper%" --input "%DiskDirectory%/c/04.dkc" --output "%scriptFolder%/04.dkc.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "02.dkc"
	python "%scriptDumper%" --input "%DiskDirectory%/c/05.dkc" --output "%scriptFolder%/05.dkc.txt" --dictionary=0x24 --textPointer=0x16,0x0A,0x26,0x0E,0x18,0x24										--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "02.dkc"

	:: D
	python "%scriptDumper%" --input "%DiskDirectory%/d/00.dkd" --output "%scriptFolder%/00.dkd.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/d/01.dkd" --output "%scriptFolder%/01.dkd.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json"
	python "%scriptDumper%" --input "%DiskDirectory%/d/02.dkd" --output "%scriptFolder%/02.dkd.txt" --dictionary=0x16 --textPointer=0x14,0x16,0x0A,0x26,0x0E,0x18	--embeddedTextPointer "0x1A,0x24"	--externalPointerMetadata "%scriptFolder%/dump.metadata.json" --fileOutOfBounds "00.dkd"
)

@pause

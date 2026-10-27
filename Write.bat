::Folders
set projectFolder=%cd%
set FDSBuilderFolder=%projectFolder%\tools\fdsBuilder
set xkasFolder=%projectFolder%\tools\xkas

set diskDirectory=%projectFolder%\disks
set scriptFolder=%projectFolder%\script

set scriptWriter=%projectFolder%\tools\script\write.py
set fileAdder=%projectFolder%\tools\addDisk.py

::Roms
set baseImage1=roms\Time Twist - Rekishi no Katasumi de... - Zenpen (Japan).fds
set baseImage2=roms\Time Twist - Rekishi no Katasumi de... - Kouhen (Japan).fds
set baseImageMerged=roms\Time Twist.fds
set translatedRom=%projectFolder%\roms\Time Twist (NEW).fds

cd "%projectFolder%"

::Expand FDS rom
del "%translatedRom%"
del %diskDirectory%
del %baseImageMerged%
del "%scriptFolder%/write.metadata.json"

copy /b "%baseImage1%" + "%baseImage2%" "%baseImageMerged%"

"%fdsBuilderFolder%\FDSBuilderC-Sharp.exe" ^
--inputDiskImage "%baseImageMerged%" ^
--extract ^
--diskDirectory "%diskDirectory%"

setlocal EnableDelayedExpansion

for /l %%A in (0,1,1) do (
    if %%A==1 (
        set "isDryRun=False"
    ) else (
        set "isDryRun=True"
    )
	
	python "%scriptWriter%" --input "%scriptFolder%/01.dka.txt" --output="%diskDirectory%/a/01.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_01.dka_0x001E,0x1BD8"
	python "%scriptWriter%" --input "%scriptFolder%/02.dka.txt" --output="%diskDirectory%/a/02.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True"
	python "%scriptWriter%" --input "%scriptFolder%/08.dka.txt" --output="%diskDirectory%/a/08.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_08.dka_0x0022,0x010F"
	
	python "%scriptWriter%" --input "%scriptFolder%/00.dkb.txt" --output="%diskDirectory%/b/00.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_00.dkb_0x001E,0x1BA0"
	python "%scriptWriter%" --input "%scriptFolder%/01.dkb.txt" --output="%diskDirectory%/b/01.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True"
	python "%scriptWriter%" --input "%scriptFolder%/02.dkb.txt" --output="%diskDirectory%/b/02.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True"	--fixedData "Label_02.dkb_0x001E,0x1D30"
	python "%scriptWriter%" --input "%scriptFolder%/03.dkb.txt" --output="%diskDirectory%/b/03.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True"
	
	python "%scriptWriter%" --input "%scriptFolder%/02.dkc.txt" --output="%diskDirectory%/c/02.dkc" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_02.dkc_0x001E,0x18F4"
	python "%scriptWriter%" --input "%scriptFolder%/03.dkc.txt" --output="%diskDirectory%/c/03.dkc" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_03.dkc_0x001E,0x1047"
	python "%scriptWriter%" --input "%scriptFolder%/04.dkc.txt" --output="%diskDirectory%/c/04.dkc" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_04.dkc_0x001E,0x11C6"
	python "%scriptWriter%" --input "%scriptFolder%/05.dkc.txt" --output="%diskDirectory%/c/05.dkc" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_05.dkc_0x001E,0x02DB"
	
	python "%scriptWriter%" --input "%scriptFolder%/00.dkd.txt" --output="%diskDirectory%/d/00.dkd" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_00.dkd_0x001E,0x22E4"
	python "%scriptWriter%" --input "%scriptFolder%/01.dkd.txt" --output="%diskDirectory%/d/01.dkd" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_01.dkd_0x001E,0x1C4B"
	python "%scriptWriter%" --input "%scriptFolder%/02.dkd.txt" --output="%diskDirectory%/d/02.dkd" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True" --fixedData "Label_02.dkd_0x001E,0x1485"
	python "%scriptWriter%" --input "%scriptFolder%/09.dkd.txt" --output="%diskDirectory%/d/09.dkd" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --isTranslation "True"
	
    echo isDryRun=!isDryRun!
)

endlocal

python "%fileAdder%"

::Apply ASM patches
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\a\06.dka" "asm\06.dka.asm"
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\a\08.dka" "asm\08.dka.asm"

"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\c\01.dkc" "asm\01.dkc.asm"
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\c\05.dkc" "asm\05.dkc.asm"
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\c\12.dkc" "asm\12.dkc.asm"


"%fdsBuilderFolder%\FDSBuilderC-Sharp.exe" ^
--inputDiskImage "%baseImageMerged%" ^
--outputDiskImage "%translatedRom%" ^
--merge "%diskDirectory%" ^
--diskDirectory "%diskDirectory%"

"%xkasFolder%\xkas+.exe" -o "%translatedRom%" "asm\part 2.asm"

"%translatedRom%"
@pause

::Folders
set projectFolder=%cd%
set FDSBuilderFolder=%projectFolder%\tools\fdsBuilder
set xkasFolder=%projectFolder%\tools\xkas

set diskDirectory=%projectFolder%\disks

set scriptWriter=%projectFolder%\tools\script\write.py
set scriptFolder=%projectFolder%\script

::Roms
set baseImage1=roms\Time Twist - Rekishi no Katasume de... - Zenpen (1991)(Pax Softnica-Nintendo).fds
set baseImage2=roms\Time Twist - Rekishi no Katasume de... - Kouhen (1991)(Pax Softnica-Nintendo).fds
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
	
	python "%scriptWriter%" --input "%scriptFolder%/01.dka.txt" --output="%diskDirectory%/a/01.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!"
	python "%scriptWriter%" --input "%scriptFolder%/02.dka.txt" --output="%diskDirectory%/a/02.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!"
	python "%scriptWriter%" --input "%scriptFolder%/08.dka.txt" --output="%diskDirectory%/a/08.dka" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --fixedData "Label_08.dka_0x0022,0x010F"
	
	python "%scriptWriter%" --input "%scriptFolder%/00.dkb.txt" --output="%diskDirectory%/b/00.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!" --fixedData "Label_00.dkb_0x001E,0x1BA0"
	python "%scriptWriter%" --input "%scriptFolder%/01.dkb.txt" --output="%diskDirectory%/b/01.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!"
	python "%scriptWriter%" --input "%scriptFolder%/02.dkb.txt" --output="%diskDirectory%/b/02.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!"
	python "%scriptWriter%" --input "%scriptFolder%/03.dkb.txt" --output="%diskDirectory%/b/03.dkb" --externalPointerMetadata "%scriptFolder%/write.metadata.json" --dryRun="!isDryRun!"

    echo isDryRun=!isDryRun!
)

endlocal

::Apply ASM patches
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\a\06.dka" "asm\06.dka.asm"
"%xkasFolder%\xkas+.exe" -o "%diskDirectory%\a\08.dka" "asm\08.dka.asm"

"%fdsBuilderFolder%\FDSBuilderC-Sharp.exe" ^
--inputDiskImage "%baseImageMerged%" ^
--outputDiskImage "%translatedRom%" ^
--merge "%diskDirectory%" ^
--diskDirectory "%diskDirectory%"

"%translatedRom%"
@pause
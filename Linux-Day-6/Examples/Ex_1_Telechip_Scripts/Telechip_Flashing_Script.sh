#!/bin/sh


### get the current file path
SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"


echo "######################################## Copying Sub-Core Image Files  ####################################################"

cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3.rom ./maincore/bootable/bootloader/u-boot/
cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3-tcc8050-sub.rom ./maincore/bootable/bootloader/u-boot/
cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3-tcc8050-sub-1.0-r0.rom ./maincore/bootable/bootloader/u-boot/

cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/* ./maincore/out/target/product/car_tcc8050_arm64/



echo "######################################## Creating SD-DATA FAI Image  ####################################################"

### mktcimg create .fai
echo "Create .fai file in mktcimg"
xterm -e 'cd ./maincore/bootable/bootloader/u-boot/boot-firmware/tools/mktcimg && ./mktcimg --parttype gpt --storage_size 31998345216 --fplist gpt_partition_for_arm64.list --outfile SD_Data.fai --area_name "SD Data" --gptfile SD_Data.gpt --sector_size 4096'




echo "######################################## Creating SNOR ROM Image  ####################################################"
### Make SNOR ROM Image
echo "Make SNOR ROM Image"
xterm -e 'cd ./maincore/bootable/bootloader/u-boot/boot-firmware/tools/tcc805x_snor_mkimage/ && ./tcc805x-snor-mkimage -i tcc8050.cs.cfg -o ../../tcc805x_snor.cs.rom'




### Firmware Download Sequence
echo "######################################## Flashing STARTED ###########################################################"
echo "Firmware Download Sequence......"
echo "Checking USB mode..."
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --fwdn /home/maneesh/Telechip_AOSP_10/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_fwdn.cs.json'

xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --low-format --storage ufs'

xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --low-format --storage snor'

xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn -w /home/maneesh/Telechip_AOSP_10/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_ufs_boot.json'

xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn -w /home/maneesh/Telechip_AOSP_10/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tools/mktcimg/SD_Data.fai --storage ufs --area user --sector-size 4096'

xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ &&  sudo ./fwdn --write /home/maneesh/Telechip_AOSP_10/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_snor.cs.rom --area die1 --storage snor'


echo "######################################## Flashing DONE ###########################################################"






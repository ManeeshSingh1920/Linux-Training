#!/bin/bash

# Get the current file path
SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"

# Ensure we're running from 'mydroid' directory
CURRENT_DIR="$(basename "$(pwd)")"
if [ "$CURRENT_DIR" != "mydroid" ]; then
    echo "❌ Error: Script must be run from within the 'mydroid' directory."
    echo "📍 Current directory: $CURRENT_DIR"
    exit 1
fi
echo "✅ Directory check passed. Proceeding..."

echo "####################################### MODIFY FILES TO REPLACE \\ WITH // ####################################################"
echo "✏️ Checking and modifying JSON files if needed..."

files_to_modify=(
    "./maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_fwdn.cs.json"
    "./maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_ufs_boot.json"
)

for file in "${files_to_modify[@]}"; do
    if [ -f "$file" ]; then
        if grep -q '\\\\' "$file"; then
            sed -i 's#\\\\#//#g' "$file"
            echo "🔧 Modified: $file"
        else
            echo "✅ Already modified: $file"
        fi
    else
        echo "⚠️ File not found: $file"
    fi
done

echo "######################################## Copying Sub-Core Image Files  ####################################################"

cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3.rom ./maincore/bootable/bootloader/u-boot/
cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3-tcc8050-sub.rom ./maincore/bootable/bootloader/u-boot/
cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/ca53_bl3-tcc8050-sub-1.0-r0.rom ./maincore/bootable/bootloader/u-boot/
cp ./subcore/build/tcc8050-sub/tmp/deploy/images/tcc8050-sub/* ./maincore/out/target/product/car_tcc8050_arm64/


echo "######################################## Checking GPT Partition List File ####################################################"

GPT_LIST_PATH="./maincore/bootable/bootloader/u-boot/boot-firmware/tools/mktcimg/gpt_partition_for_arm64_ab_dp.list"
GPT_SOURCE_PATH="./maincore/device/telechips/car_tcc8050_arm64/gpt_partition_for_arm64_ab_dp.list"

if [ ! -f "$GPT_LIST_PATH" ]; then
    echo "gpt_partition_for_arm64_ab_dp.list not found, copying from device directory..."
    cp "$GPT_SOURCE_PATH" "$GPT_LIST_PATH"
else
    echo "gpt_partition_for_arm64_ab_dp.list already exists."
fi


echo "######################################## Creating SD-DATA FAI Image  ####################################################"
echo "Create .fai file in mktcimg"
xterm -e 'cd ./maincore/bootable/bootloader/u-boot/boot-firmware/tools/mktcimg && ./mktcimg --parttype gpt --storage_size 31998345216 --fplist gpt_partition_for_arm64_ab_dp.list --outfile SD_Data.fai --area_name "SD Data" --gptfile SD_Data.gpt --sector_size 4096'

echo "######################################## Creating SNOR ROM Image  ####################################################"
echo "Make SNOR ROM Image"
xterm -e 'cd ./maincore/bootable/bootloader/u-boot/boot-firmware/tools/tcc805x_snor_mkimage/ && ./tcc805x-snor-mkimage -i tcc8050.cs.cfg -o ../../tcc805x_snor.cs.rom'

echo "######################################## Flashing STARTED ###########################################################"
echo "Firmware Download Sequence......"
echo "Checking USB mode..."
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --fwdn /home/oem/Documents/Telchip_8050/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_fwdn.cs.json'
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --low-format --storage ufs'
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --low-format --storage snor'
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn -w /home/oem/Documents/Telchip_8050/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_ufs_boot.json'
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn -w /home/oem/Documents/Telchip_8050/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tools/mktcimg/SD_Data.fai --storage ufs --area user --sector-size 4096'
xterm -e 'cd ./maincore/vendor/telechips/tools/FWDN/out/ && sudo ./fwdn --write /home/oem/Documents/Telchip_8050/mydroid/maincore/bootable/bootloader/u-boot/boot-firmware/tcc805x_snor.cs.rom --area die1 --storage snor'

echo "########################################✅ Flashing DONE ✅ ###########################################################"


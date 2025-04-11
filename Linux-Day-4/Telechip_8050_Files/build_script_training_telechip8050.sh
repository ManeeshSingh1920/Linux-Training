#!/bin/bash
###############################################################################
#
#                            Telechips Build Script
#
###############################################################################

###############################################################################
#
# export shell variables
#
#   CMD_V_... : variable
#   CMD_F_... : file name
#   CMD_D_... : directory name
#
###############################################################################

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

bold=$(tput bold)
normal=$(tput sgr0)
blinking="\x1b[5m"
export CMD_V_BOARD=
export CMD_V_BOARD_VER=
export CMD_V_UPPER_BOARD=
export CMD_V_PLATFORM=
export CMD_V_OS=
export CMD_V_MODE=
export CMD_V_BUILD_OPTION=
export CMD_V_HUD=
export CMD_V_GPU=
export CMD_V_STORAGE=
export CMD_V_RVC=
export CMD_V_STR=
#export CMD_V_SVM=
CMD_V_SUB_SDK=
CMD_V_SUB_MANIFEST=
CMD_V_SUB_MACHINE=
CMD_V_SUB_VERSION=
CMD_V_SUB_FEATURES=
CMD_V_SUB_SUBFEATURES=
export CMD_D_TOP=$PWD
PATH_CONFIG="device/telechips"
PATH_SUB_CONFIG="../subcore/autolinux.config"
PATH_SUB_TOOL_CONFIG="./template/sdk.py"
PATH_SUB_BUILDTOOLS="./buildtools"
PATH_SUB_SOURCE_MIRROR="./source-mirror"
##############################################################################
######################### MainCore Build func ###############################

function ANDROID_setup_env_func()
{
	echo "################################################################"
	echo "${yellow}			setup_env_func${reset}"
	echo "################################################################"

	. build/envsetup.sh

	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then 
		lunch car_${CMD_V_BOARD}_${CMD_V_PLATFORM}-${CMD_V_MODE}
	fi
	echo -e "\n\n"
}

function ANDROID_bootloader_build_func()
{
	echo "################################################################"
	echo "${yellow}		    bootloader_build_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null
	
	echo "################# Set Toolchain Path ##############################"
	
	cd ~
	cd gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin/
	export PATH=$PWD:$PATH
	cd ../..
	cd gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/
	export PATH=$PWD:$PATH
	echo $PATH
        cd $CMD_D_TOP 
	cd bootable/bootloader/u-boot/

	if [ "${CMD_V_PLATFORM}" == "arm" ]; then
		export ARCH=${CMD_V_PLATFORM}
		export CROSS_COMPILE="arm-none-linux-gnueabihf-"
	elif [ "${CMD_V_PLATFORM}" == "arm64" ]; then
		export ARCH=${CMD_V_PLATFORM}
		export CROSS_COMPILE="aarch64-none-linux-gnu-"
	fi
	export DEVICE_TREE=${CMD_V_BOARD}-${CMD_V_BOARD_VER}

	echo ""
	echo "    ARCH 		= ${green} $ARCH ${reset}"
	echo "    CROSS_COMPILE 	= ${green} $CROSS_COMPILE ${reset}"
	echo "    DEVICE_TREE 	= ${green} $DEVICE_TREE ${reset}"
	echo -e "\n"
	echo "################################################################"

	if [ "${CMD_V_OS}" = "Android-10" ]; then
		if [ "${CMD_V_STORAGE}" = "UFS" ]; then
			make tcc805x_android_10_ufs_defconfig
		else
			make tcc805x_android_10_defconfig
		fi
	fi


	if [ "${CMD_V_GPU}" = "Yes" ]; then
		if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
			./scripts/kconfig/merge_config.sh -n .config ../../../device/telechips/car_tcc8050_${CMD_V_PLATFORM}/gpu_cfg/gpu-vz.cfg
		fi
	fi


	make -j32
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_bootloader_clean_func()
{
	echo "################################################################"
	echo "${yellow}		   bootloader_clean_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null
	cd bootable/bootloader/u-boot/

	make clean
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_Kernel_build_func()
{
	echo "################################################################"
	echo "${yellow}		      kernel_build_func${reset}"
	echo "################################################################"

	unset ARCH
	unset CROSS_COMPILE


	pushd $CMD_D_TOP > /dev/null

	cd kernel

	if  [ "${CMD_V_OS}" = "Android-10" ]; then
		if [ "${CMD_V_STORAGE}" = "UFS" ]; then
			make ARCH=${CMD_V_PLATFORM} tcc805x_android_10_ivi_ufs_defconfig
		else
				make ARCH=${CMD_V_PLATFORM} tcc805x_android_10_ivi_defconfig
		fi
	fi

	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
		if [ "${CMD_V_GPU}" = "Yes" ]; then
			sed -i 's/# CONFIG_POWERVR_VZ is not set/CONFIG_POWERVR_VZ=y/g' .config
		else
			sed -i 's/CONFIG_POWERVR_VZ=y/# CONFIG_POWERVR_VZ is not set/g' .config
		fi
	fi

	if [ "${CMD_V_HUD}" = "Yes" ]; then
		sed -i 's/# CONFIG_DRM_TCC_EXT is not set/CONFIG_DRM_TCC_EXT=y/g' .config
		echo "CONFIG_DRM_TCC_EXT_VIC=1024" >> .config
		echo "# CONFIG_DRM_TCC_THIRD is not set" >> .config

		if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
		   	sed -i '/mxt_touch@4d {/{n;n; s/disabled/okay/;}' arch/arm/boot/dts/tcc/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dts
		fi
		
	else
		if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
			sed -i '/mxt_touch@4d {/{n;n; s/okay/disabled/;}' arch/arm/boot/dts/tcc/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dts
		fi

		sed -i 's/CONFIG_DRM_TCC_EXT=y/# CONFIG_DRM_TCC_EXT is not set/g' .config
	fi

	if [ "${CMD_V_RVC}" = "Yes" ]; then
		echo "CONFIG_VIOC_MGR=y" >> .config
	fi

	if [ "${CMD_V_BOARD}" != "tcc803xp" ]; then
		./tcc805x_customized_gpu_configuration.sh
	fi

	if [ "${CMD_V_PLATFORM}" = "arm64" ]; then
		make ARCH=${CMD_V_PLATFORM} CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-androidkernel- CC=$CMD_D_TOP/prebuilts/clang/host/linux-x86/clang-r353983c/bin/clang -j8
	else
		make ARCH=${CMD_V_PLATFORM} CLANG_TRIPLE=arm-linux-gnueabi- CROSS_COMPILE=arm-linux-androidkernel- CC=$CMD_D_TOP/prebuilts/clang/host/linux-x86/clang-r353983c/bin/clang -j8
	fi

	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null

}

function ANDROID_Kernel_clean_func()
{
	echo "################################################################"
	echo "${yellow}		      kernel_clean_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	cd kernel
	make clean
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null

}
function ANDROID_System_build_func()
{
	echo "################################################################"
	echo "${yellow}		    System_build_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	if [ "${CMD_V_BOARD}" = "tcc8053" ]; then
		TEMP_V_BOARD=tcc8050
	else
		TEMP_V_BOARD=${CMD_V_BOARD}
	fi
	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
		cd device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}
		git checkout BoardConfig.mk
		git checkout gpt_partition_for_arm64.list
		git checkout gpt_partition_for_arm64_ab.list
		croot
		if [ "${CMD_V_BOARD_VER}" = "evb_sv0.1" ]; then
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/BoardConfig.mk
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
                        sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab_dp.list
			sed -i "s/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
                        sed -i "s/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab_dp.list
		else
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/BoardConfig.mk
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
                        sed -i "s/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab_dp.list
			sed -i "s/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
		fi
	fi
	if [ "${CMD_V_BOARD}" = "tcc8053" ]; then
		cd device/telechips/car_${CMD_V_BOARD}_${CMD_V_PLATFORM}
		git checkout BoardConfig.mk
		git checkout gpt_partition_for_arm64.list
		git checkout gpt_partition_for_arm64_ab.list
		croot
		if [ "${CMD_V_BOARD_VER}" = "evb_sv0.1" ]; then
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/BoardConfig.mk
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv0.1.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/${TEMP_V_BOARD}-linux-subcore_sv1.0-${TEMP_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/${TEMP_V_BOARD}-linux-subcore_sv1.0-${TEMP_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv0.1-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
		else
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/BoardConfig.mk
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/${TEMP_V_BOARD}-android-lpd4x322_sv1.0.dtb/${CMD_V_BOARD}-android-lpd4x322_sv1.0.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/tc-boot-${TEMP_V_BOARD}-sub.img/tc-boot-${CMD_V_BOARD}-sub.img/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/tc-boot-${TEMP_V_BOARD}-sub.img/tc-boot-${CMD_V_BOARD}-sub.img/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/${TEMP_V_BOARD}-linux-subcore_sv1.0-${TEMP_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/${TEMP_V_BOARD}-linux-subcore_sv1.0-${TEMP_V_BOARD}-sub.dtb/${CMD_V_BOARD}-linux-subcore_sv1.0-${CMD_V_BOARD}-sub.dtb/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list
			sed -i "s/telechips-subcore-image-${TEMP_V_BOARD}-sub.ext/telechips-subcore-image-${CMD_V_BOARD}-sub.ext/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64.list
			sed -i "s/telechips-subcore-image-${TEMP_V_BOARD}-sub.ext/telechips-subcore-image-${CMD_V_BOARD}-sub.ext/g" device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/gpt_partition_for_arm64_ab.list

		fi
	fi

	cd hardware/telechips/hwc/v2.x/
	git checkout Android.mk
	croot

	if [ "${CMD_V_HUD}" = "Yes" ]; then
		sed -i 's/#LOCAL_CFLAGS += -DVIDEO_HW_PRIMARY_ONLY/LOCAL_CFLAGS += -DVIDEO_HW_PRIMARY_ONLY/g' hardware/telechips/hwc/v2.x/Android.mk
	fi

	if [ "${CMD_V_GPU}" = "Yes" ]; then
		sed -i 's/TCC_GPU_VZ ?= false/TCC_GPU_VZ ?= true/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	else
		sed -i 's/TCC_GPU_VZ ?= true/TCC_GPU_VZ ?= false/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	fi

	if [ "${CMD_V_STORAGE}" = "UFS" ]; then
		sed -i 's/TCC_UFS_SUPPORT := false/TCC_UFS_SUPPORT := true/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	else
		sed -i 's/TCC_UFS_SUPPORT := true/TCC_UFS_SUPPORT := false/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	fi

	if [ "${CMD_V_STR}" = "Yes" ]; then
		sed -i 's/persist.vendor.tcc.suspend_to_ram = false/persist.vendor.tcc.suspend_to_ram = true/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	else
		sed -i 's/persist.vendor.tcc.suspend_to_ram = true/persist.vendor.tcc.suspend_to_ram = false/g' device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/device.mk
	fi

	ulimit -u 4096
	make -j32
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_System_clean_func()
{
	echo "################################################################"
	echo "${yellow}			System_clean_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	make clean
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_All_clean_func()
{
	echo "################################################################"
	echo "${yellow}		  ANDROID_All_clean_func${reset}"
	echo "################################################################"

	ANDROID_bootloader_clean_func
	ANDROID_Kernel_clean_func
	ANDROID_System_clean_func

}

function ANDROID_All_build_func()
{
	echo "################################################################"
	echo "${yellow}		   ANDROID_All_build_func${reset}"
	echo "################################################################"

	ANDROID_bootloader_build_func
	ANDROID_Kernel_build_func
	ANDROID_System_build_func
}
################################################################################
############################# Subcore build func ###############################
function SUBCORE_bootloader_build_func()
{
	pushd $CMD_D_TOP > /dev/null
	cd ../subcore
	./autolinux -c build 'u-boot-tcc -C compile'
	popd > /dev/null
}
function SUBCORE_bootloader_clean_func()
{
        pushd $CMD_D_TOP > /dev/null
        cd ../subcore
	./autolinux -c build 'u-boot-tcc -c cleansstate'
        popd > /dev/null
}
function SUBCORE_Kernel_build_func()
{
         pushd $CMD_D_TOP > /dev/null
         cd ../subcore
	./autolinux -c build 'linux-telechips -C compile'
         popd > /dev/null
}
function SUBCORE_Kernel_clean_func()
{
         pushd $CMD_D_TOP > /dev/null
         cd ../subcore
	./autolinux -c build 'linux-telechips -c cleansstate'
         popd > /dev/null
}
function SUBCORE_All_build_func()
{
	pushd $CMD_D_TOP > /dev/null
	cd ../subcore
	./autolinux -c build
	popd > /dev/null
}
function SUBCORE_All_clean_func()
{
	pushd $CMD_D_TOP > /dev/null
	cd ../subcore
	./autolinux -c clean
	popd > /dev/null
}
function SUBCORE_Image_Copy_func()
{
	pushd $CMD_D_TOP > /dev/null
	cd ../subcore

	TEMP_V_SUB_MACHINE=${CMD_V_SUB_MACHINE/-sub/}

	if [ "${TEMP_V_SUB_MACHINE}" = "tcc8053" ]; then
		TEMP_V_BOARD=tcc8050
	else
		TEMP_V_BOARD=${TEMP_V_SUB_MACHINE}
	fi

	if [[ "$CMD_V_SUB_FEATURES" =~ "gpu-vz" ]]; then
		TEMP_V_SUBCORE_IMAGE=subcore_cluster
	else
		TEMP_V_SUBCORE_IMAGE=subcore
	fi

	cp build/${CMD_V_SUB_MACHINE}/tmp/deploy/images/${CMD_V_SUB_MACHINE}/ca53_bl3.rom ../maincore/device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/${TEMP_V_SUBCORE_IMAGE}
	cp build/${CMD_V_SUB_MACHINE}/tmp/deploy/images/${CMD_V_SUB_MACHINE}/tc-boot-${CMD_V_SUB_MACHINE}.img ../maincore/device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/${TEMP_V_SUBCORE_IMAGE}
	cp build/${CMD_V_SUB_MACHINE}/tmp/deploy/images/${CMD_V_SUB_MACHINE}/${TEMP_V_SUB_MACHINE}-linux-subcore_sv*-${CMD_V_SUB_MACHINE}.dtb ../maincore/device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/${TEMP_V_SUBCORE_IMAGE}
	cp build/${CMD_V_SUB_MACHINE}/tmp/deploy/images/${CMD_V_SUB_MACHINE}/telechips-subcore-image-${CMD_V_SUB_MACHINE}.ext4 ../maincore/device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/${TEMP_V_SUBCORE_IMAGE}
	

	popd > /dev/null
}
################################################################################
function ANDROID_fai_build_func
{
	echo "################################################################"
	echo "${yellow}		       fai_build_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
		TEMP_V_BOARD=tcc8050
	else
		TEMP_V_BOARD=${CMD_V_BOARD}
	fi
	if [ "${CMD_V_GPU}" = "Yes" ]; then
		cp device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/*.rom* bootable/bootloader/u-boot
		cp device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/* out/target/product/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}
	else
		cp device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore/*.rom* bootable/bootloader/u-boot
		cp device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore/* out/target/product/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}
	fi

	cd bootable/bootloader/u-boot/boot-firmware/tools/mktcimg


	LOCAL_V_GPT=$1
	if [ "${LOCAL_V_GPT}" = "" ]; then
		git reset --hard HEAD
		LOCAL_V_GPT=gpt_partition_for_arm64.list
	fi

	if [ "${CMD_V_STORAGE}" = "UFS" ]; then
		./mktcimg --parttype gpt --storage_size 31998345216 --fplist $LOCAL_V_GPT --outfile SD_Data.fai --area_name " SD Data" --gptfile SD_Data.gpt --sector_size 4096
	else
		./mktcimg  --parttype gpt --storage_size 7818182656 --fplist $LOCAL_V_GPT --outfile SD_Data.fai --area_name "SD Data" --gptfile SD_Data.gpt
	fi

	popd > /dev/null

	pushd $CMD_D_TOP > /dev/null

	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then
		cd bootable/bootloader/u-boot/boot-firmware/tools/tcc805x_snor_mkimage
		if [ "${CMD_V_STORAGE}" = "UFS" ]; then
			./tcc805x-snor-mkimage -i ${TEMP_V_BOARD}.cs.cfg -o tcc805x_snor.cs.ufs.rom
		else
			./tcc805x-snor-mkimage -i ${TEMP_V_BOARD}.cfg -o tcc805x_snor.rom
			#for cs board
			./tcc805x-snor-mkimage -i ${TEMP_V_BOARD}.cs.cfg -o tcc805x_snor.cs.rom
		fi

	fi

	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_OTA_build_func
{
	echo "################################################################"
	echo "${yellow}		  ANDROID_OTA_build_func${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	if [ "${CMD_V_BOARD}" = "tcc8053" ]; then
		TEMP_V_BOARD=tcc8050
	else
		TEMP_V_BOARD=${CMD_V_BOARD}
	fi
	rm -rf out/target/product/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/system/build.prop
	rm -rf out/target/product/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/vendor/build.prop
	rm -rf out/target/product/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/vendor/default.prop

	make otapackage -j8
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_repo_sync_func
{
	echo "################################################################"
	echo "${yellow}			 Repo sync${reset}"
	echo "################################################################"

	pushd $CMD_D_TOP > /dev/null

	repo sync -j8
	if [ $? -gt 0 ]; then
		popd > /dev/null
		exit 1
	fi

	popd > /dev/null
}

function ANDROID_image_sign_func
{
	pushd $CMD_D_TOP > /dev/null
	if [ "${CMD_V_BOARD}" = "tcc8050" ]; then

		cd bootable/bootloader/u-boot/boot-firmware
	fi
	if [ "${CMD_V_BOARD}" = "tcc8053" ]; then
		TEMP_V_BOARD=tcc8050
	else
		TEMP_V_BOARD=${CMD_V_BOARD}
	fi
	LOCAL_V_KEY_PATH=
	while [ -z $LOCAL_V_KEY_PATH ]
	do
		echo -e "\n\n"
		echo "**************************************************************************"
		echo "	     		    Secure Boot Key Path"
		echo "**************************************************************************"
		echo ""
		echo -n "${green} Enter the secure boot key path ? :${reset} "

		read LOCAL_V_KEY_PATH

		if [ "${LOCAL_V_KEY_PATH}" != "" ]; then
				git reset --hard HEAD
				cp -R prebuilt prebuilt_non_secure
			if [ "${TEMP_V_BOARD}" = "tcc803xp" ]; then
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/micom-bl1.rom prebuilt/micom-bl1.rom $LOCAL_V_KEY_PATH/root.key $LOCAL_V_KEY_PATH/root.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 keypackages prebuilt/keypackages.bin $LOCAL_V_KEY_PATH/root.key $LOCAL_V_KEY_PATH/mc.key $LOCAL_V_KEY_PATH/tc.key $LOCAL_V_KEY_PATH/ap.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/bl2-2.rom prebuilt/bl2-2.rom $LOCAL_V_KEY_PATH/tc.key $LOCAL_V_KEY_PATH/tc.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/hsm.bin prebuilt/hsm.bin $LOCAL_V_KEY_PATH/tc.key $LOCAL_V_KEY_PATH/tc.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/ap.rom prebuilt/ap.rom $LOCAL_V_KEY_PATH/tc.key $LOCAL_V_KEY_PATH/tc.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/optee.rom prebuilt/optee.rom $LOCAL_V_KEY_PATH/tc.key $LOCAL_V_KEY_PATH/tc.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw ../u-boot.rom ../u-boot.rom.signed $LOCAL_V_KEY_PATH/ap.key $LOCAL_V_KEY_PATH/ap.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/dram_params.bin prebuilt/dram_params.bin $LOCAL_V_KEY_PATH/ap.key $LOCAL_V_KEY_PATH/ap.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/fwdn.rom prebuilt/fwdn.rom $LOCAL_V_KEY_PATH/root.key $LOCAL_V_KEY_PATH/root.key

				cd tools/d3s_snor_mkimage
				./tcc803x-snor-mkimage-tools -c tcc803xpe.cfg -o ./tcc803x_snor_boot.rom
				$LOCAL_V_KEY_PATH/tcSignTool_v3 snor ./tcc803x_snor_boot.rom  ./tcc803x_snor_boot.rom.signed $LOCAL_V_KEY_PATH/mc.key

				cd ../../
				cp ./tools/mktcimg/gpt_partition_for_arm64.list ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				sed -i 's/u-boot.rom/u-boot.rom.signed/g' ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				sed -i 's/Image-tcc8031p-sub.bin/Image-tcc8031p-sub.bin.signed/g' ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw ../../../../device/telechips/car_tcc803xp/subcore/Image-tcc8031p-sub.bin ../../../../device/telechips/car_tcc803xp/subcore/Image-tcc8031p-sub.bin.signed $LOCAL_V_KEY_PATH/ap.key $LOCAL_V_KEY_PATH/ap.key
			else
				$LOCAL_V_KEY_PATH/tcSignTool_v3 mcert prebuilt/mcert.bin $LOCAL_V_KEY_PATH/root.key $LOCAL_V_KEY_PATH/master.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 hsmfw prebuilt_non_secure/hsm.cs.bin prebuilt/hsm.cs.bin $LOCAL_V_KEY_PATH/root.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/ca53_bl1.rom prebuilt/ca53_bl1.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/ca53_bl2.rom prebuilt/ca53_bl2.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/ca72_bl1.rom prebuilt/ca72_bl1.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/ca72_bl2.rom prebuilt/ca72_bl2.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/dram_params.bin prebuilt/dram_params.bin $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/fwdn.rom prebuilt/fwdn.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/optee.rom prebuilt/optee.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/r5_bl1-snor.rom prebuilt/r5_bl1-snor.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/r5_fw_TCC8050.rom prebuilt/r5_fw_TCC8050.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/r5_fw_TCC8059.rom prebuilt/r5_fw_TCC8059.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/r5_sub_fw.rom prebuilt/r5_sub_fw.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw prebuilt_non_secure/scfw.rom prebuilt/scfw.rom $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw ../ca72_bl3.rom ../ca72_bl3.rom.signed $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw ../../../../device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/ca53_bl3.rom ../../../../device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/ca53_bl3.rom.signed $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key
				$LOCAL_V_KEY_PATH/tcSignTool_v3 secfw ../../../../device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/tc-boot-${TEMP_V_BOARD}-sub.img ../../../../device/telechips/car_${TEMP_V_BOARD}_${CMD_V_PLATFORM}/subcore_cluster/tc-boot-${TEMP_V_BOARD}-sub.img.signed $LOCAL_V_KEY_PATH/master.key $LOCAL_V_KEY_PATH/image.key

				cp ./tools/mktcimg/gpt_partition_for_arm64.list ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				sed -i 's/ca72_bl3.rom/ca72_bl3.rom.signed/g' ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				sed -i 's/ca53_bl3.rom/ca53_bl3.rom.signed/g' ./tools/mktcimg/gpt_partition_for_arm64_signed.list
				sed -i "s/tc-boot-${TEMP_V_BOARD}-sub.img/tc-boot-${TEMP_V_BOARD}-sub.img.signed/g" ./tools/mktcimg/gpt_partition_for_arm64_signed.list
			fi
		else
			echo "${red} Secure boot key path is not set"
			exit 1
		fi
	done

	popd > /dev/null
	ANDROID_fai_build_func gpt_partition_for_arm64_signed.list
}

function FUNC_main_menu()
{
	while [ -z $CMD_V_BUILD_OPTION ]
    do
		clear
		echo "******************************************************************************************************************"
		echo "  "
		echo "${bold}${yellow} 	      		                           Build Menu${reset}	  "
		echo "  "
		echo "******************************************************************************************************************"
		echo "|                  ${bold}MainCore Build Option                |                  Subcore Build Option${normal}                  |"
		echo "+-------------------------------------------------------+--------------------------------------------------------+"
		echo "|  1. Build ALL Maincore       3. Clean + Build ALL     |  2. Build ALL Subcore        4. Clean + Build ALL      |"
		echo "| 1b. Bootloader(u-boot)      3b. Clean + Bootloader    | 2b. Bootloader(u-boot)      4b. Clean + Bootloader     |"
		echo "| 1c. Kernel                  3c. Clean + Kernel        | 2c. Kernel                  4c. Clean + Kernel         |"
		echo "| 1d. System                  3d. Clean + System        | 2d. Subcore Image Copy                                 |"
		echo "+-------------------------------------------------------+--------------------------------------------------------+"
		echo "| 1e. Change Build Config ${bold}(MainCore)${normal}                    | 2e. Change Build Config ${bold}(SubCore)${normal}                      |"
		echo "+-------------------------------------------------------+--------------------------------------------------------+"
		echo "|  p. Build ALL (Maincore + Subcore)                                                                             |"
		echo "+----------------------------------------------------------------------------------------------------------------+"
		echo "|  f. Create fai Image                                                                                           |"
		echo "+----------------------------------------------------------------------------------------------------------------+"
		echo "|  r. Repo sync                                                                                                  |"
		echo "+----------------------------------------------------------------------------------------------------------------+"
		echo "|  s. Image sign                                                                                                 |"
		echo "+----------------------------------------------------------------------------------------------------------------+"
		echo "|  0. exit                                                                                                       |"
		echo "+----------------------------------------------------------------------------------------------------------------+"

		FUNC_print_build_config

		echo -n -e "\n${green}  Which command would you like ? [0]:${reset} "

	   	read CMD_V_BUILD_OPTION
    done

    echo
    echo "Build Number : $CMD_V_BUILD_OPTION"
    echo


    case $CMD_V_BUILD_OPTION in
	## MainCore Build Option
	#################################################################
	1)
	        echo "************ Option 1 Setected"
		ANDROID_setup_env_func
		ANDROID_All_build_func
		#ANDROID_fai_build_func
	    ;;
	3)
		ANDROID_All_clean_func
		ANDROID_setup_env_func
		ANDROID_All_build_func
		#ANDROID_fai_build_func
	    ;;
	1b)


		ANDROID_setup_env_func
		ANDROID_bootloader_build_func
	    ;;

	3b)
		ANDROID_bootloader_clean_func
		ANDROID_setup_env_func
		ANDROID_bootloader_build_func
	    ;;

	1c)

		ANDROID_setup_env_func
		ANDROID_Kernel_build_func
	    ;;

	3c)
		ANDROID_Kernel_clean_func
		ANDROID_setup_env_func
		ANDROID_Kernel_build_func
	    ;;


	1d)
		ANDROID_setup_env_func
		ANDROID_System_build_func
	    ;;

	3d)
		ANDROID_System_clean_func
		ANDROID_setup_env_func
		ANDROID_System_build_func
	    ;;

	## SubCore Build Option
        #################################################################
	2)
		SUBCORE_All_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	4)
		SUBCORE_All_clean_func
		SUBCORE_All_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	2b)
		SUBCORE_bootloader_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	4b)
		SUBCORE_bootloader_clean_func
		SUBCORE_bootloader_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	2c)
		SUBCORE_Kernel_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	4c)
		SUBCORE_Kernel_clean_func
		SUBCORE_Kernel_build_func
		#SUBCORE_Image_Copy_func
	    ;;
	2d)
		SUBCORE_Image_Copy_func
	    ;;

        ## Build Maincore + Subcore 
        #################################################################
	p)
		ANDROID_setup_env_func
		ANDROID_All_build_func
		SUBCORE_All_build_func
		#SUBCORE_Image_Copy_func
		#ANDROID_fai_build_func
	    ;;

	#################################################################
	f)
		ANDROID_fai_build_func
	    ;;

	#################################################################
	1e)
		FUNC_change_build_config
		exit
	    ;;
	2e)
		FUNC_change_sub_build_config
		exit
		;;

        #################################################################
	r)
		ANDROID_repo_sync_func
	    ;;

	#################################################################
	s)
		ANDROID_image_sign_func
	    ;;

    esac

    echo

}

function FUNC_change_build_config()
{
	rm $CMD_D_TOP/*.log
	rm $CMD_D_TOP/$PATH_CONFIG/BUILD_CONFIG.txt

	FUNC_select_build_config
	FUNC_generate_build_config_txt
	export CMD_V_BUILD_OPTION=
	FUNC_main_menu
}
function FUNC_change_sub_build_config()
{
	FUNC_sub_select_build_config
	export CMD_V_BUILD_OPTION=
	FUNC_main_menu
}

function FUNC_select_build_config()
{
	LOCAL_V_BOARD=
	LOCAL_V_OS=
	LOCAL_V_PLATFORM=
	LOCAL_V_MODE=
	LOCAL_V_STORAGE=
	LOCAL_V_HUD=
	LOCAL_V_GPU=
	LOCAL_V_RVC=
	LOCAL_V_STR=
#	LOCAL_V_SVM=

	while [ -z $LOCAL_V_BOARD ]
	do
		clear
		FUNC_print_maincore_config
		echo -e "******************************$blinking${bold} Select Board ${normal}******************************"
		echo "${red} 1. TCC8050  EVB 1.0"
		echo "${red} 0. exit${reset}"
		echo "**************************************************************************"
		echo ""
		echo -n "${green}Which Build Board would you select ? [0]:${reset} "

		read LOCAL_V_BOARD

		case $LOCAL_V_BOARD in
		1)
			CMD_V_BOARD=tcc8050
			CMD_V_BOARD_VER=evb_sv1.0
			;;
		0)
			exit
			;;
		*)	echo "${red}Your selection is invalid number!!${reset}"
			LOCAL_V_BOARD=
			;;
		esac
	done

	while [ -z $LOCAL_V_OS ]
	do
		echo -e "\n\n"
		echo -e "*************************$blinking${bold} Select Android Version ${normal}*************************"
		echo "${red} 1. Android-10"
		echo "${red} 0. exit${reset}"
		echo "**************************************************************************"
		echo ""
		echo -n "${green}Which Android Version would you select ? [0]:${reset} "

		read LOCAL_V_OS

		case $LOCAL_V_OS in
		1)
			CMD_V_OS=Android-10
			CMD_V_PLATFORM=arm64
			;;
		0)
			exit
			;;
		*)
			echo "${red}Your selection is invalid number!!${reset}"
			LOCAL_V_OS=
			LOCAL_V_PLATFORM=
		esac
		echo
	done

	while [ -z $LOCAL_V_MODE ]
	do
		echo -e "\n"
		echo -e "***************************$blinking${bold} Select Build Option ${normal}**************************"
		echo "${red} 1. eng"
		echo "${red} 2. user"
		echo "${red} 3. userdebug"
		echo "${red} 0. exit${reset}"
		echo "**************************************************************************"
		echo ""
		echo -n "${green}Which user/eng Build Option would you select ? [0]:${reset} "

		read LOCAL_V_MODE

		case $LOCAL_V_MODE in
		1)
			CMD_V_MODE="eng      "
			;;
		2)
			CMD_V_MODE="user     "
			;;
		3)
			CMD_V_MODE="userdebug"
			;;
		0)
			exit
			;;
		*)
			echo "Your selection is invalid number"
			LOCAL_V_MODE=
		esac
		echo
	done

	while [ -z $LOCAL_V_STORAGE ]
	do
		echo -e "\n"
		echo -e "**************************$blinking${bold} Select Storage Option ${normal}*************************"
		echo "${red} 1. eMMC"
		echo "${red} 2. UFS"
		echo "${red} 0. exit${reset}"
		echo "**************************************************************************"
		echo ""
		echo -n "${green}Which eMMC/UFS Sotrage Option would you select ? [0]:${reset} "

		read LOCAL_V_STORAGE

		case $LOCAL_V_STORAGE in
		1)
			CMD_V_STORAGE=eMMC
			;;
		2)
			CMD_V_STORAGE=UFS
			;;
		0)
			exit
			;;
		*)
			echo "Your selection is invalid number"
			LOCAL_V_STORAGE=
		esac
		echo
	done

	CMD_V_GPU=Yes
        CMD_V_STR=No
        CMD_V_HUD=No
	export CMD_V_UPPER_BOARD=`echo $CMD_V_BOARD | tr '[:lower:]' '[:upper:]' 2> /dev/null`
}
function FUNC_sub_select_build_config()
{
	pushd $CMD_D_TOP > /dev/null
	cd ../subcore

	if [ ! -e $PATH_SUB_SOURCE_MIRROR  -o ! -e $PATH_SUB_BUILDTOOLS ]; then
		clear
	fi

	if [ ! -e $PATH_SUB_SOURCE_MIRROR ]; then
		echo ""
		echo -e "*******************************$blinking${bold} Source-Mirror path of Subcore ${normal}*******************************"
		echo ""
		echo -n "${green}If you have source-mirror, enter the path to the source-mirror (ex. /home/works/source-mirror) :${reset} "
		echo ""
		read LOCAL_V_SOURCE_MIRROR_PATH

		if [ "${LOCAL_V_SOURCE_MIRROR_PATH}" != "" ]; then
			sed -i '/SOURCE_MIRROR =/d' ${PATH_SUB_TOOL_CONFIG}
			echo "SOURCE_MIRROR = '${LOCAL_V_SOURCE_MIRROR_PATH}'" >> ${PATH_SUB_TOOL_CONFIG}
		fi
	fi

	if [ ! -e $PATH_SUB_BUILDTOOLS ]; then
		echo ""
		echo -e "*********************************$blinking${bold} BuildTools path of Subcore ${normal}********************************"
		echo ""
		echo -n "${green}If you have buildtools, enter the path to the buildtools (ex. /home/works/buildtools) :${reset} "
		echo ""

		read LOCAL_V_BUILDTOOL_PATH

		if [ "${LOCAL_V_BUILDTOOL_PATH}" != "" ]; then
			sed -i '/BUILDTOOL =/d' ${PATH_SUB_TOOL_CONFIG}
			echo "BUILDTOOL = '${LOCAL_V_BUILDTOOL_PATH}'" >> ${PATH_SUB_TOOL_CONFIG}
		fi
	fi


	./autolinux -c configure

	FUNC_load_sub_config
	popd > /dev/null
}

function FUNC_generate_build_config_txt()
{
	createtime="$(date +%s)"
	createtimefmt=`date --date='@'$createtime`

	echo "******************************************************" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo " Auto generated file by build command shell." >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo " !!!!!!!! Do not edit this file. !!!!!!!!" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo " Created time : ${createtimefmt}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "******************************************************" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo -e "\n" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_BOARD : ${CMD_V_BOARD}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_BOARD_VER : ${CMD_V_BOARD_VER}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_OS : ${CMD_V_OS}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_PLATFORM : ${CMD_V_PLATFORM}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_MODE : ${CMD_V_MODE}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_STORAGE : ${CMD_V_STORAGE}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_HUD : ${CMD_V_HUD}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_GPU : ${CMD_V_GPU}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "CMD_V_STR : ${CMD_V_STR}" >> $PATH_CONFIG/BUILD_CONFIG.txt
	echo "" >> $PATH_CONFIG/BUILD_CONFIG.txt
}

function FUNC_print_build_config()
{
	echo "##################################################################################################################"
	echo "------------------------------------------------------------------------------------------------------------------"
	echo "|                                                                                                                |"
	echo "|${bold}${yellow}                                               Configuration Info${reset}                                               |"
	echo "|                                                                                                                |"
	echo "+-------------------- ${bold}MainCore${normal} -------------------------+--------------------- ${bold}SubCore${normal} --------------------------+"
	echo "| Build Board         :${green} $CMD_V_BOARD ${reset}	                | #######################################################|"
	echo "| Build Board version :${green} $CMD_V_BOARD_VER ${reset}                      | #######################################################|"
	echo "| Android Versrion    :${green} $CMD_V_OS ${reset}                     | #######################################################|"
	echo "| Build Platform      :${green} $CMD_V_PLATFORM ${reset}                          | #######################################################|"
	echo "| Option eng/user     :${green} $CMD_V_MODE ${reset}		        | SDK         :${green} $CMD_V_SUB_SDK ${reset}                     |"
	echo "| Storage             :${green} $CMD_V_STORAGE ${reset}	                        | MANIFEST    :${green} $CMD_V_SUB_MANIFEST ${reset}             |"
	echo "| Head-Up Display     :${green} $CMD_V_HUD ${reset}	                        | MACHINE     :${green} $CMD_V_SUB_MACHINE ${reset}                             |"
	echo "| GPU Virtualization  :${green} $CMD_V_GPU ${reset}	                        | VERSION     :${green} $CMD_V_SUB_VERSION ${reset}                                 |"
	echo "| Suspend-To-Ram      :${green} $CMD_V_STR ${reset}	                        | FEATURES    : $CMD_V_SUB_FEATURES                                  "
	echo "+-------------------------------------------------------+--------------------------------------------------------+"
}

function FUNC_print_maincore_config()
{
	echo "${bold}${yellow}								"
	echo "--------------------------------------------------------------------------"
	echo "			  MainCore Configuration		  		"
	echo "--------------------------------------------------------------------------"
	echo "${reset}${normal}								"
}

function FUNC_print_subcore_config()
{
	echo "${bold}${yellow}											"
	echo "**************************************************************************"
	echo "			   SubCore Configuration				"
	echo "**************************************************************************"
	echo "${reset}${normal}								"
}

function FUNC_check_main_config()
{

	if [ -f $PATH_CONFIG/BUILD_CONFIG.txt ]
then

		CMD_V_BOARD=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_BOARD : [a-z0-9_]*/s/CMD_V_BOARD :[[:space:]]*//p")
		CMD_V_BOARD_VER=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_BOARD_VER : [a-z0-9_]*/s/CMD_V_BOARD_VER :[[:space:]]*//p")
		CMD_V_OS=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_OS : [a-z0-9_]*/s/CMD_V_OS :[[:space:]]*//p")
		CMD_V_PLATFORM=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_PLATFORM : [a-z0-9_]*/s/CMD_V_PLATFORM :[[:space:]]*//p")
		CMD_V_MODE=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_MODE : [a-z0-9_]*/s/CMD_V_MODE :[[:space:]]*//p")
	CMD_V_UPPER_BOARD=`echo $CMD_V_BOARD | tr '[:lower:]' '[:upper:]' 2> /dev/null`
		CMD_V_STORAGE=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_STORAGE : [a-z0-9_]*/s/CMD_V_STORAGE :[[:space:]]*//p")
		CMD_V_HUD=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_HUD : [a-z0-9_]*/s/CMD_V_HUD :[[:space:]]*//p")
		CMD_V_GPU=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_GPU : [a-z0-9_]*/s/CMD_V_GPU :[[:space:]]*//p")
		CMD_V_RVC=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_RVC : [a-z0-9_]*/s/CMD_V_RVC :[[:space:]]*//p")
		CMD_V_STR=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_STR : [a-z0-9_]*/s/CMD_V_STR :[[:space:]]*//p")
		#	CMD_V_SVM=$(cat $PATH_CONFIG/BUILD_CONFIG.txt | sed -n "/^CMD_V_SVM : [a-z0-9_]*/s/CMD_V_SVM :[[:space:]]*//p")


else
	FUNC_select_build_config

	if [ -z $CMD_V_BOARD ]
	then
		echo "Board is not exist , please select Board !!"
		exit 1
	fi

	if [ -z $CMD_V_BOARD_VER ]
	then
		echo "Board is not exist , please select Board Version !!"
		exit 1
	fi

	if [ -z $CMD_V_OS ]
	then
		echo "Android Version is not exist , please select Android Version !!"
		exit 1
	fi

	if [ -z $CMD_V_PLATFORM ]
	then
		echo "Platform is not exist , please select Platform !!"
		exit 1
	fi

	if [ -z $CMD_V_MODE ]
	then
		echo "Build option is not exist , please select build option !!"
		exit 1
	fi


	if [ -z $CMD_V_HUD ]
	then
			echo "HUD option is not exist , please select display option !!"
		exit 1
	fi


		if [ -z $CMD_V_GPU ]
	then
			echo "GPU-VZ option is not exist , please select display option !!"
		exit 1
	fi


	if [ -z $CMD_V_STORAGE ]
	then
		echo "boot option is not exist , please select boot option !!"
		exit 1
	fi

	if [ -z $CMD_V_STR ]
	then
		echo "STR option is not exist , please select STR option !!"
		exit 1
	fi

	FUNC_generate_build_config_txt

#		echo -e "\n\n"
#		echo "------------------------------------------------------------------------------------------------------------------"
#		echo "New create file BUILD_CONFIG.txt"
#		echo ""
#		FUNC_print_build_config
#		echo "------------------------------------------------------------------------------------------------------------------"
	fi
}
function FUNC_check_sub_config()
{
	if [ -f $PATH_SUB_CONFIG ]; then
		FUNC_load_sub_config
#		echo "Get build configuration form config file"
#		echo ""
#		FUNC_print_build_config
	else
		FUNC_sub_select_build_config
		echo "Get build configuration form config file"
	echo ""
	FUNC_print_build_config

fi
}
function FUNC_load_sub_config()
{
	CMD_V_SUB_SDK=$(cat $PATH_SUB_CONFIG | sed -n "/^SDK=[a-z0-9_]*/s/SDK=[[:space:]]*//p")
	CMD_V_SUB_MANIFEST=$(cat $PATH_SUB_CONFIG | sed -n "/^MANIFEST=[a-z0-9_]*/s/MANIFEST=[[:space:]]*//p")
	CMD_V_SUB_MACHINE=$(cat $PATH_SUB_CONFIG | sed -n "/^MACHINE=[a-z0-9_]*/s/MACHINE=[[:space:]]*//p")
	CMD_V_SUB_VERSION=$(cat $PATH_SUB_CONFIG | sed -n "/^VERSION=[a-z0-9_]*/s/VERSION=[[:space:]]*//p")
	CMD_V_SUB_FEATURES_TEMP=$(cat $PATH_SUB_CONFIG | sed -n "/^FEATURES=[a-z0-9_]*/s/FEATURES=[[:space:]]*//p")
	CMD_V_SUB_FEATURES=
	CMD_V_SUB_FEATURES_LIST=()
	CMD_V_NUM=0
	if [ ${#CMD_V_SUB_FEATURES_TEMP} -gt 40 ]; then
		while [ ${#CMD_V_SUB_FEATURES_TEMP} -gt 40 ]
		do
			CMD_V_SUB_FEATURES_LIST[$CMD_V_NUM]=${CMD_V_SUB_FEATURES_TEMP:0:39}
			let "CMD_V_NUM+=1"
			CMD_V_SUB_FEATURES_TEMP=${CMD_V_SUB_FEATURES_TEMP:39}
		done
		CMD_V_SUB_FEATURES_LIST[$CMD_V_NUM]=${CMD_V_SUB_FEATURES_TEMP}
		for features in "${CMD_V_SUB_FEATURES_LIST[@]}"; do
			if [ ${#features} -lt 39 ]; then
				CMD_V_SUB_FEATURES+=`echo -e "${green}${features}${reset}                  \n|  \t\t\t\t\t\t\t|\t\t "`
			else
				CMD_V_SUB_FEATURES+=`echo -e "${green}${features}${reset}  |\n|\t\t\t\t\t\t\t|\t\t"`
			fi
		done
	else
		CMD_V_SUB_FEATURES=`echo -e "${green}${CMD_V_SUB_FEATURES_TEMP}${reset}"`
	fi
	CMD_V_SUB_SUBFEATURES=$(cat $PATH_SUB_CONFIG | sed -n "/^SUBFEATURES=[a-z0-9_]*/s/SUBFEATURES=[[:space:]]*//p")
}
FUNC_check_main_config
FUNC_check_sub_config


if [ $# -eq 0 ]
then
	FUNC_main_menu
else
	for i in $@
	do
		CMD_V_BUILD_OPTION=$i
	   	FUNC_main_menu
	done
fi

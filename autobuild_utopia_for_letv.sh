#!/bin/bash

# author: huaqing.fang
# modify date: 20170301

# set that the script will stop when some statement error
set -e

# script config
utopia_url=ssh://hcgit03:29418/manifest/utopia
utopia_branch=c_cn_maserati_letv_dtmb_an_final-cus
tag_info_prefix=REL_938_LETV_TVOS-04.15.010.04.02.a6_
android_code_path=~/letv
build_code()
{
	common_build_cmd='make defconfig && make clean && make && make bsp -j16'
	cd $(get_code_path)

	set +e # patch for letv dvb line builded fail
	./genlink.sh
	set -e
	cd build

	# build mboot utopia	
	cp maserati/.config_maserati_nos_arm32_softfloat_static_mboot .config && eval $common_build_cmd
	mv bsp/{lib,include} $output_path/mboot
	
	# build sn utopia
	cp maserati/.config_maserati_linux_arm_hardfloat_dynamic_general .config && eval $common_build_cmd
	mv bsp/{lib,include} $output_path/sn
	
	# build tee utopia
	cp maserati/.config_maserati_nuttx_r2_softfloat_static_general .config && eval $common_build_cmd
	mv bsp/{lib,include} $output_path/tee
	
	# build android utopia
	cd $android_code_path
	source build/envsetup.sh
	echo -e '\n' > file
	lunch aosp_mangosteen-userdebug < file
	# libcutils just builded one time; if libcutils have builded that the libcutils_have_builded.magic file will be create in the android code root folder 
	if [[ ! -f libcutils_have_builded.magic ]]; then
		cd system/core/libcutils
		mma -j32
		croot
		touch libcutils_have_builded.magic 
	fi
	cd device/mstar/mangosteen/libraries/utopia/
	sh genlink.sh $(get_code_path)
	cd src/
	mm -B -j32
	cd ..
	rm -rf src/bsp
	mkdir -p $output_path/an/lib && mkdir -p $output_path/an/lib64
	mv $ANDROID_PRODUCT_OUT/obj/STATIC_LIBRARIES/libutopia_intermediates/libutopia.a $output_path/an/lib64
	mv $ANDROID_PRODUCT_OUT/obj/SHARED_LIBRARIES/libutopia_intermediates/LINKED/libutopia.so $output_path/an/lib64
	mv $ANDROID_PRODUCT_OUT/obj_arm/STATIC_LIBRARIES/libutopia_intermediates/libutopia.a $output_path/an/lib
	mv $ANDROID_PRODUCT_OUT/obj_arm/SHARED_LIBRARIES/libutopia_intermediates/LINKED/libutopia.so $output_path/an/lib
	mv $(get_code_path)/build/bsp/include $output_path/an
	
	cd $script_path
}

output_path=$(pwd)/out
script_path=$(pwd)

get_code_path()
{
	echo $script_path/$(grep -m 1 -Po '(?<=path=").*?(?=")' $script_path/.repo/manifest.xml)
}

download_code()
{
	if [[ ! -d .repo ]]; then
		repo init -u $utopia_url -b $utopia_branch && repo sync -j16 
	else
		repo sync -j16 
	fi  
} 

mark_tag()
{
	cd $(get_code_path)
	tag_info="$tag_info_prefix$(date +%Y%m%d)"
	if [[ $( git tag | grep $tag_info ) == '' ]]; then
		repo forall -c "git tag -a $tag_info -m \'$tag_info\'"	
		repo forall -c "git push origin $tag_info"
	fi
	cd $script_path
}

create_output_folder()
{
	rm -vrf $output_path
	mkdir -p $output_path/mboot
	mkdir -p $output_path/sn
	mkdir -p $output_path/an
	mkdir -p $output_path/tee
}

main()
{
	create_output_folder
	download_code
	mark_tag
	build_code
}

#set -x
main

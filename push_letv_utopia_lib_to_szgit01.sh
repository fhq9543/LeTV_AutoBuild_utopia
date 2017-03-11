#!/bin/bash

# this script need 2 arg
# arg1: the path that one branch of szgit01 
# arg2: the path that the out/ folder of utopia lib
# example: ./push_letv_utopia_lib_to_szgit01.sh ~/szgit01_letv_utopia_lib/final ~/letv_final_utopia/final/out

set -e
# script config
mboot_path=mboot
sn_path=maserati
an_path=mangosteen

# script begin
[[ $# != 2 ]] && echo -e '\e[1;41m pls input 2 args!! \e[m'
utopia_to=$(cd $1 && pwd && cd - > /dev/null)
utopia_from=$(cd $2 && pwd && cd - > /dev/null)

mboot_path=$utopia_to/$mboot_path
sn_path=$utopia_to/$sn_path
an_path=$utopia_to/$an_path

# check the folder tree of utopia_to & utopia_from 
check_folder_tree()
{
	cd $utopia_to
	[[ -d $mboot_path && -d $sn_path && -d $an_path ]] || 
		{ echo -e "\e[1;41m make sure $utopia_to have mboot&sn&an code!! \e[m" && exit 1; }
	
	subdir_of_out=(mboot/include mboot/lib sn/include sn/lib tee/include tee/lib an/include an/lib an/lib64)
	cd $utopia_from
	for dir in ${subdir_of_out[*]}; do
		[[ $(ls $dir) ]] ||
			{ echo -e "\e[1;41m $utopia_from/$dir is empty!! \e[m" && exit 1; }
	done
}

push_mboot_code()
{
	# push mboot code
	cd $mboot_path && git pull
	cp -rf $utopia_from/mboot/* $mboot_path/MstarCore/bsp/maserati
	git add $mboot_path/MstarCore/bsp/maserati
	git commit -n
	git push origin HEAD:refs/for/$(git branch | awk '{print $2}')
}

push_sn_code()
{
	# push sn code
	cd $sn_path && git pull
	cp -rf $utopia_from/sn/include/* $sn_path/libraries/utopia/sn/include
	cp -rf $utopia_from/sn/lib/* $sn_path/libraries/utopia/sn/arm-gnueabi-4.7.2/libs
	cp -rf $utopia_from/tee/include/* $sn_path/libraries/utopia/tee/include
	cp -rf $utopia_from/tee/lib/* $sn_path/libraries/utopia/tee/libs
	git add $sn_path/libraries/utopia/
	git commit -n
	git push origin HEAD:refs/for/$(git branch | awk '{print $2}')
}

push_an_code()
{
	# push an code
	cd $an_path && git pull
	cp -rf $utopia_from/an/* $an_path/libraries/utopia
	git add $an_path/libraries/utopia
	git commit -n
	git push origin HEAD:refs/for/$(git branch | awk '{print $2}')
}

main()
{
	check_folder_tree
	push_mboot_code
	push_sn_code
	push_an_code
}

#set -x
main

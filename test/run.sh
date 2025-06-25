#! /bin/bash

source ../__zenkai-deploy

check() {
	if [ "$2" == "$3" ]; then
		echo "✓ $1"
	else
		echo "✗ $1"
		echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		echo "expected:"
		echo "$3"
		echo
		echo "actual:"
		echo "$2"
		exit 1
	fi
}



echo
echo '== get_img_url'
echo '==== stable channel'
check 'should select the system image asset in stable'            $(cat test1.dat  | get_img_url stable) 'fragos-1_0000000.img.tar.xz.part.aa' 'fragos-1_0000000.img.tar.xz.part.ab'

echo
echo '==== testing channel'
check 'should select the system image asset in testing'            $(cat test1.dat  | get_img_url testing) 'fragos-2_0000000.img.tar.xz.part.aa' 'fragos-2_0000000.img.tar.xz.part.ab'

echo
echo '==== unstable channel'
check 'should select the system image asset in unstable'            $(cat test1.dat  | get_img_url unstable) 'fragos-3_0000000.img.tar.xz.part.aa' 'fragos-3_0000000.img.tar.xz.part.ab'

echo
echo '== get_boot_cfg'
check 'should return expected boot config' "$(get_boot_cfg '12_abcdef' 'initrd /12_abcdef/amd-ucode.img' 'initrd /12_abcdef/intel-ucode.img' 'ibt=off split_lock_detect=off')" \
'title 12_abcdef
linux /12_abcdef/vmlinuz-linux
initrd /12_abcdef/amd-ucode.img
initrd /12_abcdef/intel-ucode.img
initrd /12_abcdef/initramfs-linux.img
options root=LABEL=zenkai_root rw rootflags=subvol=deployments/12_abcdef quiet splash loglevel=3 rd.systemd.show_status=auto rd.udev.log_priority=3 ibt=off split_lock_detect=off'



echo
echo '== get_deployment_to_delete'

base='/tmp/zenkai_test/get_deployment_to_delete'
mkdir -p "${base}/config"
mkdir -p "${base}/deployments"

mkdir "${base}/deployments/3_a"
check 'should return empty if a valid deployment to delete is not found (no other deployments, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/4_a"
check 'should return a deployment if it is not the current version and not referenced in the boot config (one other deployment, no deployments in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") '4_a'

get_boot_cfg '4_a' > "${base}/config/boot.cfg"
check 'should return empty if a valid deployment to delete is not found (one other deployment which is referenced in the config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") ""

mkdir "${base}/deployments/1_a"
mkdir "${base}/deployments/2_a"
check 'should select a single deployment which is not active and will not become active on next boot (three other deployments, one which is in config)' $(get_deployment_to_delete '3_a' "${base}/config/boot.cfg" "${base}/deployments") '1_a'

rm -rf "${base}"

echo

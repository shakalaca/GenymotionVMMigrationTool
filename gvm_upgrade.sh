#!/bin/sh

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: $0 <old_vm_name> <new_vm_name>\n\n\
   ex: $0 \"Galaxy Nexus - 4.2.2 - with Google Apps - API 17 - 720x1280_1.2.0\" \"Galaxy Nexus - 4.2.2 - with Google Apps - API 17 - 720x1280_1.3.0\"  " >&2
  exit
fi

VM_old="$1"
VM_new="$2"

VM_base_path=~/.Genymobile/Genymotion/deployed/
VM_old_path="$VM_base_path/$1"
VM_new_path="$VM_base_path/$2"

echo Detach data disk from new VM
VBoxManage storageattach "$VM_new" --storagectl "IDEController" --port 0 --device 1 --medium none

echo Remove data partition file \(android_data_disk.vmdk\)
VBoxManage closemedium disk "$VM_new_path/android_data_disk.vmdk" --delete

echo Detach sdcard disk from new VM
VBoxManage storageattach "$VM_new" --storagectl "IDEController" --port 1 --device 0 --medium none
if [[ -e "$VM_new_path/sdcard.vdi" ]]; then
  echo Remove sdcard partition file \(sdcard.vdi\)
  VBoxManage closemedium disk "$VM_new_path/sdcard.vdi" --delete
fi

if [[ -e "$VM_new_path/android_sdcard_disk.vmdk" ]]; then
  echo Remove sdcard partition file \(android_sdcard_disk.vmdk\)
  VBoxManage closemedium disk "$VM_new_path/android_sdcard_disk.vmdk" --delete
fi

echo Copy old data partition file to new VM
VBoxManage clonehd "$VM_old_path/android_data_disk.vmdk" "$VM_new_path/android_data_disk.vmdk"

echo Attach data disk to new VM
VBoxManage storageattach "$VM_new" --storagectl "IDEController" --port 0 --device 1 --medium "$VM_new_path/android_data_disk.vmdk" --type hdd

if [[ -e "$VM_old_path/android_sdcard_disk.vmdk" ]]; then
  echo Copy old sdcard partition file to new VM \(android_sdcard_disk.vmdk\)
  VBoxManage clonehd "$VM_old_path/android_sdcard_disk.vmdk" "$VM_new_path/android_sdcard_disk.vmdk"
#  VBoxManage storageattach "$VM_new" --storagectl "IDEController" --port 1 --device 0 --medium "$VM_new_path/android_sdcard_disk.vmdk" --type hdd
fi

if [[ -e "$VM_old_path/sdcard.vdi" ]]; then
  echo Copy old sdcard partition file to new VM \(sdcard.vdi\)
  VBoxManage clonehd "$VM_old_path/sdcard.vdi" "$VM_new_path/sdcard.vdi"
  VBoxManage storageattach "$VM_new" --storagectl "IDEController" --port 1 --device 0 --medium "$VM_new_path/sdcard.vdi" --type hdd
fi

#!/bin/bash

dir=`dirname $0`
. ${dir}/script_root.sh

# check system information
sysinfofile=${script_root}/system_information
sysinfo=`dmidecode | grep 'System Information' -A3`
if [ -f ${sysinfofile} ]; then
  oldsysinfo=`cat ${sysinfofile}`
  if [ "${sysinfo}" = "${oldsysinfo}" ]; then
    echo "System is the same as the previous boot. Skip hardware inspection."
    logger -t myscript "System is the same as the previous boot. Skip hardware inspection."
    exit 0
  else
    status="System is defferent from the previous boot."
  fi
else
  status="First boot."
fi
sudo mount -o remount,rw /
echo "${sysinfo}" > ${sysinfofile}

log=${script_local}/inspect_hw.log
# clear splash screen
/usr/bin/ply-image --clear 0x000000 > /dev/null 2>&1
echo ply-image:$? > ${log}

# enable echo on /dev/tty1
(stty -F /dev/tty1 echo echonl icanon iexten isig; sleep 5) > /dev/tty1
echo stty:$? >> ${log}

msg="start hardware inspection. ${status}"
echo -e "${msg}\n" | tee /dev/tty1 | logger -t myscript
logger -t myscript "${msg}"

# read hwdb/input
inputfile=${script_root}/hwdb/input
while IFS="	" read id name script desc; do
  hit=`grep -B1 "${name}" /proc/bus/input/devices | grep "${id}"`
  if [ -n "${hit}" ]; then
    echo -e "\n${id}" | tee /dev/tty1 | logger -t myscript
    echo -e "${desc}\n" | tee /dev/tty1 | logger -t myscript
    (cd ${script_root};${script_root}/${script} nohistory 2>&1 | tee /dev/tty1 | logger -t myscript)
  fi
done < ${inputfile}

# read hwdb/vga
vgafile=${script_root}/hwdb/vga
declare -A script_vga
declare -A desc_vga
while read name script desc; do
  script_vga["${name}"]="${script}"
  desc_vga["${name}"]="${desc}"
done < ${vgafile} 

#lsmod | while read name other; do
name=`/usr/sbin/lspci -k | grep -A2 "VGA" | grep "Kernel driver in use" | sed -e 's/^.*: //g'`
if [ -n "${name}" ]; then
  script=${script_vga["${name}"]}
fi
  if [ -n "${script}" ]; then
    echo -e "\n${desc_vga["${name}"]}\n" | tee /dev/tty1 | logger -t myscript
    (cd ${script_root};${script_root}/${script_vga["${name}"]} nohistory 2>&1 | tee /dev/tty1 | logger -t myscript)
  else
    echo Known VGA Driver not found. use VESA Driver. | tee /dev/tty1 | logger -t myscript
    (cd ${script_root};${script_root}/VESA.sh nohistory 2>&1 | tee /dev/tty1 | logger -t myscript)
  fi
#done

# read hwdb/pci
pcifile=${script_root}/hwdb/pci
declare -A script_pci
declare -A desc_pci
while read id script desc; do
  script_pci["${id}"]="${script}"
  desc_pci["${id}"]="${desc}"
#  echo ${script_pci["${id}"]}
#  echo ${desc_pci["${id}"]}
done < ${pcifile}

lspci -n | while read bus a id rev; do
  script=${script_pci["${id}"]}
  if [ -n "${script}" ]; then
    echo -e "\n${desc_pci["${id}"]}\n" | tee /dev/tty1 | logger -t myscript
    (cd ${script_root};bash ${script_root}/${script_pci["${id}"]} nohistory 2>&1 | tee /dev/tty1 | logger -t myscript)
  fi
done 

# apply user defined chronos password
${script_root}/apply_chronospass.sh 2>&1 | tee /dev/tty1 | logger -t myscript

# execute history.sh
if [ -f ${script_local}/history.sh ]; then
  echo history.sh found. execute... | tee /dev/tty1 | logger -t myscript
  bash ${script_local}/history.sh 2>&1 | tee /dev/tty1 | logger -t myscript
fi

echo -e "\nHardware Inspection finished. restart now...." | tee /dev/tty1 | logger -t myscript
sync
sync
reboot





# disable echo on /dev/tty1
(stty -F /dev/tty1 -echo -echonl -icanon -iexten -isig; sleep 20) | tee /dev/tty1 | logger -t myscript

echo stty:$? >> ${log}

exit 0
~                                                                                                            
~                                                                                                            

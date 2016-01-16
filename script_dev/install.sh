#!/bin/bash

checkatadisk() {
  result=`ls -l /dev/disk/by-id | grep -x '.*[^0-9]$' | sed -e 's@../..@/dev@' | grep $1 | grep -o -e " ata[^ ]*"`
  echo ${result}
}

getinternaldisk(){
  sudo fdisk -l 2>/dev/null| grep '^Disk /dev/sd' | sed -e 's/:/,/' -e 's/Disk //' |while IFS=',' read disk size_g size_b size_s; do
    isata=`checkatadisk ${disk}`
    root=`rootdev -d|sed -e "s@${disk}@@" -e "s/[\r\n ]\+//"`
    if [ -n "${root}" -a -n "${isata}" ]; then
      echo ${disk} ${size_g} ${isata}
    fi
    
  done
}

disklist=`getinternaldisk`
disks=(`echo ${disklist} | grep -o -e '/dev/[^ ]* '`)

disknum=${#disks[@]}
maxindex=`expr ${disknum} - 1`
if [ ${disknum} -eq 0 ]; then
  echo Destination disk not found. Abort.
  exit 1
fi

echo List of Disks:
echo "${disklist}" | nl -v0 

target=${disks[0]}
if [ ${disknum} -gt 1 ]; then
  echo "Please select destination disk[0-${maxindex}] :"
  read targetnum
  expr "${targetnum}" + 1 >/dev/null 2>&1
  while [[ ($? -ge 2) || (${targetnum} -ge ${disknum}) ]]
  do
    echo "Invalid number."
    echo "Please select destination disk[0-${maxindex}] :"
    read targetnum
    expr "${targetnum}" + 1 >/dev/null 2>&1
  done 
  target=${disks[$targetnum]}
fi

echo Destination Disk: ${target}

sudo /usr/sbin/chromeos-install --dst=${target}


#checkusbdisk '/dev/sdd'


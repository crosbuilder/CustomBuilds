#!/bin/sh
source ./path.sh
if [ -z "$BOARD" ]; then
  echo "Prease set BOARD"
  exit
fi
echo ${BOARD}
overlay_name="overlay-${BOARD}"
echo ${overlay_name}
target_path=${OVERLAY_DIR}/${overlay_name}
echo ${target_path}
make_conf=${target_path}/make.conf
use=`grep -e "^USE=" ${make_conf}`
echo ${use}



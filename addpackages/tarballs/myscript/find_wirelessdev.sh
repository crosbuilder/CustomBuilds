#!/bin/bash
# search wireless device


for ((i=0; i<20; i++)); do
for path in /sys/class/net/*
do
  if [ -e ${path}/wireless ]; then
    dev=${path##*/}
    break
  fi
done
if [ -z "${dev}" ]; then
  sleep 5
fi
done;
echo ${dev}

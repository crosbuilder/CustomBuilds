#!/bin/bash

echo Apply Scripts Patches
cd ~/myenv/patches/bootloader

make dryrun
if [ 0 -ne $? ]; then
  echo Failed to dryrun. Abort.
  exit 1
fi
make apply
if [ 0 -ne $? ]; then
  echo Failed to patch. Abort.
  exit 1
fi

cd ~/trunk/src/scripts
repo start my-scripts .
if [ 0 -ne $? ]; then
  echo Failed to repo start. Abort.
  exit 1
fi

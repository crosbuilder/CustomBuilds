#!/bin/bash

echo Apply Platform2 Patches
cd /home/chromium/myenv/patches/kernel-3_14

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

# cros_workonはexecKernelReconst.shで実行する。

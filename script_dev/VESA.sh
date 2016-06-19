#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# disable modesetting
${script_root}/disable_modeset.sh

# enable vesa
${script_root}/enable_vesa.sh

# disable gpu composittinig
${script_root}/disable_gpu_compositing.sh

#!/bin/bash

. ./script_root.sh
. ./addhistory.sh

addhistory $0 "$@"

# disable modesetting
${script_root}/disable_modeset.sh

# enable vesa
${script_root}/enable_vesa.sh


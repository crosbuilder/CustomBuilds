#!/bin/bash

cd `dirname $0`
. ./script_root.sh
. ./add_chrome_dev.sh
. ./addhistory.sh

addhistory $0 "$@"

add_chrome_dev --disable-gpu-compositing
add_chrome_dev --ui-disable-threaded-compositing

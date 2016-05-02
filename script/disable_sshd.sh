#!/bin/bash
myname=$0
cd ${myname%/*}

. ./revisionup_ebuild.sh

cd /home/chromium/trunk/src/third_party/chromiumos-overlay/chromeos-base/chromeos-dev-root

sed -e '/chromeos-base\/openssh-server-init/d' -i chromeos-dev-root-0.0.1.ebuild

revisionup_ebuild

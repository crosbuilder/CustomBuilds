#!/bin/dash

# Custom Chrosh commands. 

USAGE_devmode=''
HELP_devmode='
  Enter Developer Mode on next boot.
'
cmd_devmode() (
  sudo /opt/myscript/devmode.sh
)

USAGE_normalmode='[ -f]'
HELP_normalmode='
  Return to Normal Mode on next boot.
'
cmd_normalmode() (
  sudo /opt/myscript/normalmode.sh $@
)

USAGE_rootdev=''
HELP_rootdev='
  Display the device name of the ROOT partition.
'
cmd_rootdev() (
  rootdev
)

USAGE_disklist=''
HELP_disklist='
  Display a list of disks and partitions.
'
cmd_disklist() (
  sudo fdisk -l
)

USAGE_installflash=''
HELP_installflash='
  Install Flash Player plugin.
'
cmd_installflash() (
  is_x86=`uname -a | grep -o -e 'i686'`
  if [ -n "${is_x86}" ]; then
    sudo /opt/myscript/downloadflash_ubuntu.sh
  else
    sudo /opt/myscript/downloadflash.sh
  fi
)

USAGE_chgroot=''
HELP_chgroot='
  Switch the ROOT partition between ROOT-A and ROOT-B.
'
cmd_chgroot() (
  sudo /opt/myscript/chgroot.sh
)

USAGE_suspend_lid=''
HELP_suspend_lid='
  Change the suspension settings of when closing the lid.
'
cmd_suspend_lid() (
  sudo /opt/myscript/change_use_lid.sh
)

#USAGE_restoreflash=''
#HELP_restoreflash='
#  Restore PepperFlash plugin from the old Chromium OS environment.
#'
#cmd_restoreflash() (
#  sudo /opt/myscript/restoreflash.sh
#)


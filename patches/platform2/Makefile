
PATCH_FILES = preload-network.conf.diff login_manager_X_ROOT.diff ui_conf_inspect_hw.diff installer_root_uuid.diff chromeos-setdevpasswd.diff halt_reboot_conf.diff
DRYRUN_TARGET = $(PATCH_FILES:.diff=.dryrun)
APPLY_TARGET = $(PATCH_FILES:.diff=.apply)
TARGET_DIR = ~/trunk/src/platform2

.PHONY: dryrun
dryrun: $(DRYRUN_TARGET)

%.dryrun : %.diff
	cat $? | bash -c "(cd $(TARGET_DIR);patch -p1 --dry-run)"
	touch $@

.PHONY: apply
apply: $(APPLY_TARGET)

%.apply : %.diff
	cat $? | bash -c "(cd $(TARGET_DIR);patch -p1)"
	touch $@

.PHONY: clean
clean:
	rm -f $(DRYRUN_TARGET) $(APPLY_TARGET)

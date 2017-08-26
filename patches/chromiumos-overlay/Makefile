
#PATCH_FILES = gcc-libs/gcc-libs-9999.ebuild.diff tty/tty.diff linux-firmware/linux-firmware-9999.ebuild.diff
PATCH_FILES = gcc-libs/gcc-libs-9999.ebuild.diff linux-firmware/linux-firmware-9999.ebuild.diff
DRYRUN_TARGET = $(PATCH_FILES:.diff=.dryrun)
APPLY_TARGET = $(PATCH_FILES:.diff=.apply)
TARGET_DIR = ~/trunk/src/third_party/chromiumos-overlay

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

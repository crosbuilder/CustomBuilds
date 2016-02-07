
PATCH_FILES = $(wildcard *.diff)
DRYRUN_TARGET = $(PATCH_FILES:.diff=.dryrun)
APPLY_TARGET = $(PATCH_FILES:.diff=.apply)
TARGET_DIR = ~/trunk/src/third_party/kernel/v3.14

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
	rm $(DRYRUN_TARGET) $(APPLY_TARGET)
